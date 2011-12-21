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

@property (nonatomic, readonly, strong) NSArray *books;

+ (id)sharedBookData;

- (void)loadBooks;
- (void)addBook:(Book *)book;
- (void)removeBookAtIndex:(NSInteger)index;
- (void)removeAllBooks;

@end
