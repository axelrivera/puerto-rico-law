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
@property (strong, nonatomic, readonly) NSArray *books;

+ (id)sharedBookData;

- (void)loadBooks;
- (void)addBook:(Book *)book;
- (void)insertBook:(Book *)book atIndex:(NSInteger)index;
- (void)removeBookAtIndex:(NSInteger)index;
- (void)removeAllBooks;

@end
