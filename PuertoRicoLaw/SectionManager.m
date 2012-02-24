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
#import "BookDetailViewController.h"
#import "UIViewController+Section.h"

@interface SectionManager (Private)

- (void)displayComposerSheetTo:(NSArray *)toRecipients subject:(NSString *)subject body:(NSString *)body;

@end

@implementation SectionManager

@synthesize section = section_;
@synthesize siblings = siblings_;
@synthesize currentIndex = currentIndex_;
@synthesize favoriteIndex = favoriteIndex_;
@synthesize highlightString = highlightString_;
@synthesize nextItem = nextItem_;
@synthesize prevItem = prevItem_;
@synthesize actionSheet = actionSheet_;
@synthesize favoritesPopover = favoritesPopover_;
@synthesize detailsPopover = detailsPopover_;
@synthesize controller = controller_;

- (id)init
{
	self = [super init];
	if (self) {
		section_ = nil;
		siblings_ = nil;
		currentIndex_ = 0;
		favoriteIndex_ = -1;
		highlightString_ = nil;
		nextItem_ = nil;
		prevItem_ = nil;
		actionSheet_ = nil;
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
	[[self.controller manager] setSection:section];
	[self.controller setSectionDataSource:section.children];
	[self.controller refresh];
	[[self.controller tableView] setContentOffset:CGPointZero animated:NO];
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
	[[self.controller manager] setSection:section];
	[self.controller setContentStr:nil];
	[self.controller refresh];
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
	self.favoriteIndex = [self.section.book unsignedIndexOfSectionInFavorites:self.section];
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

- (void)showFavorites:(id)sender
{
	if ([self.favoritesPopover isPopoverVisible]) {
		//[self.favoritesPopover dismissPopoverAnimated:YES];
		return;
	}
	
	if ([self.detailsPopover isPopoverVisible]) {
		[self.detailsPopover dismissPopoverAnimated:NO];
	}
	
	if ([self.actionSheet isVisible]) {
		[self.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
	}
	
	FavoritesViewController *favoritesController = [[FavoritesViewController alloc] initWithFavoritesType:FavoritesTypeSection];
	favoritesController.delegate = self;
	favoritesController.favoritesDataSource = self.section.book.favorites;
	favoritesController.navigationItem.prompt = self.section.book.shortTitle;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:favoritesController];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.favoritesPopover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
		[self.favoritesPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else {
		[self.controller presentModalViewController:navigationController animated:YES];
	}
}

- (void)showNext
{
	if ([self.favoritesPopover isPopoverVisible] || [self.detailsPopover isPopoverVisible]) {
		return;
	}
	
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
	if ([self.favoritesPopover isPopoverVisible] || [self.detailsPopover isPopoverVisible]) {
		return;
	}
	
	if ([self canGoPrev]) {
		self.currentIndex--;
		if ([self.controller isKindOfClass:[SectionListViewController class]]) {
			[self reloadListWithCurrentIndex];
			return;
		}
		[self reloadContentWithCurrentIndex];
	}
}

- (void)showOptions:(id)sender
{
	if ([self.actionSheet isVisible]) {
		[self.actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
		return;
	}
	
	if ([self.detailsPopover isPopoverVisible]) {
		[self.detailsPopover dismissPopoverAnimated:NO];
	}

	if ([self.favoritesPopover isPopoverVisible]) {
		[self.favoritesPopover dismissPopoverAnimated:NO];
	}
	
	self.actionSheet = [[UIActionSheet alloc] init];
	self.actionSheet.delegate = self;
	
	NSString *favoriteStr = nil;
	if (self.favoriteIndex >= 0) {
		favoriteStr = kFavoriteContentRemoveTitle;
	} else {
		favoriteStr = kFavoriteContentAddTitle;
	}
	
	[self.actionSheet addButtonWithTitle:favoriteStr];
	
	if ([self.controller isKindOfClass:[SectionContentViewController class]]) {
		[self.actionSheet addButtonWithTitle:@"Enviar E-mail"];
		[self.actionSheet addButtonWithTitle:@"Reportar Error"];
	}
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.actionSheet showFromBarButtonItem:sender animated:NO];
	} else {
		[self.actionSheet addButtonWithTitle:@"Cancelar"];
		self.actionSheet.cancelButtonIndex = [self.actionSheet numberOfButtons] - 1;
		[self.actionSheet showFromToolbar:[[self.controller navigationController] toolbar]];
	}
}

- (void)showDetails:(id)sender
{
	if ([self.detailsPopover isPopoverVisible]) {
		return;
	}
	
	if ([self.actionSheet isVisible]) {
		[self.actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
	}
	
	if ([self.favoritesPopover isPopoverVisible]) {
		[self.favoritesPopover dismissPopoverAnimated:NO];
	}
	
	Book *book = self.section.book;
	
	NSString *dateStr = [NSString stringWithFormat:@"Actualizado: %@",
						 [[UIViewController dateFormatter] stringFromDate:book.lastUpdate]];
	
	BookDetailViewController *detailsController = [[BookDetailViewController alloc] initWithTitle:book.title
																					  description:book.bookDescription
																					   lastUpdate:dateStr
																							notes:book.bookNotes];
	detailsController.delegate = self;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:detailsController];
	self.detailsPopover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
	[self.detailsPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)resetSection
{
	self.section = nil;
	self.siblings = nil;
	self.currentIndex = 0;
}

#pragma mark - Private Methods

- (void)displayComposerSheetTo:(NSArray *)toRecipients subject:(NSString *)subject body:(NSString *)body
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	if (toRecipients) {
		[picker setToRecipients:toRecipients];
	}
	
	[picker setSubject:subject];
	[picker setMessageBody:body isHTML:YES];
	[self.controller presentModalViewController:picker animated:YES];
}

#pragma mark - UIViewController Delegate Methods

- (void)favoritesViewControllerDidFinish:(FavoritesViewController *)controller save:(BOOL)save
{
	Section *section = nil;
	if (save) {
		section = controller.selection;
	}
	if (section) {
		Section *favoriteSection = [self.section.book sectionInMainSectionMatchingSectionID:section.sectionID];
		[self.controller reloadControllerWithSection:favoriteSection];
	}
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.favoritesPopover dismissPopoverAnimated:YES];
	} else {
		[controller dismissModalViewControllerAnimated:YES];
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

- (void)detailsViewControllerDidFinish:(UIViewController *)controller
{
	[self.detailsPopover dismissPopoverAnimated:YES];
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
	} else {
		if ([self.controller isKindOfClass:[SectionContentViewController class]] && buttonIndex == 1) {
			NSString *subjectStr = [NSString stringWithFormat:@"Leyes Puerto Rico - %@ - %@",
									self.section.book.shortTitle,
									self.section.title];
			NSString *bodyStr = [self.controller htmlStringForEmail];
			[self displayComposerSheetTo:nil subject:subjectStr body:bodyStr];
		} else if ([self.controller isKindOfClass:[SectionContentViewController class]] && buttonIndex == 2) {
			NSString *subjectStr = [NSString stringWithFormat:@"Reportar Error - Leyes Puerto Rico"];
			NSString *htmlStr = [self.controller htmlStringForEmail];
			NSString *headerStr = 
			@"<br />---<br />He encontrado un error la siguiente sección del app "
			@"Leyes Puerto Rico y deseo reportarlo.<br />";
			NSString *bodyStr = [NSString stringWithFormat:@"%@%@", headerStr, htmlStr];
			NSArray *toRecipients = [NSArray arrayWithObject:@"apps@riveralabs.com"];
			[self displayComposerSheetTo:toRecipients subject:subjectStr body:bodyStr];
		}
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
