//
//  SectionManager.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/31/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "SectionManager.h"
#import "Book.h"
#import "Section.h"
#import "SectionListViewController.h"
#import "SectionContentViewController.h"

@implementation SectionManager

@synthesize section = section_;
@synthesize siblings = siblings_;
@synthesize currentIndex = currentIndex_;
@synthesize favoriteIndex = favoriteIndex_;
@synthesize nextItem = nextItem_;
@synthesize prevItem = prevItem_;
@synthesize controller = controller_;

- (id)init
{
	self = [super init];
	if (self) {
		section_ = nil;
		siblings_ = nil;
		currentIndex_ = 0;
		nextItem_ = nil;
		prevItem_ = nil;
		controller_ = nil;
	}
	return self;
}

- (id)initWithSection:(Section *)section siblings:(NSArray *)siblings currentIndex:(NSInteger)currentIndex
{
	self = [self init];
	if (self) {
		section_ = section;
		siblings_ = siblings;
		currentIndex_ = currentIndex;
	}
	return self;
}

- (void)dealloc
{
	nextItem_ = nil;
	prevItem_ = nil;
	controller_ = nil;
}

#pragma mark - Custom Methods

- (void)reloadContentWithCurrentIndex
{	
	Section *section = [self.siblings objectAtIndex:self.currentIndex];
	if (section.children == nil) {
		NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:[[self.controller navigationController] viewControllers]];
		[viewControllers removeLastObject];
		SectionContentViewController *contentController =
		[[SectionContentViewController alloc] initWithSection:section
											  siblingSections:self.siblings
										  currentSiblingIndex:self.currentIndex];
		[viewControllers addObject:contentController];
		[[self.controller navigationController] setViewControllers:viewControllers];
		return;
	}
	[self.controller setTitle:section.label];
	[[self.controller manager] setSection:section];
	[self.controller setSectionDataSource:section.children];
	[[self.controller tableView] reloadData];
	[[self.controller tableView] setContentOffset:CGPointZero animated:NO];
	[[self.controller manager] checkItemsAndUpdateFavoriteIndex];
}

- (void)checkItemsAndUpdateFavoriteIndex
{
	[self checkGoNextItem];
	[self checkGoPrevItem];
	[self updateFavoriteIndex];
}

- (void)checkGoNextItem
{
	if ([self canGoNext]) {
		self.nextItem.enabled = YES;
		return;
	}
	self.nextItem.enabled = NO;
}

- (BOOL)canGoNext
{
	if (self.currentIndex < 0 || self.currentIndex + 1 >= [self.siblings count]) {
		return NO;
	}
	return YES;
}

- (void)checkGoPrevItem
{
	if ([self canGoPrev]) {
		self.prevItem.enabled = YES;
		return;
	}
	self.prevItem.enabled = NO;
}

- (BOOL)canGoPrev
{
	if (self.currentIndex < 0 || self.currentIndex - 1 < 0) {
		return NO;
	}
	return YES;
}

- (void)updateFavoriteIndex
{
	self.favoriteIndex = [self.section.book unsignedIndexOfFavoritesWithMd5String:[self.section md5String]];
}

- (void)addToFavorites
{
	[self.section.book.favorites addObject:self.section];
	self.favoriteIndex = [self.section.book.favorites count] - 1;
}

- (void)removeFromFavorites
{
	[self.section.book.favorites removeObjectAtIndex:self.favoriteIndex];
	self.favoriteIndex = -1;
}

@end
