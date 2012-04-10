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

- (void)findInSection:(Section *)section sectionID:(NSString *)sectionID;
- (void)findString:(NSString *)string inSection:(Section *)section titleOnly:(BOOL)titleOnly;
- (BOOL)foundString:(NSString *)string inSection:(Section *)section titleOnly:(BOOL)titleOnly;

@end

@implementation Book
{
	Section *findSection_;
	NSMutableArray *findArray_;
}

@synthesize bookID = bookID_;
@synthesize name = name_;
@synthesize shortTitle = shortTitle_;
@synthesize title = title_;
@synthesize bookDescription = bookDescription_;
@synthesize bookNotes = bookNotes_;
@synthesize lastUpdate = lastUpdate_;
@synthesize bookVersion = bookVersion_;
@synthesize mainSection = mainSection_;
@synthesize favorites = favorites_;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
		findSection_ = nil;
		findArray_ = nil;
		self.bookID = [dictionary objectForKey:kBookIDKey];
		self.name = [dictionary objectForKey:kBookNameKey];
		self.shortTitle = [dictionary objectForKey:kBookShortTitleKey];
		self.title = [dictionary objectForKey:kBookTitleKey];
		self.bookDescription = [dictionary objectForKey:kBookDescriptionKey];
		self.bookNotes = [dictionary objectForKey:kBookNotesKey];
		self.lastUpdate = [dictionary objectForKey:kBookLastUpdateKey];
		self.bookVersion = [dictionary objectForKey:kBookVersionKey];
		self.mainSection = nil;
		self.favorites = [[NSMutableArray alloc] initWithCapacity:0];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];  // this needs to be [super initWithCoder:aDecoder] if the superclass implements NSCoding
	if (self) {
		//self.object = [decoder decodeObjectForKey:@"objectName"];
		self.bookID = [decoder decodeObjectForKey:@"bookID"];
		self.name = [decoder decodeObjectForKey:@"bookName"];
		self.shortTitle = [decoder decodeObjectForKey:@"bookShortTitle"];
		self.title = [decoder decodeObjectForKey:@"bookTitle"];
		self.bookDescription = [decoder decodeObjectForKey:@"bookBookDescription"];
		self.bookNotes = [decoder decodeObjectForKey:@"bookBookNotes"];
		self.lastUpdate = [decoder decodeObjectForKey:@"bookLastUpdate"];
		self.bookVersion = [decoder decodeObjectForKey:@"bookBookVersion"];
		self.mainSection = [decoder decodeObjectForKey:@"bookMainSection"];
		NSMutableArray *favorites = [decoder decodeObjectForKey:@"bookFavorites"];
		self.favorites = favorites;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// add [super encodeWithCoder:encoder] if the superclass implements NSCoding
	//[encoder encodeObject:object forKey:@"objectName"];
	[encoder encodeObject:self.bookID forKey:@"bookID"];
	[encoder encodeObject:self.name forKey:@"bookName"];
	[encoder encodeObject:self.shortTitle forKey:@"bookShortTitle"];
	[encoder encodeObject:self.title forKey:@"bookTitle"];
	[encoder encodeObject:self.bookDescription forKey:@"bookBookDescription"];
	[encoder encodeObject:self.bookNotes forKey:@"bookBookNotes"];
	[encoder encodeObject:self.lastUpdate forKey:@"bookLastUpdate"];
	[encoder encodeObject:self.bookVersion forKey:@"bookBookVersion"];
	[encoder encodeObject:self.mainSection forKey:@"bookMainSection"];
	[encoder encodeObject:self.favorites forKey:@"bookFavorites"];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Title: %@", self.title];
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
	
	NSString *bookPath = [[NSBundle mainBundle] pathForResource:self.name ofType:@"plist"]; 
    
    // Read in the plist file
    NSDictionary *bookDictionary = [NSDictionary dictionaryWithContentsOfFile:bookPath];
	NSArray *sectionArray = [bookDictionary objectForKey:kBookSectionsKey];
	
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
	//[self archiveMainSection];
	self.mainSection = nil;
}

- (NSInteger)unsignedIndexOfSectionInFavorites:(Section *)section
{
	NSInteger index = -1;
	for (NSInteger i = 0; i < [self.favorites count]; i++) {
		Section *favoriteSection = [self.favorites objectAtIndex:i];
		if ([favoriteSection isEqualToSection:section]) {
			index = i;
			break;
		}
	}
	return index;
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
	return mainSectionPathForBookName(self.name);
}

- (void)reloadSection:(Section *)section andParent:(Section *)parent
{
	for (Section *child in section.children) {
		[self reloadSection:child andParent:section];
	}
	section.book = self;
	section.parent = parent;
}

- (Section *)sectionInMainSectionMatchingSectionID:(NSString *)sectionID
{
	findSection_ = nil;
	[self findInSection:self.mainSection sectionID:sectionID];
	return findSection_;
}

- (NSArray *)searchMainSectionWithString:(NSString *)string titleOnly:(BOOL)titleOnly
{
	findArray_ = [[NSMutableArray alloc] initWithCapacity:0];
	[self findString:string inSection:self.mainSection titleOnly:titleOnly];
	return findArray_;
}

#pragma mark - Private Methods

- (void)findInSection:(Section *)section sectionID:(NSString *)sectionID
{
	if (findSection_ != nil) {
		return;
	}
	
	if ([section.sectionID isEqualToString:sectionID]) {
		findSection_ = section;
		return;
	} else {
		for (Section *child in section.children) {
			[self findInSection:child sectionID:sectionID];
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
		NSRange textRange = [[section asciiStringForContent] rangeOfString:searchStr
																  options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
		if (textRange.location != NSNotFound) {
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)isNewComparedToBook:(Book *)book
{
	return [self.bookVersion integerValue] > [book.bookVersion integerValue];
}

- (BOOL)isEqualToBook:(Book *)book
{
	return [self.bookID caseInsensitiveCompare:book.bookID] == NSOrderedSame;
}

@end
