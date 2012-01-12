//
//  SectionListViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "SectionListViewController.h"
#import "UIViewController+Section.h"
#import "SectionContentViewController.h"
#import "SearchViewController.h"
#import "Book.h"
#import "Section.h"
#import "SectionTableViewCell.h"
#import "Settings.h"
#import "SectionManager.h"

@implementation SectionListViewController
{
	UIView *headerView_;
}

@synthesize manager = manager_;
@synthesize sectionDataSource = sectionDataSource_;
@synthesize masterPopoverController = masterPopoverController_;

- (id)init
{
	self = [super initWithNibName:@"SectionListViewController" bundle:nil];
	if (self) {
		manager_ = nil;
		sectionDataSource_ = nil;
	}
	return self;
}

- (id)initWithSection:(Section *)section
		   dataSource:(NSArray *)data
	  siblingSections:(NSArray *)siblings
  currentSiblingIndex:(NSInteger)index
{
	self = [self init];
	if (self) {
		manager_ = [[SectionManager alloc] initWithSection:section siblings:siblings currentIndex:index];
		manager_.controller = self;
		sectionDataSource_ = data;
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
	
	if (self.manager.section == self.manager.section.book.mainSection) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"magnify_mini.png"]
																				  style:UIBarButtonItemStyleBordered
																				 target:self
																				 action:@selector(searchAction:)];
	}
	
	[self setToolbarItems:[self sectionToolbarItems] animated:NO];
	self.manager.prevItem = [self.toolbarItems objectAtIndex:kToolbarItemPosition2];
	self.manager.nextItem = [self.toolbarItems objectAtIndex:kToolbarItemPosition3];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self refresh];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	if ([self.manager.actionSheet isVisible]) {
		[self.manager.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
	}
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

#pragma mark - Custom Methods

- (void)refresh
{
	if ([self.manager.actionSheet isVisible]) {
		[self.manager.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
	}
	
	if (self.sectionDataSource == nil) {
		self.navigationController.toolbarHidden = YES;
	} else {
		self.navigationController.toolbarHidden = NO;
	}
	if (self.manager.section == nil) {
		self.title = @"Leyes Puerto Rico";
		self.navigationItem.rightBarButtonItem.enabled = NO;
	} else {
		self.title = self.manager.section.label;
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
	[self.manager checkItemsAndUpdateFavoriteIndex];
	[self.tableView reloadData];
}

#pragma mark - Selector Actions

- (void)searchAction:(id)sender
{
	SearchViewController *searchController = [[SearchViewController alloc] init];
	[self.navigationController pushViewController:searchController animated:YES];
}

- (void)homeAction:(id)sender
{
	[self goHome];
}

- (void)favoritesAction:(id)sender
{
	[self.manager showFavorites:sender];
}

- (void)optionsAction:(id)sender
{
	[self.manager showOptions:sender];
}

- (void)prevAction:(id)sender
{
	[self.manager showPrev];
}

- (void)nextAction:(id)sender
{
	[self.manager showNext];
}

#pragma mark - Section Selection Delegate Methods

- (void)sectionSelectionChanged:(Section *)section
					 dataSource:(NSArray *)data
				siblingSections:(NSArray *)siblings
			currentSiblingIndex:(NSInteger)index
{
	if (self.masterPopoverController) {
		[self.masterPopoverController dismissPopoverAnimated:YES];
	}
	
	self.sectionDataSource = data;
	self.manager.section = section;
	self.manager.siblings = siblings;
	self.manager.currentIndex = index;
	[self refresh];
}

- (void)refreshCurrentSection
{
	
}

- (void)clearCurrentSection
{
	[self goHomeAnimated:NO];
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
        cell = [[SectionTableViewCell alloc] initWithRLStyle:RLTableCellStyleSection reuseIdentifier:CellIdentifier];
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
		SectionContentViewController *contentController =
		[[SectionContentViewController alloc] initWithSection:section
											  siblingSections:self.sectionDataSource
										  currentSiblingIndex:indexPath.row];
		[self.navigationController pushViewController:contentController animated:YES];
	} else {
		SectionListViewController *sectionController =
		[[SectionListViewController alloc] initWithSection:section
												dataSource:section.children
										   siblingSections:self.sectionDataSource
									   currentSiblingIndex:indexPath.row];
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
	textLabel.text = self.manager.section.title;
	
	[headerView_ addSubview:textLabel];
	
	return headerView_;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 52.0;
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
