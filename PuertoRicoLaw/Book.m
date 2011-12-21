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
@synthesize title = title_;
@synthesize bookDescription = bookDescription_;
@synthesize directory = directory_;
@synthesize sections = sections_;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
		name_ = [dictionary objectForKey:kBookNameKey];
		title_ = [dictionary objectForKey:kBookTitleKey];
		bookDescription_ = [dictionary objectForKey:kBookDescriptionKey];
		directory_ = [dictionary objectForKey:kBookDirectoryKey];
	}
	return self;
}

- (void)loadSections
{
	if (self.sections) {
		[self clearSections];
	}
	
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:self.name ofType:@"plist"]; 
    
    // Read in the plist file
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
	NSArray *sectionArray = [plistDictionary objectForKey:self.name];
	
	NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:[sectionArray count]];
	
	for (NSDictionary *dictionary in sectionArray) {
		Section *section = [[Section alloc] initWithDictionary:dictionary];
		[sections addObject:section];
	}
	
	if ([sections count] > 0) {
		self.sections = [NSArray arrayWithArray:sections];
	}
}

- (void)clearSections
{
	self.sections = nil;
}

@end
