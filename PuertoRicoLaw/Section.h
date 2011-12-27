//
//  Section.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Book;

@interface Section : NSObject <NSCoding>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *contentFile;
@property (nonatomic, strong) NSArray *children;
@property (nonatomic, unsafe_unretained) Book *book;
@property (nonatomic, unsafe_unretained) Section *parent;

- (id)initWithBook:(Book *)book;
- (id)initWithBook:(Book *)book andDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (id)initWithData:(NSData *)data;
- (NSString *)md5String;
- (NSData *)serialize;

@end
