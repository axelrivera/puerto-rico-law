//
//  BookData.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@class Book;

@interface BookData : NSObject <NSCoding, RKObjectLoaderDelegate, RKRequestQueueDelegate, RKRequestDelegate>

@property (unsafe_unretained, nonatomic) Book *currentBook;
@property (strong, nonatomic) NSMutableArray *books;
@property (strong, nonatomic) NSMutableArray *favoriteBooks;
@property (strong, nonatomic) NSArray *booksFromAPI;
@property (strong, nonatomic) NSDate *booksFromAPILastUpdate;
@property (assign, nonatomic) NSInteger favoritesSegmentedControlIndex;
@property (strong, nonatomic) RKRequestQueue *requestQueue;

+ (BookData *)sharedBookData;

- (void)loadBooks;
- (NSInteger)indexOfBook:(Book *)book;
- (NSInteger)indexOfBookInFavorites:(Book *)book;
- (NSDictionary *)booksDictionary;
- (void)getBooksFromAPI;
- (void)updateBooksFromAPI;

@end
