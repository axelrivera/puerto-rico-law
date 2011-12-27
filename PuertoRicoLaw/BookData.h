//
//  BookData.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Book;

@interface BookData : NSObject

@property (strong, nonatomic) Book *currentBook;
@property (strong, nonatomic) NSMutableArray *books;
@property (strong, nonatomic) NSMutableArray *favoriteBooks;
@property (strong, nonatomic) NSMutableArray *favoriteContent;
@property (assign, nonatomic) NSInteger favoritesSegmentedControlIndex;

+ (id)sharedBookData;

- (void)loadBooks;

- (NSInteger)unsignedIndexOfFavoriteContentWithMd5String:(NSString *)string;

@end
