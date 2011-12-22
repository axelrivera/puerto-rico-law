//
//  BookViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "BookViewController.h"
#import "SectionListViewController.h"
#import "FavoritesViewController.h"
#import "SettingsViewController.h"
#import "BookData.h"
#import "Book.h"

@interface BookViewController (Private)

- (NSArray *)toolbarItemsArray;

@end

@implementation BookViewController
{
	BookData *bookData_;
	UIBarButtonItem *searchItem_;
	UIBarButtonItem *doneItem_;
}

- (id)init
{
	self = [super initWithNibName:@"BookViewController" bundle:nil];
	if (self) {
		bookData_ = [BookData sharedBookData];
		bookData_.currentBook = nil;
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
	self.navigationController.toolbarHidden = NO;
	[self setToolbarItems:[self toolbarItemsArray]];
	
	self.tableView.rowHeight = 48.0;
	
	searchItem_ = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"magnify_mini.png"]
												   style:UIBarButtonItemStyleBordered
												  target:self
												  action:@selector(searchAction:)];
	
	doneItem_ = [[UIBarButtonItem alloc] initWithTitle:@"Terminar"
												 style:UIBarButtonItemStyleDone
												target:self
												action:@selector(doneAction:)];
	[self setEditing:NO animated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	searchItem_ = nil;
	doneItem_ = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	self.title = @"Leyes de Puerto Rico";
	if (bookData_.currentBook != nil) {
		[bookData_.currentBook clearSections];
		bookData_.currentBook = nil;
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

#pragma mark - Private Methods

- (NSArray *)toolbarItemsArray
{
	UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				  target:nil
																				  action:nil];
	
	UIBarButtonItem *homeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"house.png"]
																 style:UIBarButtonItemStylePlain
																target:self
																action:@selector(homeAction:)];
	
	UIBarButtonItem *listItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"]
																	style:UIBarButtonItemStylePlain
																   target:self
																   action:@selector(doneAction:)];
	
	UIBarButtonItem *favoritesItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star.png"]
																 style:UIBarButtonItemStylePlain
																target:self
																action:@selector(favoritesAction:)];
	
	UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gears.png"]
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(settingsAction:)];
	
	return [NSArray arrayWithObjects:
			homeItem,
			flexibleItem,
			listItem,
			flexibleItem,
			favoritesItem,
			flexibleItem,
			settingsItem,
			nil];
}

#pragma mark - Parent Methods

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
	
	if (editing) {
		self.navigationItem.rightBarButtonItem = doneItem_;
	} else {
		self.navigationItem.rightBarButtonItem = searchItem_;
	}
	[self.tableView reloadData];
}

#pragma mark - Selector Actions

- (void)searchAction:(id)sender
{
	
}

- (void)doneAction:(id)sender
{
	[self setEditing:!self.isEditing animated:YES];
}

- (void)homeAction:(id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)favoritesAction:(id)sender
{
	FavoritesViewController *favoritesController = [[FavoritesViewController alloc] init];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:favoritesController];
	[self presentModalViewController:navigationController animated:YES];
}

- (void)settingsAction:(id)sender
{
	SettingsViewController *settingsController = [[SettingsViewController alloc] init];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsController];
	[self presentModalViewController:navigationController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [bookData_.books count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
	Book *book = [bookData_.books objectAtIndex:indexPath.row];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.textLabel.font = [UIFont systemFontOfSize:14.0];
	cell.textLabel.text = book.title;
	cell.detailTextLabel.text = book.bookDescription;
	
	if (tableView.editing) {
		cell.imageView.image = [UIImage imageNamed:@"star_cell.png"];
	} else {
		cell.imageView.image = nil;
	}
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	bookData_.currentBook = [bookData_.books objectAtIndex:indexPath.row];
	[bookData_.currentBook loadSections];
	
	SectionListViewController *sectionController = [[SectionListViewController alloc] init];
	sectionController.sectionTitle = bookData_.currentBook.shortName;
	sectionController.sectionDataSource = bookData_.currentBook.sections;
	self.title = kHomeNavigationLabel;
	[self.navigationController pushViewController:sectionController animated:YES];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
	  toIndexPath:(NSIndexPath *)destinationIndexPath
{
	Book *book = [bookData_.books objectAtIndex:sourceIndexPath.row];
    [bookData_ removeBookAtIndex:sourceIndexPath.row];
    [bookData_ insertBook:book atIndex:destinationIndexPath.row];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

@end
