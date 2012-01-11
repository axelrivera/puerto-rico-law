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
@property (strong, nonatomic) NSString *shortTitle;
@property (strong, nonatomic) NSString *bookDescription;
@property (strong, nonatomic) NSDate *lastUpdate;
@property (strong, nonatomic) Section *mainSection;
@property (strong, nonatomic) NSString *favoritesTitle;
@property (strong, nonatomic) NSMutableArray *favorites;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)loadSections;
- (void)clearSections;
- (NSInteger)unsignedIndexOfFavoritesWithSectionID:(NSString *)sectionID;
- (void)archiveMainSection;
- (id)unarchiveMainSection;
- (NSString *)mainSectionDataFileName;
- (void)reloadSection:(Section *)section andParent:(Section *)parent;
- (Section *)sectionInMainSectionMatchingSectionID:(NSString *)sectionID;
- (NSArray *)searchMainSectionWithString:(NSString *)string titleOnly:(BOOL)titleOnly;
- (BOOL)isOlderComparedToBook:(Book *)book;

@end
