//
//  Section.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "Section.h"
#import "Book.h"
#import "NSString+Extras.h"

@implementation Section

@synthesize sectionID = sectionID_;
@synthesize title = title_;
@synthesize label = label_;
@synthesize sublabel = sublabel_;
@synthesize content = content_;
@synthesize children = children_;
@synthesize book = book_;
@synthesize parent = parent_;

- (id)initWithBook:(Book *)book
{
	self = [super init];
	if (self) {
		sectionID_ = [book.name lowercaseString];
		title_ = book.title;
		label_ = book.shortTitle;
		sublabel_ = nil;
		book_ = book;
		parent_	= nil;
		content_ = nil;
		children_ = nil;
	}
	return self;
}

- (id)initWithBook:(Book *)book andDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
		sectionID_ = [[dictionary objectForKey:kSectionIDKey] lowercaseString];
		title_ = [dictionary objectForKey:kSectionTitleKey];
		label_ = [dictionary objectForKey:kSectionLabelKey];
		book_ = book;
		parent_ = nil;
		children_ = nil;
		
		if ([dictionary objectForKey:kSectionSublabelKey]) {
			sublabel_ = [dictionary objectForKey:kSectionSublabelKey];
		}
		
		if ([dictionary objectForKey:kSectionContentKey]) {
			content_ = [dictionary objectForKey:kSectionContentKey];
		}
		
		if ([dictionary objectForKey:kSectionChildrenKey]) {
			NSArray *sectionArray = [dictionary objectForKey:kSectionChildrenKey];
			NSMutableArray *children = [[NSMutableArray alloc] initWithCapacity:[sectionArray count]];
			for (NSDictionary *child in sectionArray) {
				Section *section = [[Section alloc] initWithBook:book_ andDictionary:child];
				section.parent = self;
				[children addObject:section];
			}
			children_ = (NSArray *)children;
		}
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [self initWithBook:nil andDictionary:dictionary];
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];  // this needs to be [super initWithCoder:aDecoder] if the superclass implements NSCoding
	if (self) {
		//self.object = [decoder decodeObjectForKey:@"objectName"];
		self.sectionID = [decoder decodeObjectForKey:@"sectionSectionID"];
		self.title = [decoder decodeObjectForKey:@"sectionTitle"];
		self.label = [decoder decodeObjectForKey:@"sectionLabel"];
		self.sublabel = [decoder decodeObjectForKey:@"sectionSublabel"];
		self.book = [decoder decodeObjectForKey:@"sectionBook"];
		self.parent = [decoder decodeObjectForKey:@"sectionParent"];
		self.content = [decoder decodeObjectForKey:@"sectionContent"];
		self.children = [decoder decodeObjectForKey:@"sectionChildren"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// add [super encodeWithCoder:encoder] if the superclass implements NSCoding
	//[encoder encodeObject:object forKey:@"objectName"];
	[encoder encodeObject:self.sectionID forKey:@"sectionSectionID"];
	[encoder encodeObject:self.title forKey:@"sectionTitle"];
	[encoder encodeObject:self.label forKey:@"sectionLabel"];
	[encoder encodeObject:self.sublabel forKey:@"sectionSublabel"];
	[encoder encodeConditionalObject:self.book forKey:@"sectionBook"];
	[encoder encodeConditionalObject:self.parent forKey:@"sectionParent"];
	[encoder encodeObject:self.content forKey:@"sectionContent"];
	[encoder encodeObject:self.children forKey:@"sectionChildren"];
}

- (void)dealloc
{
	book_ = nil;
	parent_ = nil;
}

#pragma mark - Custom Methods

- (NSString *)asciiStringForContent
{
	NSData *data = [self.content dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	return string;
}

- (NSInteger)indexPositionAtParent
{
	if (self.parent == nil) {
		return -1;
	}
	
	NSInteger index = 0;
	for (NSInteger i = 0; i < [self.parent.children count]; i++) {
		Section *section = [self.parent.children objectAtIndex:i];
		if ([self.sectionID isEqualToString:section.sectionID]) {
			index = i;
			break;
		}
	}
	return index;
}

- (BOOL)isEqualToSection:(Section *)section
{
	return [self.sectionID caseInsensitiveCompare:section.sectionID] == NSOrderedSame;
}

#pragma mark - Parent Methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"Title: %@, Label: %@", self.title, self.label];
}

@end
