//
//  BookData.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

extern NSString * const BookManagerDidLoadBooksNotification;
extern NSString * const BookManagerDidDownloadBooksNotification;

@protocol BookDataUpdateDelegate;

@class Book;
@class APIBook;

@interface BookData : NSObject <NSCoding, RKObjectLoaderDelegate, RKRequestDelegate, RKRequestQueueDelegate>

@property (unsafe_unretained, nonatomic) id <BookDataUpdateDelegate> delegate;
@property (unsafe_unretained, nonatomic) Book *currentBook;
@property (strong, nonatomic) NSMutableArray *books;
@property (strong, nonatomic) NSMutableArray *favoriteBooks;
@property (strong, nonatomic) NSArray *booksFromAPI;
@property (strong, nonatomic) NSMutableArray *booksAvailableForUpdate;
@property (strong, nonatomic) NSMutableArray *booksAvailableforInstall;
@property (strong, nonatomic) NSDate *booksFromAPILastUpdate;
@property (assign, nonatomic) NSInteger downloadsSegmentedControlIndex;

+ (BookData *)sharedBookData;

- (void)loadBooks;
- (BOOL)loadBookWithName:(NSString *)bookName;
- (NSInteger)indexOfBook:(Book *)book;
- (NSInteger)indexOfBookInFavorites:(Book *)book;
- (NSDictionary *)booksDictionary;
- (void)getBooksFromAPI;
- (void)cancelAllBookRequests;
- (void)sortBooksAlphabetically;
- (void)downloadBooks:(NSArray *)books;
- (void)downloadAndInstallBook:(APIBook *)book;

@end

@protocol BookDataUpdateDelegate <NSObject>

@optional
- (void)willBeginLoadingBooks;
- (void)didLoadBooks:(NSArray *)books;
- (void)didFailToLoadBooks:(NSError *)error;
- (void)willDownloadBooks;
- (void)didFinishDownloadingBooks;
- (void)willBeginInstallingBook:(APIBook *)book;
- (void)didFinishInstallingBook:(APIBook *)book;

@end
