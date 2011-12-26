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
@synthesize contentFile = contentFile_;
@synthesize children = children_;
@synthesize book = book_;
@synthesize parent = parent_;

- (id)initWithBook:(Book *)book
{
	self = [super init];
	if (self) {
		self.title = book.title;
		self.label = book.shortName;
		self.book = book;
		self.parent	= nil;
		self.contentFile = nil;
		self.children = nil;
	}
	return self;
}

- (id)initWithBook:(Book *)book andDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
		self.title = [dictionary objectForKey:kSectionTitleKey];
		self.label = [dictionary objectForKey:kSectionLabelKey];
		self.book = book;
		self.parent = nil;
		self.children = nil;
		
		if ([dictionary objectForKey:kSectionContentFileKey]) {
			self.contentFile = [dictionary objectForKey:kSectionContentFileKey];
		}
		
		if ([dictionary objectForKey:kSectionChildrenKey]) {
			NSArray *sectionArray = [dictionary objectForKey:kSectionChildrenKey];
			NSMutableArray *children = [[NSMutableArray alloc] initWithCapacity:[sectionArray count]];
			for (NSDictionary *child in sectionArray) {
				Section *section = [[Section alloc] initWithBook:self.book andDictionary:child];
				section.parent = self;
				[children addObject:section];
			}
			self.children = (NSArray *)children;
		}
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [self initWithBook:nil andDictionary:dictionary];
	return self;
}

- (void)dealloc
{
	book_ = nil;
	parent_ = nil;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Title: %@, Label: %@, Content File: %@", self.title, self.label, self.contentFile];
}

@end
