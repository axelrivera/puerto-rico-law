//
//  Book.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *shortName;
@property (strong, nonatomic) NSString *bookDescription;
@property (strong, nonatomic) NSString *directory;
@property (strong, nonatomic) NSArray *sections;
@property (assign, nonatomic, getter = isFavorite) BOOL favorite;


- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)loadSections;
- (void)clearSections;

@end
