//
//  BookData.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Book;

@interface BookData : NSObject <NSCoding>

@property (unsafe_unretained, nonatomic) Book *currentBook;
@property (strong, nonatomic) NSMutableArray *books;
@property (strong, nonatomic) NSMutableArray *favoriteBooks;
@property (assign, nonatomic) NSInteger favoritesSegmentedControlIndex;

+ (BookData *)sharedBookData;

- (void)loadBooks;
- (NSInteger)indexOfBookWithName:(NSString *)name;
- (NSInteger)indexOfFavoriteBookWithName:(NSString *)name;

@end
