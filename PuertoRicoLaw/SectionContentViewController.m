//
//  SectionContentViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "SectionContentViewController.h"
#import "SectionListViewController.h"
#import "FavoritesViewController.h"
#import "Book.h"
#import "Section.h"
#import "Settings.h"
#import "NSString+Extras.h"

@interface SectionContentViewController (Private)

- (void)checkGoNextItem;
- (BOOL)canGoNext;
- (void)checkGoPrevItem;
- (BOOL)canGoPrev;
- (void)reloadContentWithParentSectionAtIndex:(NSInteger)index;
- (NSString *)htmlStringForSection;
- (NSString *)htmlStringForEmail;
- (NSString *)fileContentString;
- (void)displayComposerSheet;
- (NSArray *)toolbarItemsArray;
- (void)reloadControllerWithSection:(Section *)section;

@end

@implementation SectionContentViewController
{
	UIBarButtonItem *prevItem_;
	UIBarButtonItem *nextItem_;
	NSString *fileContentStr_;
	NSInteger favoriteIndex_;
}

@synthesize webView = webView_;
@synthesize section = section_;
@synthesize siblingSections = siblingSections_;
@synthesize currentSiblingSectionIndex = currentSiblingSectionIndex_;
@synthesize masterPopoverController = masterPopoverController_;

- (id)init
{
	self = [super initWithNibName:@"SectionContentViewController" bundle:nil];
	if (self) {
		siblingSections_ = nil;
		currentSiblingSectionIndex_ = 0;
		fileContentStr_ = nil;
	}
	return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"magnify_mini.png"]
																			  style:UIBarButtonItemStyleBordered
																			 target:self
																			 action:@selector(searchAction:)];
	
    [self setToolbarItems:[self toolbarItemsArray] animated:NO];
	prevItem_ = [self.toolbarItems objectAtIndex:kToolbarItemPosition2];
	nextItem_ = [self.toolbarItems objectAtIndex:kToolbarItemPosition3];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.webView = nil;
	prevItem_ = nil;
	nextItem_ = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.title = self.section.label;
	if (fileContentStr_ == nil) {
		fileContentStr_ = [self fileContentString];
		self.webView.scrollView.indicatorStyle = [[Settings sharedSettings] scrollViewIndicator];
		[self.webView loadHTMLString:[self htmlStringForSection] baseURL:nil];
	}
	[self checkGoNextItem];
	[self checkGoPrevItem];	
	favoriteIndex_ = [self.section.book unsignedIndexOfFavoritesWithMd5String:[self.section md5String]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (UIDeviceOrientationIsLandscape(interfaceOrientation) && ![Settings sharedSettings].landscapeMode) {
		return NO;
	}
	// Return YES for supported orientations
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

#pragma mark - Private Methods

- (void)checkGoNextItem
{
	if ([self canGoNext]) {
		nextItem_.enabled = YES;
		return;
	}
	nextItem_.enabled = NO;
}

- (BOOL)canGoNext
{
	if (self.currentSiblingSectionIndex < 0 || self.currentSiblingSectionIndex + 1 >= [self.siblingSections count]) {
		return NO;
	}
	return YES;
}

- (void)checkGoPrevItem
{
	if ([self canGoPrev]) {
		prevItem_.enabled = YES;
		return;
	}
	prevItem_.enabled = NO;
}

- (BOOL)canGoPrev
{
	if (self.currentSiblingSectionIndex < 0 || self.currentSiblingSectionIndex - 1 < 0) {
		return NO;
	}
	return YES;
}

- (void)reloadContentWithParentSectionAtIndex:(NSInteger)index
{
	Section *section = [self.siblingSections objectAtIndex:index];
	if (section.children != nil) {
		NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
		[viewControllers removeLastObject];
		SectionListViewController *sectionController = [[SectionListViewController alloc] init];
		sectionController.title = section.label;
		sectionController.section = section;
		sectionController.sectionDataSource = section.children;
		sectionController.siblingSections = self.siblingSections;
		sectionController.currentSiblingSectionIndex = index;
		[viewControllers addObject:sectionController];
		[self.navigationController setViewControllers:viewControllers];
		return;
	}
	self.title = section.label;
	self.section = section;
	fileContentStr_ = [self fileContentString];
	[self.webView loadHTMLString:[self htmlStringForSection] baseURL:nil];
	[self checkGoNextItem];
	[self checkGoPrevItem];
	favoriteIndex_ = [self.section.book unsignedIndexOfFavoritesWithMd5String:[self.section md5String]];
}

- (NSString *)fileContentString
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:self.section.contentFile ofType:@"html"];
	return [NSString stringWithContentsOfFile:filePath
									 encoding:NSUTF8StringEncoding
										error:NULL];
}

- (NSString *)htmlStringForSection
{
	return [NSString htmlStringWithTitle:self.section.title body:fileContentStr_];
}

- (NSString *)htmlStringForEmail
{
	NSString *contentStr = fileContentStr_;
	
	NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:0];
	Section *section = self.section;
	while (section != nil) {
		[sections addObject:section];
		section = section.parent;
	}
	
	NSMutableString *tmpStr = [[NSMutableString alloc] initWithString:@""];
	for (NSInteger i = [sections count] - 1; i >= 0; i--) {
		Section *currentSection = [sections objectAtIndex:i];
		if (i == [sections count] - 1) {
			[tmpStr appendFormat:@"<p><strong>%@</strong></p>", currentSection.title];
		} else {
			[tmpStr appendFormat:@"<p><strong>%@:</strong> %@</p>", currentSection.label, currentSection.title];
		}
	}
	
	NSString *headerStr = nil;
	if ([tmpStr length] > 0) {
		headerStr = [NSString stringWithFormat:@"<p>%@</p>", tmpStr];
	}
	
	NSString *aboutStr = @"<p>----------<br/>Esta información fue generada con el App Leyes de Puerto Rico para iPhone, "
	@"iPod touch y iPad. Para más información visite http://riveralabs.com</p>";
	
	return [NSString stringWithFormat:@"<html><body>%@%@%@</body></html>", headerStr, contentStr, aboutStr];
}

- (void)displayComposerSheet {
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	NSString *subjectStr = [NSString stringWithFormat:@"%@ [Leyes de Puerto Rico]", self.section.book.title];
	[picker setSubject:subjectStr];
	[picker setMessageBody:[self htmlStringForEmail] isHTML:YES];
	
	[self presentModalViewController:picker animated:YES];
}

- (NSArray *)toolbarItemsArray
{
	UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				  target:nil
																				  action:nil];
	
	UIBarButtonItem *homeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"house.png"]
																 style:UIBarButtonItemStylePlain
																target:self
																action:@selector(homeAction:)];
	
	
	UIBarButtonItem *prevItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_arrow.png"]
																 style:UIBarButtonItemStylePlain
																target:self
																action:@selector(prevAction:)];
	
	UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"right_arrow.png"]
																 style:UIBarButtonItemStylePlain
																target:self
																action:@selector(nextAction:)];
	
	UIBarButtonItem *favoritesItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star.png"]
																	  style:UIBarButtonItemStylePlain
																	 target:self
																	 action:@selector(favoritesAction:)];
	
	UIBarButtonItem *optionsItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																				 target:self
																				 action:@selector(optionsAction:)];
	
	return [NSArray arrayWithObjects:
			homeItem,
			flexibleItem,
			prevItem,
			flexibleItem,
			nextItem,
			flexibleItem,
			favoritesItem,
			flexibleItem,
			optionsItem,
			nil];
}

- (void)reloadControllerWithSection:(Section *)section
{
	NSMutableArray *reversedSections = [[NSMutableArray alloc] initWithCapacity:0];
	NSMutableArray *orderedSections = [[NSMutableArray alloc] initWithCapacity:0];
	
	Section *tmpSection = section;
	while (tmpSection != nil) {
		[reversedSections addObject:tmpSection];
		tmpSection = tmpSection.parent;
	}
	
	NSEnumerator *reverseEnumerator = [reversedSections reverseObjectEnumerator];
	id object;
	while (object = [reverseEnumerator nextObject]) {
		[orderedSections addObject:object];
	}
	
	NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:0];
	[viewControllers addObject:[self.navigationController.viewControllers objectAtIndex:0]];
	
	for (Section *mySection in orderedSections) {
		if (mySection.children == nil) {
			SectionContentViewController *contentController = [[SectionContentViewController alloc] init];
			contentController.section = mySection;
			contentController.siblingSections = mySection.parent.children;
			contentController.currentSiblingSectionIndex = [mySection indexPositionAtParent];
			[viewControllers addObject:contentController];
		} else {
			SectionListViewController *sectionController = [[SectionListViewController alloc] init];
			sectionController.title = mySection.label;
			sectionController.section = mySection;
			sectionController.sectionDataSource = mySection.children;
			sectionController.siblingSections = mySection.parent.children;
			sectionController.currentSiblingSectionIndex = [mySection indexPositionAtParent];
			[viewControllers addObject:sectionController];
		}
	}
	[self.navigationController setViewControllers:(NSArray *)viewControllers animated:YES];
}

#pragma mark - Selector Actions

- (void)searchAction:(id)sender
{
	
}

- (void)homeAction:(id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)favoritesAction:(id)sender
{
	FavoritesViewController *favoritesController = [[FavoritesViewController alloc] initWithFavoritesType:FavoritesTypeSection];
	favoritesController.delegate = self;
	favoritesController.favoritesDataSource = self.section.book.favorites;
	favoritesController.navigationItem.prompt = self.section.book.favoritesTitle;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:favoritesController];
	[self presentModalViewController:navigationController animated:YES];	
}

- (void)optionsAction:(id)sender
{
	NSString *favoriteStr = nil;
	if (favoriteIndex_ >= 0) {
		favoriteStr = kFavoriteContentRemoveTitle;
	} else {
		favoriteStr = kFavoriteContentAddTitle;
	}
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancelar"
											   destructiveButtonTitle:nil
													otherButtonTitles:favoriteStr, @"Enviar E-mail", nil];
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (void)prevAction:(id)sender
{
	if ([self canGoPrev]) {
		self.currentSiblingSectionIndex--;
		[self reloadContentWithParentSectionAtIndex:self.currentSiblingSectionIndex];
	}
}

- (void)nextAction:(id)sender
{
	if ([self canGoNext]) {
		self.currentSiblingSectionIndex++;
		[self reloadContentWithParentSectionAtIndex:self.currentSiblingSectionIndex];
	}
}

#pragma mark - UIWebView Delegate Methods

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
		[self reloadControllerWithSection:favoriteSection];
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
		if (favoriteIndex_ >= 0) {
			[self.section.book.favorites removeObjectAtIndex:favoriteIndex_];
			favoriteIndex_ = -1;
		} else {
			[self.section.book.favorites addObject:self.section];
			favoriteIndex_ = [self.section.book.favorites count] - 1;
		}
	} else if (buttonIndex == 1) {
		[self displayComposerSheet];
	}
}

#pragma mark - MFMailComposeViewController Delegate

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {	
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
	
	[self dismissModalViewControllerAnimated:YES];
	
	if (showAlert == YES) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"E-mail Error"
														message:errorString
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[alert show];
	}
}

#pragma mark Split View Delegate

- (void)splitViewController:(UISplitViewController *)splitController
	 willHideViewController:(UIViewController *)viewController
		  withBarButtonItem:(UIBarButtonItem *)barButtonItem
	   forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"Leyes Puerto Rico";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
	 willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
