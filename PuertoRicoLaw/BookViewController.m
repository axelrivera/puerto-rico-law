//
//  BookViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "BookViewController.h"
#import "SectionListViewController.h"
#import "SettingsViewController.h"
#import "BookData.h"
#import "Book.h"
#import "BookTableView.h"
#import "BookTableViewCell.h"
#import "Section.h"
#import "Settings.h"

@interface BookViewController (Private)

- (void)loadBook:(Book *)book;
- (NSArray *)toolbarItemsArray;

@end

@implementation BookViewController
{
	BookData *bookData_;
	UIBarButtonItem *searchItem_;
	UIBarButtonItem *doneItem_;
	UIPopoverController *favoritesPopover_;
	UIPopoverController *settingsPopover_;
}

- (id)init
{
	self = [super initWithNibName:@"BookViewController" bundle:nil];
	if (self) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
		}
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
	
	self.tableView.allowsSelectionDuringEditing = YES;
	self.tableView.rowHeight = 64.0;
	
	doneItem_ = [[UIBarButtonItem alloc] initWithTitle:@"OK"
												 style:UIBarButtonItemStyleDone
												target:self
												action:@selector(reorderAction:)];
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
	self.title = @"Leyes Puerto Rico";
	if (bookData_.currentBook != nil) {
		[bookData_.currentBook clearSections];
		bookData_.currentBook = nil;
	}
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (favoritesPopover_ != nil) {
			[favoritesPopover_ dismissPopoverAnimated:YES];
			favoritesPopover_ = nil;
		}
		
		if (settingsPopover_ != nil) {
			[settingsPopover_ dismissPopoverAnimated:YES];
			settingsPopover_ = nil;
		}
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

#pragma mark - Private Methods

- (void)loadBook:(Book *)book
{
	bookData_.currentBook = book;
	[bookData_.currentBook loadSections];
	
	Section *section = bookData_.currentBook.mainSection;
	SectionListViewController *sectionController =
	[[SectionListViewController alloc] initWithSection:section
											dataSource:section.children
									   siblingSections:nil
								   currentSiblingIndex:0];
	self.title = kHomeNavigationLabel;
	[self.navigationController pushViewController:sectionController animated:YES];
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
	
	UIBarButtonItem *listItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"]
																	style:UIBarButtonItemStylePlain
																   target:self
																   action:@selector(reorderAction:)];
	
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

#pragma mark - Selector Actions

- (void)reorderAction:(id)sender
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (favoritesPopover_ != nil) {
			[favoritesPopover_ dismissPopoverAnimated:YES];
			favoritesPopover_ = nil;
		}
		
		if (settingsPopover_ != nil) {
			[settingsPopover_ dismissPopoverAnimated:YES];
			settingsPopover_ = nil;
		}
	}
	[self setEditing:!self.isEditing animated:YES];
}

- (void)homeAction:(id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)favoritesAction:(id)sender
{
	[self setEditing:NO animated:YES];
	FavoritesViewController *favoritesController = [[FavoritesViewController alloc] initWithFavoritesType:FavoritesTypeBook];
	favoritesController.delegate = self;
	favoritesController.favoritesDataSource = bookData_.favoriteBooks;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:favoritesController];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (settingsPopover_ != nil) {
			[settingsPopover_ dismissPopoverAnimated:YES];
			settingsPopover_ = nil;
		}
		if (favoritesPopover_ == nil) {
			favoritesPopover_ = [[UIPopoverController alloc] initWithContentViewController:navigationController];
		}
		[favoritesPopover_ presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else {
		[self presentModalViewController:navigationController animated:YES];
	}
}

- (void)settingsAction:(id)sender
{
	[self setEditing:NO animated:YES];
	SettingsViewController *settingsController = [[SettingsViewController alloc] init];
	settingsController.delegate = self;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsController];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (favoritesPopover_ != nil) {
			[favoritesPopover_ dismissPopoverAnimated:YES];
			favoritesPopover_ = nil;
		}
		
		if (settingsPopover_ == nil) {
			settingsPopover_ = [[UIPopoverController alloc] initWithContentViewController:navigationController];
		}
		[settingsPopover_ presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else {
		[self presentModalViewController:navigationController animated:YES];
	}
}

#pragma mark - Parent Methods

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
	
	if (editing) {
		self.navigationItem.rightBarButtonItem = doneItem_;
	} else {
		self.navigationItem.rightBarButtonItem = nil;
	}
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [bookData_.books count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.row];
    
    BookTableViewCell *cell = (BookTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BookTableViewCell alloc] initWithReuseIdentifier:CellIdentifier];
		BookTableView *bookTableView = [[BookTableView alloc] initWithFrame:CGRectZero];
		[cell saveBookTableView:bookTableView];
    }
    
	Book *book = [bookData_.books objectAtIndex:indexPath.row];
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.showsReorderControl = YES;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.bookTableView.textLabel.text = book.title;
	cell.bookTableView.detailTextLabel.text = book.bookDescription;
	cell.bookTableView.favorite = book.favorite;
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	Book *book = [bookData_.books objectAtIndex:indexPath.row];
	
	if (!tableView.isEditing) {
		[self loadBook:book];
		return;
	}

	BookTableViewCell *cell = (BookTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	if (cell.bookTableView.isFavorite) {
		cell.bookTableView.favorite = book.favorite = NO;
		NSInteger index = [bookData_ unsignedIndexOfFavoriteBookWithMd5String:[book md5String]];
		if (index >= 0) {
			[bookData_.favoriteBooks removeObjectAtIndex:index];
		}
	} else {
		cell.bookTableView.favorite = book.favorite = YES;
		[bookData_.favoriteBooks addObject:book];
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
	  toIndexPath:(NSIndexPath *)destinationIndexPath
{
	Book *book = [bookData_.books objectAtIndex:sourceIndexPath.row];
    [bookData_.books removeObjectAtIndex:sourceIndexPath.row];
    [bookData_.books insertObject:book atIndex:destinationIndexPath.row];
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

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

#pragma mark - UIViewController Delegates

- (void)favoritesViewControllerDidFinish:(FavoritesViewController *)controller save:(BOOL)save
{
	Book *book = nil;
	if (save) {
		book = controller.selection;
	}
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[favoritesPopover_ dismissPopoverAnimated:YES];
		favoritesPopover_ = nil;
	} else {
		[self dismissModalViewControllerAnimated:YES];
	}
	
	if (book) {
		[self loadBook:book];
	}
}

- (void)favoritesViewControllerDeleteDataSource:(FavoritesViewController *)controller
{
	for (Book *book in controller.favoritesDataSource) {
		book.favorite = NO;
	}
	[controller.favoritesDataSource removeAllObjects];
	[controller.tableView reloadData];
	[controller setEditing:NO animated:YES];
}

- (void)favoritesViewController:(FavoritesViewController *)controller deleteRowAtIndexPath:(NSIndexPath *)indexPath
{
	Book *book = [controller.favoritesDataSource objectAtIndex:indexPath.row];
	book.favorite = NO;
	[controller.favoritesDataSource removeObjectAtIndex:indexPath.row];
	[controller.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	if ([controller.favoritesDataSource count] <= 0) {
		[controller setEditing:NO animated:YES];
	}
}

- (void)settingsViewControllerDidFinish:(UIViewController *)controller
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[settingsPopover_ dismissPopoverAnimated:YES];
		settingsPopover_ = nil;
	} else {
		[self dismissModalViewControllerAnimated:YES];
	}
}

@end
