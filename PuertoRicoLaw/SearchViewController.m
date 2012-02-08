//
//  SearchViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 1/3/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import "SearchViewController.h"
#import "UIViewController+Section.h"
#import "Book.h"
#import "Section.h"
#import "BookData.h"
#import "SectionTableViewCell.h"
#import "SectionListViewController.h"
#import "SectionContentViewController.h"
#import "Settings.h"
#import "SectionManager.h"

@implementation SearchViewController
{
	BookData *bookData_;
}

@synthesize searchDataSource = searchDataSource_;

- (id)init
{
	self = [super initWithNibName:@"SearchViewController" bundle:nil];
	if (self) {
		bookData_ = [BookData sharedBookData];
		self.title = @"Buscar";
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
	self.searchDisplayController.searchBar.placeholder = [NSString stringWithFormat:@"Buscar en %@", bookData_.currentBook.title];
	self.searchDisplayController.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"Todo el Texto", @"Títulos", nil];
	[self setToolbarItems:[self searchToolbarItems] animated:NO];
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

#pragma mark - Selector Actions

- (void)homeAction:(id)sender
{
	[self goHome];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchDataSource count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SectionTableViewCell *cell = (SectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SectionTableViewCell alloc] initWithRLStyle:RLTableCellStyleSectionSubtitle reuseIdentifier:CellIdentifier];
    }
    
	Section *section = [self.searchDataSource objectAtIndex:indexPath.row];
	
	cell.textLabel.text = section.label;
	cell.subtextLabel.text = section.sublabel;
	cell.detailTextLabel.text = section.title;
	if (section.parent == nil) {
		cell.subtitleTextLabel.text = section.book.title;
	} else {
		cell.subtitleTextLabel.text = section.parent.title;
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Section *section = [self.searchDataSource objectAtIndex:indexPath.row];
	if (section.children == nil) {
		SectionContentViewController *contentController =
		[[SectionContentViewController alloc] initWithSection:section
											  siblingSections:nil
										  currentSiblingIndex:-1];
		contentController.manager.highlightString = self.searchDisplayController.searchBar.text;
		[self.navigationController pushViewController:contentController animated:YES];
	} else {
		SectionListViewController *sectionController =
		[[SectionListViewController alloc] initWithSection:section
												dataSource:section.children
										   siblingSections:nil
									   currentSiblingIndex:-1];
		[self.navigationController pushViewController:sectionController animated:YES];
	}

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80.0;
}

#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	BOOL titleOnly;
	if ([searchBar selectedScopeButtonIndex] == 0) {
		titleOnly = NO;
	} else {
		titleOnly = YES;
	}
	
	self.searchDataSource = [bookData_.currentBook searchMainSectionWithString:searchBar.text titleOnly:titleOnly];
	[self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - UISearchDisplayController Delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
	//self.searchDataSource = nil;
	//[controller.searchResultsTableView reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
	self.searchDataSource = nil;
	[tableView reloadData];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
	return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	return NO;
}



@end
