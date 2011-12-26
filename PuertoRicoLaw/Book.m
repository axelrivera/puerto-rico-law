//
//  Book.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "Book.h"
#import "Section.h"

@implementation Book

@synthesize name = name_;
@synthesize shortName = shortName_;
@synthesize title = title_;
@synthesize bookDescription = bookDescription_;
@synthesize mainSection = mainSection_;
@synthesize favorite = favorite_;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
		self.favorite = NO;
		self.name = [dictionary objectForKey:kBookNameKey];
		self.shortName = [dictionary objectForKey:kBookShortNameKey];
		self.title = [dictionary objectForKey:kBookTitleKey];
		self.bookDescription = [dictionary objectForKey:kBookDescriptionKey];
	}
	return self;
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

@end
