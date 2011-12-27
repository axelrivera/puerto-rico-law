//
//  Book.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "Book.h"
#import "Section.h"
#import "NSString+Extras.h"

@implementation Book

@synthesize name = name_;
@synthesize shortName = shortName_;
@synthesize title = title_;
@synthesize bookDescription = bookDescription_;
@synthesize date = date_;
@synthesize mainSection = mainSection_;
@synthesize favorite = favorite_;
@synthesize favoritesTitle = favoritesTitle_;
@synthesize favorites = favorites_;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
		self.name = [dictionary objectForKey:kBookNameKey];
		self.shortName = [dictionary objectForKey:kBookShortNameKey];
		self.title = [dictionary objectForKey:kBookTitleKey];
		self.bookDescription = [dictionary objectForKey:kBookDescriptionKey];
		self.date = [dictionary objectForKey:kBookDateKey];
		self.favoritesTitle = [dictionary objectForKey:kBookFavoritesTitleKey];
		self.mainSection = nil;
		self.favorite = NO;
		self.favorites = [[NSMutableArray alloc] initWithCapacity:0];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];  // this needs to be [super initWithCoder:aDecoder] if the superclass implements NSCoding
	if (self) {
		//self.object = [decoder decodeObjectForKey:@"objectName"];
		self.name = [decoder decodeObjectForKey:@"bookName"];
		self.shortName = [decoder decodeObjectForKey:@"bookShortName"];
		self.title = [decoder decodeObjectForKey:@"bookTitle"];
		self.bookDescription = [decoder decodeObjectForKey:@"bookBookDescription"];
		self.date = [decoder decodeObjectForKey:@"bookDate"];
		self.mainSection = [decoder decodeObjectForKey:@"bookMainSection"];
		self.favorite = [decoder decodeBoolForKey:@"bookFavorite"];
		self.favoritesTitle = [decoder decodeObjectForKey:@"bookFavoritesTitle"];
		self.favorites = [decoder decodeObjectForKey:@"bookFavorites"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// add [super encodeWithCoder:encoder] if the superclass implements NSCoding
	//[encoder encodeObject:object forKey:@"objectName"];
	[encoder encodeObject:self.name forKey:@"bookName"];
	[encoder encodeObject:self.shortName forKey:@"bookShortName"];
	[encoder encodeObject:self.title forKey:@"bookTitle"];
	[encoder encodeObject:self.bookDescription forKey:@"bookBookDescription"];
	[encoder encodeObject:self.date forKey:@"bookDate"];
	[encoder encodeObject:self.mainSection forKey:@"bookMainSection"];
	[encoder encodeBool:self.isFavorite forKey:@"bookFavorite"];
	[encoder encodeObject:self.favoritesTitle forKey:@"bookFavoritesTitle"];
	[encoder encodeObject:self.favorites forKey:@"bookFavorites"];
}

- (void)loadSections
{
	if (self.mainSection) {
		[self clearSections];
	}
	
	self.mainSection = [[Section alloc] initWithBook:self];
	
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:self.name ofType:@"plist"]; 
    
    // Read in the plist file
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
	NSArray *sectionArray = [plistDictionary objectForKey:self.name];
	
	NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:[sectionArray count]];
	
	for (NSDictionary *dictionary in sectionArray) {
		Section *section = [[Section alloc] initWithBook:self andDictionary:dictionary];
		section.parent = self.mainSection;
		[sections addObject:section];
	}
	
	if ([sections count] > 0) {
		self.mainSection.children = (NSArray *)sections;
	}
}

- (void)clearSections
{
	self.mainSection = nil;
}

- (NSString *)md5String
{
	return [[NSString stringWithFormat:@"%@%@%@%@", self.name, self.title, self.shortName, self.bookDescription] md5];
}

@end
