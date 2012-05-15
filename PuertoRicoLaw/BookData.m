//
//  BookData.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "BookData.h"
#import "Book.h"
#import "Section.h"
#import "FileHelpers.h"
#import "APIBook.h"
#import "ZipArchive.h"

#define kDownloadQueueName @"DownloadQueueName"

NSString * const BookManagerDidLoadBooksNotification = @"BookManagerDidLoadBooksNotification";

static BookData *sharedBookData_ = nil;

@interface BookData (Private)

- (void)setupBooksforUpdateAndInstall;
- (void)runRequests;

@end

@implementation BookData
{
	NSMutableArray *updateRequests_;
}

@synthesize delegate = delegate_;
@synthesize currentBook = currentBook_;
@synthesize books = books_;
@synthesize favoriteBooks = favoriteBooks_;
@synthesize booksFromAPI = booksFromAPI_;
@synthesize booksAvailableForUpdate = booksAvailableForUpdate_;
@synthesize booksAvailableforInstall = booksAvailableForInstall_;
@synthesize booksFromAPILastUpdate = booksFromAPILastUpdate_;
@synthesize downloadsSegmentedControlIndex = downloadsSegmentedControlIndex_;
@synthesize requestQueue = requestQueue_;

- (id)init
{
	self = [super init];
	if (self) {
		currentBook_ = nil;
		books_ = [[NSMutableArray alloc] initWithCapacity:0];
		favoriteBooks_ = [[NSMutableArray alloc] initWithCapacity:0];
		booksFromAPI_ = nil;
		booksAvailableForUpdate_ = [NSArray array];
		booksAvailableForInstall_ = [NSArray array];
		booksFromAPILastUpdate_ = nil;
		downloadsSegmentedControlIndex_ = 0;
		updateRequests_ = [[NSMutableArray alloc] initWithCapacity:0];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	// this needs to be [super initWithCoder:aDecoder] if the superclass implements NSCoding
	self = [super init];
	if (self) {
		//self.object = [decoder decodeObjectForKey:@"objectName"];
		NSArray *books = [decoder decodeObjectForKey:@"bookDataBooks"];
		books_ = [[NSMutableArray alloc] initWithArray:books];
		
		NSArray *favoriteBooks = [decoder decodeObjectForKey:@"bookDataFavoriteBooks"];
		favoriteBooks_ = [[NSMutableArray alloc] initWithArray:favoriteBooks];
		
		booksFromAPILastUpdate_ = [decoder decodeObjectForKey:@"booksFromAPILastUpdate"];
		
		NSNumber *downloadsIndex = [decoder decodeObjectForKey:@"bookDataDownloadsSegmentedControlIndex"];
		if (downloadsIndex == nil) {
			downloadsIndex = [NSNumber numberWithInteger:0];
		}
		downloadsSegmentedControlIndex_ = [downloadsIndex integerValue];
		
		[self loadBooks];
		booksFromAPI_ = nil;
		booksAvailableForUpdate_ = [NSArray array];
		booksAvailableForInstall_ = [NSArray array];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// add [super encodeWithCoder:encoder] if the superclass implements NSCoding
	//[encoder encodeObject:object forKey:@"objectName"];
	[encoder encodeObject:self.books forKey:@"bookDataBooks"];
	[encoder encodeObject:self.favoriteBooks forKey:@"bookDataFavoriteBooks"];
	[encoder encodeObject:self.booksFromAPILastUpdate forKey:@"booksFromAPILastUpdate"];
		
	[encoder encodeObject:[NSNumber numberWithInteger:self.downloadsSegmentedControlIndex]
				   forKey:@"bookDataDownloadsSegmentedControlIndex"];
}

- (void)loadBooks
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:pathInBooksDirectory(@"")]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:pathInBooksDirectory(@"")
												   withIntermediateDirectories:NO
												   attributes:nil
														error:nil];
	}
	
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:kBookListFileName ofType:@"plist"];
    
    // Read in the plist file
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
	NSArray *booksArray = [plistDictionary objectForKey:kBookListKey];
	
	NSInteger bookIndex;
	for (NSString *string in booksArray) {
		NSString *dictionaryPath = pathInBooksDirectory([string stringByAppendingPathExtension:@"plist"]);
		if (![[NSFileManager defaultManager] fileExistsAtPath:dictionaryPath]) {
			NSError *error = nil;
			[[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:string ofType:@"plist"]
													toPath:dictionaryPath
													 error:&error];
			if (error) continue;
		}
		
		NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:dictionaryPath];
		NSDictionary *bookDictionary = [dictionary objectForKey:kBookInfoKey];
		dictionary = nil;
		
		Book *defaultBook = [[Book alloc] initWithDictionary:bookDictionary];
		bookIndex = [self indexOfBook:defaultBook];
		
		if (bookIndex == -1) {
			[self.books addObject:defaultBook];
		} else {
			Book *currentBook = [self.books objectAtIndex:bookIndex];
			if ([defaultBook isNewComparedToBook:currentBook]) {
				[self.books replaceObjectAtIndex:bookIndex withObject:defaultBook];
				deletePathInDocumentDirectory(mainSectionFilenameForBookName(defaultBook.name));
			}
		}
	}
}

- (NSInteger)indexOfBook:(Book *)book
{
	NSInteger index = -1;
	for (NSInteger i = 0; i < [self.books count]; i++) {
		Book *currentBook = [self.books objectAtIndex:i];
		if ([currentBook isEqualToBook:book]) {
			index = i;
			break;
		}
	}
	return index;
}

- (NSInteger)indexOfBookInFavorites:(Book *)book
{
	NSInteger index = -1;
	for (NSInteger i = 0; i < [self.favoriteBooks count]; i++) {
		Book *favoriteBook = [self.favoriteBooks objectAtIndex:i];
		if ([favoriteBook isEqualToBook:book]) {
			index = i;
			break;
		}
	}
	return index;
}

- (NSDictionary *)booksDictionary
{
	NSMutableDictionary *booksDictionary = [[NSMutableDictionary alloc] initWithCapacity:[self.books count]];
	for (Book *book in self.books) {
		[booksDictionary setObject:book forKey:book.name];
	}
	return booksDictionary;
}

- (void)getBooksFromAPI
{
	[[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/books" delegate:self];
	if ([self.delegate respondsToSelector:@selector(didBeginCheckingForUpdate)]) {
		[self.delegate didBeginCheckingForUpdate];
	}
}

- (void)updateBooksFromAPI
{
	[updateRequests_ removeAllObjects];
	RKRequestQueue *queue = [RKRequestQueue newRequestQueueWithName:kDownloadQueueName];
	queue.suspended = YES;
	queue.delegate = self;
	queue.concurrentRequestsLimit = 1;
	queue.showsNetworkActivityIndicatorWhenBusy = YES;
	
	NSDictionary *installedBooks = [self booksDictionary];
	
	RKRequest *request = nil;
	
	for (APIBook *api in self.booksFromAPI) {
		Book *installed = [installedBooks objectForKey:api.name];
		if (installed) {
			if ([api.bookVersion integerValue] > [installed.bookVersion integerValue]) {
				NSString *resourcePath = [NSString stringWithFormat:@"/download/%@", [api zipFile]];
				request = [[RKObjectManager sharedManager].client requestWithResourcePath:resourcePath];
				request.userData = api;
				request.delegate = self;
				[queue addRequest:request];
			}
		}
	}
	
	queue.suspended = NO;
	self.requestQueue = queue;
}

- (void)cancelAllBookRequests
{
	[[RKObjectManager sharedManager].client.requestQueue cancelAllRequests];
	[self.requestQueue cancelAllRequests];
	self.requestQueue = nil;
}

- (void)sortBooksAlphabetically
{
	[self.books sortUsingSelector:@selector(compareTitleAlphabetically:)];
}

#pragma mark - Private Methods

- (void)setupBooksforUpdateAndInstall
{
	NSDictionary *installedBooks = [self booksDictionary];
	NSMutableArray *updateArray = [[NSMutableArray alloc] initWithCapacity:0];
	NSMutableArray *installArray = [[NSMutableArray alloc] initWithCapacity:0];
	for (APIBook *book in self.booksFromAPI) {
		Book *installed = [installedBooks objectForKey:book.name];
		if (installed == nil) {
			[installArray addObject:book];
		} else {
			if (!book.isPurchase && [book.bookVersion integerValue] > [installed.bookVersion integerValue]) {
				[updateArray addObject:book];
			}
		}
	}
	self.booksAvailableForUpdate = updateArray;
	self.booksAvailableforInstall = installArray;
}

- (void)runRequests
{
	for (NSDictionary *dictionary in updateRequests_) {
		APIBook *apiBook = [dictionary objectForKey:@"apiBook"];
		NSData *fileData = [dictionary objectForKey:@"apiData"];
		
		if (![[fileData MD5] isEqualToString:apiBook.md5]) {
			return;
		}
		
		NSString *tmpZipFilepath = pathInTemporaryDirectory([apiBook zipFile]);
		NSString *tmpPlistFilepath = pathInTemporaryDirectory([apiBook plistFile]);
		NSString *bookPath = pathInBooksDirectory([apiBook plistFile]);
		BOOL didWriteFile = [fileData writeToFile:tmpZipFilepath atomically:YES];
		if (didWriteFile) {
			ZipArchive *archive = [[ZipArchive alloc] init];
			if ([archive UnzipOpenFile:tmpZipFilepath]) {
				if ([archive UnzipFileTo:pathInTemporaryDirectory(@"") overWrite:YES]) {
					[archive UnzipCloseFile];
					if ([[NSFileManager defaultManager] fileExistsAtPath:tmpPlistFilepath]) {
						if ([[NSFileManager defaultManager] fileExistsAtPath:bookPath]) {
							NSString *tmpFilePath = pathInBooksDirectory(@"tmp.plist");
							
							NSError *error = nil;
							[[NSFileManager defaultManager] moveItemAtPath:bookPath toPath:tmpFilePath error:&error];
							if (error) return;
							
							error = nil;
							[[NSFileManager defaultManager] moveItemAtPath:tmpPlistFilepath toPath:bookPath error:&error];
							if (error) {
								[[NSFileManager defaultManager] moveItemAtPath:tmpFilePath toPath:bookPath error:nil];
							} else {
								[[NSFileManager defaultManager] removeItemAtPath:tmpFilePath error:nil];
							}
						}
					}
				}
			}
		}
	}
}

#pragma mark - RestKit Delegate Methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
	self.booksFromAPI = objects;
	self.booksFromAPILastUpdate = [NSDate date];
	[self setupBooksforUpdateAndInstall];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:BookManagerDidLoadBooksNotification object:nil];
	
	if ([self.delegate respondsToSelector:@selector(didLoadBooksForUpdate:)]) {
		[self.delegate didLoadBooksForUpdate:objects];
	}
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
	NSLog(@"%@", error);
	if ([self.delegate respondsToSelector:@selector(didFailToLoadBooksForUpdate:)]) {
		[self.delegate didFailToLoadBooksForUpdate:error];
	}
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
	NSLog(@"finished request");
	if ([response isSuccessful]) {
		NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
									request.userData, @"apiBook",
									[response body], @"apiData",
									nil];
		[updateRequests_ addObject:dictionary];
	}
}

- (void)requestQueue:(RKRequestQueue *)queue didSendRequest:(RKRequest *)request
{
	NSLog(@"RKRequestQueue %@ is current loading %d of %d requests", queue, [queue loadingCount], [queue count]);
}

- (void)requestQueueDidBeginLoading:(RKRequestQueue *)queue
{
	NSLog(@"Queue began loading with objects: %d", [queue count]);
}

- (void)requestQueueDidFinishLoading:(RKRequestQueue *)queue
{
	if ([queue.name isEqualToString:kDownloadQueueName]) {
		[self performSelectorOnMainThread:@selector(runRequests) withObject:nil waitUntilDone:YES];
		[self performSelectorOnMainThread:@selector(loadBooks) withObject:nil waitUntilDone:YES];
		
		if ([queue count] == 1) {
			if ([self.delegate respondsToSelector:@selector(didFinishUpdatingBooks)]) {
				NSLog(@"Finished Updating Books");
				[self.delegate didFinishUpdatingBooks];
			}
		}
	}
}

#pragma mark - Singleton Code

+ (BookData *)sharedBookData
{
    if (sharedBookData_ == nil) {
        sharedBookData_ = [[super allocWithZone:NULL] init];
    }
    return sharedBookData_;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedBookData];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
