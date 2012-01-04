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
#import "FileHelpers.h"

@interface Book (Private)

- (void)findInSection:(Section *)section md5String:(NSString *)string;
- (void)findString:(NSString *)string inSection:(Section *)section titleOnly:(BOOL)titleOnly;
- (BOOL)foundString:(NSString *)string inSection:(Section *)section titleOnly:(BOOL)titleOnly;

@end

@implementation Book
{
	Section *findSection_;
	NSMutableArray *findArray_;
}

@synthesize name = name_;
@synthesize shortName = shortName_;
@synthesize title = title_;
@synthesize bookDescription = bookDescription_;
@synthesize date = date_;
@synthesize mainSection = mainSection_;
@synthesize favorite = favorite_;
@synthesize favoritesTitle = favoritesTitle_;
@synthesize favorites = favorites_;

// FIXME: Remember to remove the automatic file deletion
- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
		// Remove this
		deletePathInDocumentDirectory([self mainSectionDataFileName]);
		findSection_ = nil;
		findArray_ = nil;
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
	self.mainSection = [self unarchiveMainSection];
	if (self.mainSection) {
		[self reloadSection:self.mainSection andParent:nil];
		return;
	}
	
	self.favorites = [[NSMutableArray alloc] initWithCapacity:0];
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
	
	[self archiveMainSection];
}

- (void)clearSections
{
	[self archiveMainSection];
	self.mainSection = nil;
}

- (NSInteger)unsignedIndexOfFavoritesWithMd5String:(NSString *)string
{
	NSInteger index = -1;
	for (NSInteger i = 0; i < [self.favorites count]; i++) {
		Section *section = [self.favorites objectAtIndex:i];
		if ([[section md5String] isEqualToString:string]) {
			index = i;
			break;
		}
	}
	return index;
}

- (NSString *)md5String
{
	return [[NSString stringWithFormat:@"%@%@%@%@", self.name, self.title, self.shortName, self.bookDescription] md5];
}

- (void)archiveMainSection
{
	[NSKeyedArchiver archiveRootObject:self.mainSection toFile:[self mainSectionDataFileName]];
}

- (id)unarchiveMainSection
{
	return [NSKeyedUnarchiver unarchiveObjectWithFile:[self mainSectionDataFileName]];
}

- (NSString *)mainSectionDataFileName
{
	NSString *filePath = pathInDocumentDirectory([NSString stringWithFormat:@"%@_mainSection.data", self.name]);
	return filePath;
}

- (void)reloadSection:(Section *)section andParent:(Section *)parent
{
	for (Section *child in section.children) {
		[self reloadSection:child andParent:section];
	}
	section.book = self;
	section.parent = parent;
}

- (Section *)sectionInMainSectionMatchingMd5String:(NSString *)string
{
	findSection_ = nil;
	[self findInSection:self.mainSection md5String:string];
	return findSection_;
}

- (NSArray *)searchMainSectionWithString:(NSString *)string titleOnly:(BOOL)titleOnly
{
	findArray_ = [[NSMutableArray alloc] initWithCapacity:0];
	[self findString:string inSection:self.mainSection titleOnly:titleOnly];
	return findArray_;
}

#pragma mark - Private Methods

- (void)findInSection:(Section *)section md5String:(NSString *)string
{
	if (findSection_ != nil) {
		return;
	}
	
	if ([[section md5String] isEqualToString:string]) {
		findSection_ = section;
		return;
	} else {
		for (Section *child in section.children) {
			[self findInSection:child md5String:string];
		}
	}
}

- (void)findString:(NSString *)string inSection:(Section *)section titleOnly:(BOOL)titleOnly
{
	if ([self foundString:string inSection:section titleOnly:titleOnly]) {
		[findArray_ addObject:section];
	}
	for (Section *child in section.children) {
		[self findString:string inSection:child titleOnly:titleOnly];
	}
}

- (BOOL)foundString:(NSString *)string inSection:(Section *)section titleOnly:(BOOL)titleOnly
{
	NSString *searchStr = string;
	if (searchStr == nil) {
		searchStr = @"";
	}
	
	NSRange titleRange = [section.title rangeOfString:searchStr
											  options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
	if (titleRange.location != NSNotFound) {
		return YES;
	}
	
	if (!titleOnly) {
		NSRange textRange = [[section stringForContentFile] rangeOfString:searchStr
																  options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
		if (textRange.location != NSNotFound) {
			return YES;
		}
	}
	
	return NO;
}

@end
