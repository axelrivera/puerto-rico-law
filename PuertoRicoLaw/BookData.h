//
//  BookData.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@protocol BookDataUpdateDelegate;

@class Book;

@interface BookData : NSObject <NSCoding, RKObjectLoaderDelegate, RKRequestQueueDelegate, RKRequestDelegate>

@property (unsafe_unretained, nonatomic) id <BookDataUpdateDelegate> delegate;
@property (unsafe_unretained, nonatomic) Book *currentBook;
@property (strong, nonatomic) NSMutableArray *books;
@property (strong, nonatomic) NSMutableArray *favoriteBooks;
@property (strong, nonatomic) NSArray *booksFromAPI;
@property (strong, nonatomic) NSDate *booksFromAPILastUpdate;
@property (assign, nonatomic) NSInteger downloadsSegmentedControlIndex;
@property (strong, nonatomic) RKRequestQueue *requestQueue;

+ (BookData *)sharedBookData;

- (void)loadBooks;
- (NSInteger)indexOfBook:(Book *)book;
- (NSInteger)indexOfBookInFavorites:(Book *)book;
- (NSDictionary *)booksDictionary;
- (void)getBooksFromAPI;
- (void)updateBooksFromAPI;
- (void)cancelAllBookRequests;
- (void)sortBooksAlphabetically;

@end

@protocol BookDataUpdateDelegate <NSObject>

@optional
- (void)didBeginCheckingForUpdate;
- (void)didLoadBooksForUpdate:(NSArray *)books;
- (void)didFailToLoadBooksForUpdate:(NSError *)error;
- (void)didFinishUpdatingBooks;

@end
