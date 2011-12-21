//
//  Book.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *bookDescription;
@property (nonatomic, strong) NSString *directory;
@property (nonatomic, strong) NSArray *sections;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)loadSections;
- (void)clearSections;

@end
