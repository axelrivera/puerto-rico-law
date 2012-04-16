//
//  BookViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "BookViewController.h"
#import "SectionListViewController.h"
#import "SectionContentViewController.h"
#import "SettingsViewController.h"
#import "BookData.h"
#import "Book.h"
#import "BookTableView.h"
#import "BookTableViewCell.h"
#import "Section.h"
#import "Settings.h"
#import "UIViewController+Section.h"

@interface BookViewController (Private)

- (void)loadBook:(Book *)book animated:(BOOL)animated;
- (NSArray *)toolbarItemsArray;

@end

@implementation BookViewController
{
	BookData *bookData_;
	UIBarButtonItem *searchItem_;
	UIBarButtonItem *doneItem_;
}

@synthesize delegate = delegate_;

- (id)init
{
	self = [super initWithNibName:@"BookViewController" bundle:nil];
	if (self) {
		delegate_ = nil;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.contentSizeForViewInPopover = kMainPopoverSize;
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

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:kUpdateBooksNotification
												  object:nil];
	
	self.delegate = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleBookUpdate:)
												 name:kUpdateBooksNotification
											   object:nil];
	
	self.clearsSelectionOnViewWillAppear = YES;
	
	[self setToolbarItems:[self toolbarItemsArray]];
	
	self.tableView.allowsSelectionDuringEditing = YES;
	self.tableView.rowHeight = 76.0;
	
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
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:kUpdateBooksNotification
												  object:nil];
	
	searchItem_ = nil;
	doneItem_ = nil;
	self.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	self.navigationController.toolbarHidden = NO;
	
	self.title = @"Leyes Puerto Rico";
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && bookData_.currentBook != nil) {
		[bookData_.currentBook clearSections];
		bookData_.currentBook = nil;
	}
	[self.tableView reloadData];
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

#pragma mark - Custom Methods

- (void)handleBookUpdate:(id)notification
{
	NSLog(@"I received a notification to update books");
	bookData_.currentBook = nil;
	[self.tableView reloadData];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.delegate resetCurrentSection];
		[self.delegate clearCurrentSection];
	}
}

#pragma mark - Private Methods

- (void)loadBook:(Book *)book animated:(BOOL)animated
{
	[bookData_.currentBook clearSections];
	bookData_.currentBook = book;
	[bookData_.currentBook loadSections];
	
	Section *section = bookData_.currentBook.mainSection;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.delegate sectionSelectionChanged:section dataSource:section.children siblingSections:nil currentSiblingIndex:-1];
	} else {
		SectionListViewController *sectionController =
		[[SectionListViewController alloc] initWithSection:section
												dataSource:section.children
										   siblingSections:nil
									   currentSiblingIndex:0];
		self.title = kHomeNavigationLabel;
		[self.navigationController pushViewController:sectionController animated:animated];
	}
}

- (NSArray *)toolbarItemsArray
{
	UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				  target:nil
																				  action:nil];
	
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
			listItem,
			flexibleItem,
			favoritesItem,
			flexibleItem,
			settingsItem,
			nil];;
}

#pragma mark - Selector Actions

- (void)reorderAction:(id)sender
{
	[self setEditing:!self.isEditing animated:YES];
}

- (void)favoritesAction:(id)sender
{
	[self setEditing:NO animated:YES];
	FavoritesViewController *favoritesController = [[FavoritesViewController alloc] initWithFavoritesType:FavoritesTypeBook];
	favoritesController.delegate = self;
	favoritesController.favoritesDataSource = bookData_.favoriteBooks;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:favoritesController];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.navigationController pushViewController:favoritesController animated:YES];
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
		[self.navigationController pushViewController:settingsController animated:YES];
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
	
	NSInteger favoriteIndex = [bookData_ indexOfBookInFavorites:book];
	
	BOOL isFavorite = NO;
	
	if (favoriteIndex >= 0) {
		isFavorite = YES;
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.showsReorderControl = YES;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	
	cell.bookTableView.textLabel.text = book.title;
	cell.bookTableView.detailTextLabel.text = book.bookDescription;
	cell.bookTableView.favorite = isFavorite;
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	
	Book *book = [bookData_.books objectAtIndex:indexPath.row];
	
	if (!tableView.isEditing) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			if ([bookData_.currentBook isEqualToBook:book]) {
				return;
			}
			[self.delegate resetCurrentSection];
		}
		[self loadBook:book animated:YES];
		return;
	}

	BookTableViewCell *cell = (BookTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	if (cell.bookTableView.isFavorite) {
		cell.bookTableView.favorite = NO;
		NSInteger index = [bookData_ indexOfBookInFavorites:book];
		if (index >= 0) {
			[bookData_.favoriteBooks removeObjectAtIndex:index];
		}
	} else {
		cell.bookTableView.favorite = YES;
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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	Book *book = [[bookData_ books] objectAtIndex:indexPath.row];
	
	NSString *dateStr = [NSString stringWithFormat:@"Actualizado: %@",
						 [[UIViewController dateFormatter] stringFromDate:book.lastUpdate]];
	
	BookDetailViewController *controller = [[BookDetailViewController alloc] initWithTitle:book.title
																			   description:book.bookDescription
																				lastUpdate:dateStr
																					 notes:book.bookNotes];
	controller.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	
	[self.navigationController presentModalViewController:navController animated:YES];
}

#pragma mark - UIViewController Delegates

- (void)favoritesViewControllerDidFinish:(FavoritesViewController *)controller save:(BOOL)save
{
	Book *book = nil;
	if (save) {
		book = controller.selection;
	}
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		[self dismissModalViewControllerAnimated:YES];
	}
	
	if (book) {
		[self loadBook:book animated:NO];
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
	[self dismissModalViewControllerAnimated:YES];
}

- (void)settingsViewControllerDidFinish:(UIViewController *)controller
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		id rightController = [[self.splitViewController.viewControllers objectAtIndex:1] visibleViewController];
		if ([rightController isKindOfClass:[SectionContentViewController class]]) {
			[rightController setContentStr:nil];
			[rightController refresh];
		}
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		[self dismissModalViewControllerAnimated:YES];
	}
}

@end
