//
//  BookData.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "BookData.h"
#import "Book.h"
#import "FileHelpers.h"

@implementation BookData
{
	NSMutableArray *books_;
}

@synthesize currentBook = currentBook_;

- (id)init
{
	self = [super init];
	if (self) {
		books_ = [NSMutableArray arrayWithCapacity:0];
		[self loadBooks];
		currentBook_ = nil;
	}
	return self;
}

- (void)loadBooks
{
	if ([books_ count] > 0) {
		[self removeAllBooks];
	}
	
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:kBookListFileName ofType:@"plist"];
    
    // Read in the plist file
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
	NSArray *booksArray = [plistDictionary objectForKey:kBookListKey];
		
	for (NSDictionary *dictionary in booksArray) {
		Book *book = [[Book alloc] initWithDictionary:dictionary];
		[self addBook:book];
	}
}

- (void)addBook:(Book *)book
{
	NSAssert([book isKindOfClass:[Book class]], @"Object is not a book");
	[books_ addObject:book];
}

- (void)insertBook:(Book *)book atIndex:(NSInteger)index
{
	NSAssert([book isKindOfClass:[Book class]], @"Object is not a book");
	[books_ insertObject:book atIndex:index];
}

- (void)removeBookAtIndex:(NSInteger)index
{
	[books_ removeObjectAtIndex:index];
}

- (void)removeAllBooks
{
	[books_ removeAllObjects];
}

- (NSArray *)books
{
	return books_;
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
