//
//  BookData.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "BookData.h"
#import "Book.h"
#import "Section.h"
#import "FileHelpers.h"

@implementation BookData

@synthesize currentBook = currentBook_;
@synthesize books = books_;
@synthesize favoriteBooks = favoriteBooks_;
@synthesize favoriteContent = favoriteContent_;
@synthesize favoritesSegmentedControlIndex = favoritesSegmentedControlIndex_;

- (id)init
{
	self = [super init];
	if (self) {
		currentBook_ = nil;
		books_ = [[NSMutableArray alloc] initWithCapacity:0];
		favoriteBooks_ = [[NSMutableArray alloc] initWithCapacity:0];
		favoriteContent_ = [[NSMutableArray alloc] initWithCapacity:0];
		favoritesSegmentedControlIndex_ = 0;
		[self loadBooks];
	}
	return self;
}

- (void)loadBooks
{
	if ([self.books count] > 0) {
		[self.books removeAllObjects];
	}
	
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:kBookListFileName ofType:@"plist"];
    
    // Read in the plist file
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
	NSArray *booksArray = [plistDictionary objectForKey:kBookListKey];
		
	for (NSDictionary *dictionary in booksArray) {
		Book *book = [[Book alloc] initWithDictionary:dictionary];
		[self.books addObject:book];
	}
}

- (NSInteger)unsignedIndexOfFavoriteContentWithMd5String:(NSString *)string
{
	NSInteger index = -1;
	for (NSInteger i = 0; i < [self.favoriteContent count]; i++) {
		Section *section = [[Section alloc] initWithData:[self.favoriteContent objectAtIndex:i]];
		if ([[section md5String] isEqualToString:string]) {
			index = i;
			break;
		}
	}
	return index;
}

#pragma mark - Singleton Code

+ (id)sharedBookData
{
	static dispatch_once_t pred = 0;
	__strong static id _sharedObject = nil;
	dispatch_once(&pred, ^{
		_sharedObject = [[self alloc] init]; // or some other init method
	});
	return _sharedObject;
}

@end
