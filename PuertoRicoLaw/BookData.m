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
	for (NSString *string in booksArray) {
		NSString *dictionaryPath = [[NSBundle mainBundle] pathForResource:string ofType:@"plist"];
		NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:dictionaryPath];
		NSDictionary *bookDictionary = [dictionary objectForKey:kBookInfoKey];
		dictionary = nil;
		
		Book *defaultBook = [[Book alloc] initWithDictionary:bookDictionary];
		bookIndex = [self indexOfBook:defaultBook];
		
		if (bookIndex == -1) {
			[self.books addObject:defaultBook];
		} else {
			Book *currentBook = [self.books objectAtIndex:bookIndex];
			if ([defaultBook isNewComparedToBook:currentBook]) {
				[self.books replaceObjectAtIndex:bookIndex withObject:defaultBook];
				deletePathInDocumentDirectory(mainSectionFilenameForBookName(defaultBook.name));
			}
		}
	}
}

- (NSInteger)indexOfBook:(Book *)book
{
	NSInteger index = -1;
	for (NSInteger i = 0; i < [self.books count]; i++) {
		Book *currentBook = [self.books objectAtIndex:i];
		if ([currentBook isEqualToBook:book]) {
			index = i;
			break;
		}
	}
	return index;
}

- (NSInteger)indexOfBookInFavorites:(Book *)book
{
	NSInteger index = -1;
	for (NSInteger i = 0; i < [self.favoriteBooks count]; i++) {
		Book *favoriteBook = [self.favoriteBooks objectAtIndex:i];
		if ([favoriteBook isEqualToBook:book]) {
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
