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

@property (strong, nonatomic) NSString *sectionID;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) NSString *sublabel;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSArray *children;
@property (unsafe_unretained, nonatomic) Book *book;
@property (unsafe_unretained, nonatomic) Section *parent;

- (id)initWithBook:(Book *)book;
- (id)initWithBook:(Book *)book andDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)asciiStringForContent;
- (NSInteger)indexPositionAtParent;
- (BOOL)isEqualToSection:(Section *)section;

@end
