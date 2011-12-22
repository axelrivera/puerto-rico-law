//
//  Section.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "Section.h"
#import "Book.h"

@implementation Section

@synthesize title = title_;
@synthesize label = label_;
@synthesize directory = directory_;
@synthesize contentFile = contentFile_;
@synthesize children = children_;
@synthesize book = book_;
@synthesize parent = parent_;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [self initWithDictionary:dictionary book:nil];
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary book:(Book *)book
{
	self = [super init];
	if (self) {
		title_ = [dictionary objectForKey:kSectionTitleKey];
		label_ = [dictionary objectForKey:kSectionLabelKey];
		directory_ = [dictionary objectForKey:kSectionDirectoryKey];
		book_ = book;
		parent_ = nil;
		
		if ([dictionary objectForKey:kSectionContentFileKey]) {
			contentFile_ = [dictionary objectForKey:kSectionContentFileKey];
		}
		
		if ([dictionary objectForKey:kSectionChildrenKey]) {
			NSArray *sectionArray = [dictionary objectForKey:kSectionChildrenKey];
			NSMutableArray *children = [[NSMutableArray alloc] initWithCapacity:[sectionArray count]];
			for (NSDictionary *child in sectionArray) {
				Section *section = [[Section alloc] initWithDictionary:child];
				section.parent = self;
				[children addObject:section];
			}
			children_ = [NSArray arrayWithArray:children];
		}
	}
	return self;
}

- (void)dealloc
{
	book_ = nil;
	parent_ = nil;
}

@end
