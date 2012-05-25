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
- (BOOL)installBook:(APIBook *)apiBook withData:(NSData *)fileData;

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

- (id)init
{
	self = [super init];
	if (self) {
		currentBook_ = nil;
		books_ = [[NSMutableArray alloc] initWithCapacity:0];
		favoriteBooks_ = [[NSMutableArray alloc] initWithCapacity:0];
		booksFromAPI_ = nil;
		booksAvailableForUpdate_ = [NSMutableArray arrayWithCapacity:0];
		booksAvailableForInstall_ = [NSMutableArray arrayWithCapacity:0];
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
		booksAvailableForUpdate_ = [NSMutableArray arrayWithCapacity:0];
		booksAvailableForInstall_ = [NSMutableArray arrayWithCapacity:0];
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
	
	// Path of File with the list of default books to install
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:kBookListFileName ofType:@"plist"];
    
    // Read in the plist file
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
	NSArray *booksArray = [plistDictionary objectForKey:kBookListKey];
	
	for (NSString *bookName in booksArray) {
		NSString *dictionaryPath = pathInBooksDirectory([bookName stringByAppendingPathExtension:@"plist"]);
		if (![[NSFileManager defaultManager] fileExistsAtPath:dictionaryPath]) {
			NSError *error = nil;
			[[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:bookName ofType:@"plist"]
													toPath:dictionaryPath
													 error:&error];
			if (error) continue;
		}
		[self loadBookWithName:bookName];
	}
}

- (BOOL)loadBookWithName:(NSString *)bookName
{
	NSString *dictionaryPath = pathInBooksDirectory([bookName stringByAppendingPathExtension:@"plist"]);
	NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:dictionaryPath];
	NSDictionary *bookDictionary = [dictionary objectForKey:kBookInfoKey];
	dictionary = nil;
	
	Book *defaultBook = [[Book alloc] initWithDictionary:bookDictionary];
	NSInteger bookIndex = [self indexOfBook:defaultBook];
	
	if (bookIndex == -1) {
		[self.books addObject:defaultBook];
	} else {
		Book *currentBook = [self.books objectAtIndex:bookIndex];
		if ([defaultBook isNewComparedToBook:currentBook]) {
			[self.books replaceObjectAtIndex:bookIndex withObject:defaultBook];
		}
	}
	return YES;
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
	
	NSDictionary *installedBooks = [self booksDictionary];
	
	for (APIBook *api in self.booksFromAPI) {
		Book *installed = [installedBooks objectForKey:api.name];
		if (installed) {
			if ([api.bookVersion integerValue] > [installed.bookVersion integerValue]) {
//				NSString *resourcePath = [NSString stringWithFormat:@"/download/%@", [api zipFile]];
//				request = [[RKObjectManager sharedManager].client requestWithResourcePath:resourcePath];
//				request.userData = api;
//				request.delegate = self;
			}
		}
	}
}

- (void)cancelAllBookRequests
{

}

- (void)sortBooksAlphabetically
{
	[self.books sortUsingSelector:@selector(compareTitleAlphabetically:)];
}

- (void)downloadAndInstallBook:(APIBook *)book
{
	if ([self.delegate respondsToSelector:@selector(willBeginInstallingAPIBook:)]) {
		[self.delegate willBeginInstallingAPIBook:book];
	}
	
	NSString *resourcePath = [NSString stringWithFormat:@"/download/%@", [book zipFile]];
	NSLog(@"Resource Path: %@", resourcePath);
	RKRequest *request = [[RKObjectManager sharedManager].client requestWithResourcePath:resourcePath];
	request.method = RKRequestMethodGET;
	request.userData = book;
	request.delegate = self;
	[request send];
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
			// We don't care about books that are In-App Purchases.  They will be handled somewhere else.
			if (!book.isPurchase && [book.bookVersion integerValue] > [installed.bookVersion integerValue]) {
				[updateArray addObject:book];
			}
		}
	}
	self.booksAvailableForUpdate = updateArray;
	self.booksAvailableforInstall = installArray;
}

- (BOOL)installBook:(APIBook *)apiBook withData:(NSData *)fileData
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:pathInBooksDirectory(@"")]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:pathInBooksDirectory(@"")
								  withIntermediateDirectories:NO
												   attributes:nil
														error:nil];
	}
	
	if (![[fileData MD5] isEqualToString:apiBook.md5]) {
		NSLog(@"Hash mismatch");
		return NO;
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
				
				NSError *error;
				NSString *tmpFilePath = nil;
				
				if ([[NSFileManager defaultManager] fileExistsAtPath:tmpPlistFilepath])
				{
					if ([[NSFileManager defaultManager] fileExistsAtPath:bookPath]) {
						tmpFilePath = pathInBooksDirectory(@"tmp.plist");
						error = nil;
						// Move the current book to a temporary file
						[[NSFileManager defaultManager] moveItemAtPath:bookPath toPath:tmpFilePath error:&error];
						if (error) {
							NSLog(@"Error moving current book to temporary file");
							return NO;
						}
					}
						
					error = nil;
					// Move downloaded file to the documents directory
					[[NSFileManager defaultManager] moveItemAtPath:tmpPlistFilepath toPath:bookPath error:&error];
					if (error) {
						// If we couldn't move the new file then move the old file back
						[[NSFileManager defaultManager] moveItemAtPath:tmpFilePath toPath:bookPath error:nil];
						NSLog(@"Error moving file back to old file");
						return NO;
					} else {
						if (tmpFilePath) {
							// Remove the temporary file if we succedded installing the new file
							[[NSFileManager defaultManager] removeItemAtPath:tmpFilePath error:nil];
						}
						NSLog(@"Oh my YES");
						return YES;
					}
				}
			}
		}
	}
	NSLog(@"WTF!");
	return NO;
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
		if ([response.contentType isEqualToString:@"application/zip"]) {
			NSLog(@"Content Type: %@, Content Length: %@", response.contentType, response.contentLength);
			if ([self installBook:request.userData withData:[response body]]) {
				if ([self.delegate respondsToSelector:@selector(didFinishInstallingAPIBook:)]) {
					[self.delegate didFinishInstallingAPIBook:request.userData];
				}
			} else {
				NSLog(@"Something happened");
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
