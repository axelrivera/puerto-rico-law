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

static BookData *sharedBookData_ = nil;

@implementation BookData

@synthesize currentBook = currentBook_;
@synthesize books = books_;
@synthesize favoriteBooks = favoriteBooks_;
@synthesize favoritesSegmentedControlIndex = favoritesSegmentedControlIndex_;

- (id)init
{
	self = [super init];
	if (self) {
		currentBook_ = nil;
		books_ = [[NSMutableArray alloc] initWithCapacity:0];
		favoriteBooks_ = [[NSMutableArray alloc] initWithCapacity:0];
		favoritesSegmentedControlIndex_ = 0;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	// this needs to be [super initWithCoder:aDecoder] if the superclass implements NSCoding
	self = [super init];
	if (self) {
		//self.object = [decoder decodeObjectForKey:@"objectName"];
		NSArray *books = [decoder decodeObjectForKey:@"bookDataBooks"];
		self.books = [[NSMutableArray alloc] initWithArray:books];
		
		NSArray *favoriteBooks = [decoder decodeObjectForKey:@"bookDataFavoriteBooks"];
		self.favoriteBooks = [[NSMutableArray alloc] initWithArray:favoriteBooks];
		
		NSNumber *number = [decoder decodeObjectForKey:@"bookDataFavoritesSegmentControlIndex"];
		self.favoritesSegmentedControlIndex = [number integerValue];
		[self loadBooks];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// add [super encodeWithCoder:encoder] if the superclass implements NSCoding
	//[encoder encodeObject:object forKey:@"objectName"];
	[encoder encodeObject:self.books forKey:@"bookDataBooks"];
	[encoder encodeObject:self.favoriteBooks forKey:@"bookDataFavoriteBooks"];
	
	[encoder encodeObject:[NSNumber numberWithInteger:self.favoritesSegmentedControlIndex]
				   forKey:@"bookDataFavoritesSegmentControlIndex"];
}

- (void)loadBooks
{	
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:kBookListFileName ofType:@"plist"];
    
    // Read in the plist file
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
	NSArray *booksArray = [plistDictionary objectForKey:kBookListKey];
	
	NSInteger bookIndex;
	for (NSDictionary *dictionary in booksArray) {
		Book *dictionaryBook = [[Book alloc] initWithDictionary:dictionary];
		bookIndex = [self indexOfBookWithName:dictionaryBook.name];
		if (bookIndex == -1) {
			[self.books addObject:dictionaryBook];
		} else {
			Book *currentBook = [self.books objectAtIndex:bookIndex];
			if ([currentBook isOlderComparedToBook:dictionaryBook]) {
				[self.books replaceObjectAtIndex:bookIndex withObject:dictionaryBook];
				deletePathInDocumentDirectory(mainSectionPathForBookName(dictionaryBook.name));
			}
		}
	}
}

- (NSInteger)indexOfBookWithName:(NSString *)name
{
	NSInteger index = -1;
	for (NSInteger i = 0; i < [self.books count]; i++) {
		Book *book = [self.books objectAtIndex:i];
		if ([book.name isEqualToString:name]) {
			index = i;
			break;
		}
	}
	return index;
}

- (NSInteger)indexOfFavoriteBookWithName:(NSString *)name
{
	NSInteger index = -1;
	for (NSInteger i = 0; i < [self.favoriteBooks count]; i++) {
		Book *book = [self.favoriteBooks objectAtIndex:i];
		if ([book.name isEqualToString:name]) {
			index = i;
			break;
		}
	}
	return index;
}

#pragma mark - Singleton Code

+ (BookData *)sharedBookData
{
    if (sharedBookData_ == nil) {
        sharedBookData_ = [[super allocWithZone:NULL] init];
    }
    return sharedBookData_;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedBookData];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
