//
//  SectionListViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "SectionListViewController.h"
#import "SectionContentViewController.h"
#import "Book.h"
#import "Section.h"
#import "SectionTableViewCell.h"
#import "Settings.h"

@interface SectionListViewController (Private)

- (void)checkGoNextItem;
- (BOOL)canGoNext;
- (void)checkGoPrevItem;
- (BOOL)canGoPrev;
- (void)reloadContentWithParentSectionAtIndex:(NSInteger)index;
- (NSArray *)toolbarItemsArray;
- (void)reloadControllerWithSection:(Section *)section;

@end

@implementation SectionListViewController
{
	UIView *headerView_;
	UIBarButtonItem *prevItem_;
	UIBarButtonItem *nextItem_;
	NSInteger favoriteIndex_;
}

@synthesize section = section_;
@synthesize sectionDataSource = sectionDataSource_;
@synthesize siblingSections = siblingSections_;
@synthesize currentSiblingSectionIndex = currentSiblingSectionIndex_;

- (id)init
{
	self = [super initWithNibName:@"SectionListViewController" bundle:nil];
	if (self) {
		currentSiblingSectionIndex_ = 0;
		siblingSections_ = nil;
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
	
	[self setToolbarItems:[self toolbarItemsArray]];
	prevItem_ = [self.toolbarItems objectAtIndex:kToolbarItemPosition2];
	nextItem_ = [self.toolbarItems objectAtIndex:kToolbarItemPosition3];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	prevItem_ = nil;
	nextItem_ = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	self.title = self.section.label;
	[self checkGoNextItem];
	[self checkGoPrevItem];
	favoriteIndex_ = [self.section.book unsignedIndexOfFavoritesWithMd5String:[self.section md5String]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
	if (section.children == nil) {
		NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
		[viewControllers removeLastObject];
		SectionContentViewController *contentController = [[SectionContentViewController alloc] init];
		contentController.section = section;
		contentController.siblingSections = self.siblingSections;
		contentController.currentSiblingSectionIndex = index;
		[viewControllers addObject:contentController];
		[self.navigationController setViewControllers:viewControllers];
		return;
	}
	self.title = section.label;
	self.section = section;
	self.sectionDataSource = section.children;
	[self.tableView reloadData];
	[self.tableView setContentOffset:CGPointZero animated:NO];
	[self checkGoNextItem];
	[self checkGoPrevItem];
	favoriteIndex_ = [self.section.book unsignedIndexOfFavoritesWithMd5String:[self.section md5String]];
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
													otherButtonTitles:favoriteStr, nil];
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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sectionDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SectionTableViewCell *cell = (SectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SectionTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
	
	Section *section = [self.sectionDataSource objectAtIndex:indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.textLabel.text = section.label;
	cell.detailTextLabel.text = section.title;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	Section *section = [self.sectionDataSource objectAtIndex:indexPath.row];
	if (section.children == nil) {
		SectionContentViewController *contentController = [[SectionContentViewController alloc] init];
		contentController.section = section;
		contentController.siblingSections = self.sectionDataSource;
		contentController.currentSiblingSectionIndex = indexPath.row;
		[self.navigationController pushViewController:contentController animated:YES];
	} else {
		SectionListViewController *sectionController = [[SectionListViewController alloc] init];
		sectionController.title = section.label;
		sectionController.section = section;
		sectionController.sectionDataSource = section.children;
		sectionController.siblingSections = self.sectionDataSource;
		sectionController.currentSiblingSectionIndex = indexPath.row;
		[self.navigationController pushViewController:sectionController animated:YES];
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	CGRect screenRect = [UIScreen mainScreen].bounds;
	CGRect headerFrame = CGRectMake(0.0, 0.0, screenRect.size.width, 52.0);
	CGRect labelFrame = CGRectMake(10.0, 0.0, screenRect.size.width - 20.0, headerFrame.size.height);
	
	headerView_ = [[UIView alloc] initWithFrame:headerFrame];
	headerView_.backgroundColor = [UIColor clearColor];
	
	UILabel *textLabel = [[UILabel alloc] initWithFrame:labelFrame];
	textLabel.font = [UIFont boldSystemFontOfSize:16.0];
	textLabel.backgroundColor = [UIColor clearColor];
	textLabel.textColor = [UIColor darkGrayColor];
	textLabel.textAlignment = UITextAlignmentCenter;
	textLabel.numberOfLines = 2.0;
	textLabel.lineBreakMode = UILineBreakModeTailTruncation;
	textLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
	textLabel.shadowColor = [UIColor whiteColor];
	textLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	textLabel.text = self.section.title;
	
	[headerView_ addSubview:textLabel];
	
	return headerView_;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 52.0;
}

#pragma mark - UIViewControllerDelegates

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
	}
}

@end
