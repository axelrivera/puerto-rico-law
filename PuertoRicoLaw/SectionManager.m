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
#import "UIViewController+Section.h"
#import "SectionListViewController.h"
#import "SectionContentViewController.h"

@interface SectionManager (Private)

- (void)displayComposerSheet;

@end

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

- (void)reloadListWithCurrentIndex
{	
	Section *section = [self.siblings objectAtIndex:self.currentIndex];
	if (section.children == nil) {
		NSMutableArray *viewControllers = 
		[[NSMutableArray alloc] initWithArray:[[self.controller navigationController] viewControllers]];
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

- (void)reloadContentWithCurrentIndex
{
	Section *section = [self.siblings objectAtIndex:self.currentIndex];
	if (section.children != nil) {
		NSMutableArray *viewControllers =
		[[NSMutableArray alloc] initWithArray:[[self.controller navigationController] viewControllers]];
		[viewControllers removeLastObject];
		SectionListViewController *sectionController =
		[[SectionListViewController alloc] initWithSection:section
												dataSource:section.children
										   siblingSections:self.siblings
									   currentSiblingIndex:self.currentIndex];
		[viewControllers addObject:sectionController];
		[[self.controller navigationController] setViewControllers:viewControllers];
		return;
	}
	[self.controller setTitle:section.label];
	[[self.controller manager] setSection:section];
	[self.controller setFileContentStr:[self.controller fileContentString]];
	[[self.controller webView] loadHTMLString:[self.controller htmlStringForSection] baseURL:nil];
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

- (void)showFavorites
{
	FavoritesViewController *favoritesController = [[FavoritesViewController alloc] initWithFavoritesType:FavoritesTypeSection];
	favoritesController.delegate = self;
	favoritesController.favoritesDataSource = self.section.book.favorites;
	favoritesController.navigationItem.prompt = self.section.book.favoritesTitle;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:favoritesController];
	[self.controller presentModalViewController:navigationController animated:YES];
}

- (void)showNext
{
	if ([self canGoNext]) {
		self.currentIndex++;
		if ([self.controller isKindOfClass:[SectionListViewController class]]) {
			[self reloadListWithCurrentIndex];
			return;
		}
		[self reloadContentWithCurrentIndex];
	}
}

- (void)showPrev
{
	if ([self canGoPrev]) {
		self.currentIndex--;
		if ([self.controller isKindOfClass:[SectionListViewController class]]) {
			[self reloadListWithCurrentIndex];
			return;
		}
		[self reloadContentWithCurrentIndex];
	}
}

- (void)showOptions
{
	NSString *favoriteStr = nil;
	if (self.favoriteIndex >= 0) {
		favoriteStr = kFavoriteContentRemoveTitle;
	} else {
		favoriteStr = kFavoriteContentAddTitle;
	}
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancelar"
											   destructiveButtonTitle:nil
													otherButtonTitles:favoriteStr, @"Enviar E-mail", nil];
	[actionSheet showFromToolbar:[[self.controller navigationController] toolbar]];
}

#pragma mark - Private Methods

- (void)displayComposerSheet {
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	NSString *subjectStr = [NSString stringWithFormat:@"%@ [Leyes de Puerto Rico]", self.section.book.title];
	[picker setSubject:subjectStr];
		
	[picker setMessageBody:[self.controller htmlStringForEmail] isHTML:YES];
	
	[self.controller presentModalViewController:picker animated:YES];
}

#pragma mark - UIViewController Delegate Methods

- (void)favoritesViewControllerDidFinish:(FavoritesViewController *)controller save:(BOOL)save
{
	Section *section = nil;
	if (save) {
		section = controller.selection;
	}
	[controller dismissModalViewControllerAnimated:YES];
	if (section) {
		Section *favoriteSection = [self.section.book sectionInMainSectionMatchingMd5String:[section md5String]];
		[self.controller reloadControllerWithSection:favoriteSection];
	}
}

- (void)favoritesViewControllerDeleteDataSource:(FavoritesViewController *)controller
{
	[controller.favoritesDataSource removeAllObjects];
	[controller.tableView reloadData];
	[controller setEditing:NO animated:YES];
}

- (void)favoritesViewController:(FavoritesViewController *)controller deleteRowAtIndexPath:(NSIndexPath *)indexPath
{
	[controller.favoritesDataSource removeObjectAtIndex:indexPath.row];
	[controller.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	if ([controller.favoritesDataSource count] <= 0) {
		[controller setEditing:NO animated:YES];
	}
}

#pragma mark - UIActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		if (self.favoriteIndex >= 0) {
			[self removeFromFavorites];
		} else {
			[self addToFavorites];
		}
	} else if (buttonIndex == 1) {
		[self displayComposerSheet];
	}
}

#pragma mark - MFMailComposeViewController Delegate

// Dismisses the email composition interface when users tap Cancel or Send.
// Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError*)error
{	
	NSString *errorString = nil;
	
	BOOL showAlert = NO;
	// Notifies users about errors associated with the interface
	switch (result)  {
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
			errorString = [NSString stringWithFormat:@"E-mail failed: %@", 
						   [error localizedDescription]];
			showAlert = YES;
			break;
		default:
			errorString = [NSString stringWithFormat:@"E-mail was not sent: %@", 
						   [error localizedDescription]];
			showAlert = YES;
			break;
	}
	
	[self.controller dismissModalViewControllerAnimated:YES];
	
	if (showAlert == YES) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"E-mail Error"
														message:errorString
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[alert show];
	}
}

@end
