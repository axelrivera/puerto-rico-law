//
//  Book.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Section;

@interface Book : NSObject <NSCoding>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *shortName;
@property (strong, nonatomic) NSString *bookDescription;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) Section *mainSection;
@property (assign, nonatomic, getter = isFavorite) BOOL favorite;
@property (strong, nonatomic) NSString *favoritesTitle;
@property (strong, nonatomic) NSMutableArray *favorites;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)loadSections;
- (void)clearSections;
- (NSInteger)unsignedIndexOfFavoritesWithMd5String:(NSString *)string;
- (NSString *)md5String;
- (void)archiveMainSection;
- (id)unarchiveMainSection;
- (NSString *)mainSectionDataFileName;
- (void)reloadSection:(Section *)section andParent:(Section *)parent;

@end
