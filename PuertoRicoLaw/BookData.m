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

static BookData *sharedBookData_ = nil;

@implementation BookData

@synthesize currentBook = currentBook_;
@synthesize books = books_;
@synthesize favoriteBooks = favoriteBooks_;
@synthesize booksFromAPI = booksFromAPI_;
@synthesize booksFromAPILastUpdate = booksFromAPILastUpdate_;
@synthesize favoritesSegmentedControlIndex = favoritesSegmentedControlIndex_;
@synthesize requestQueue = requestQueue_;

- (id)init
{
	self = [super init];
	if (self) {
		currentBook_ = nil;
		books_ = [[NSMutableArray alloc] initWithCapacity:0];
		favoriteBooks_ = [[NSMutableArray alloc] initWithCapacity:0];
		booksFromAPI_ = nil;
		booksFromAPILastUpdate_ = nil;
		favoritesSegmentedControlIndex_ = 0;
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
		self.books = [[NSMutableArray alloc] initWithArray:books];
		
		NSArray *favoriteBooks = [decoder decodeObjectForKey:@"bookDataFavoriteBooks"];
		self.favoriteBooks = [[NSMutableArray alloc] initWithArray:favoriteBooks];
		
		self.booksFromAPILastUpdate = [decoder decodeObjectForKey:@"booksFromAPILastUpdate"];
		
		NSNumber *number = [decoder decodeObjectForKey:@"bookDataFavoritesSegmentControlIndex"];
		self.favoritesSegmentedControlIndex = [number integerValue];
		[self loadBooks];
		
		self.booksFromAPI = nil;
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
	
	[encoder encodeObject:[NSNumber numberWithInteger:self.favoritesSegmentedControlIndex]
				   forKey:@"bookDataFavoritesSegmentControlIndex"];
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
}

- (void)updateBooksFromAPI
{
	RKRequestQueue *queue = [RKRequestQueue requestQueue];
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
	
	if ([queue count] > 0) {
		[queue start];
	}
	
	self.requestQueue = queue;
}

#pragma mark - RestKit Delegate Methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
	self.booksFromAPI = objects;
	self.booksFromAPILastUpdate = [NSDate date];
	[self updateBooksFromAPI];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
	// Error Code
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
	if ([response isSuccessful]) {
		APIBook *apiBook = request.userData;
		NSData *fileData = [response body];
		
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

- (void)requestQueue:(RKRequestQueue *)queue didSendRequest:(RKRequest *)request
{
    // Code here
}

- (void)requestQueueDidBeginLoading:(RKRequestQueue *)queue
{
	// Code here
}

- (void)requestQueueDidFinishLoading:(RKRequestQueue *)queue
{
    [self loadBooks];	
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
