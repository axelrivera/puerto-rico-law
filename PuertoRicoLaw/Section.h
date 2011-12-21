//
//  Section.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Book;

@interface Section : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *directory;
@property (nonatomic, strong) NSString *contentFile;
@property (nonatomic, strong) NSArray *children;
@property (nonatomic, weak) Book *book;
@property (nonatomic, weak) Section *parent;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary book:(Book *)book;

@end
