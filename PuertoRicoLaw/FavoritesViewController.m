//
//  FavoritesViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "FavoritesViewController.h"
#import "Book.h"
#import "Section.h"
#import "BookTableViewCell.h"
#import "BookTableView.h"

@interface FavoritesViewController (Private)

@property (assign, readwrite, nonatomic) FavoritesType favoritesType;

- (void)deleteAction:(id)sender;

@end

@implementation FavoritesViewController

@synthesize delegate = delegate_;
@synthesize favoritesDataSource = favoritesDataSource_;
@synthesize favoritesType = favoritesType_;
@synthesize selection = selection_;

- (id)init
{
	self = [self initWithFavoritesType:FavoritesTypeBook];
	return self;
}

- (id)initWithFavoritesType:(FavoritesType)type
{
	self = [super initWithNibName:@"FavoritesViewController" bundle:nil];
	if (self) {
		favoritesType_ = type;
		selection_ = nil;
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
	self.tableView.rowHeight = 64.0;
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
	[self setEditing:NO animated:NO];
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

#pragma mark - Custom Methods


#pragma mark - Selector Actions

- (void)dismissAction:(id)sender
{
	[self.delegate favoritesViewControllerDidFinish:self save:NO];
}

- (void)editingAction:(id)sender
{
	[self setEditing:YES animated:YES];
}

- (void)doneEditingAction:(id)sender
{
	[self setEditing:NO animated:YES];
}

- (void)deleteOptionsAction:(id)sender
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancelar"
											   destructiveButtonTitle:@"Borrar Todos"
													otherButtonTitles:nil];
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (void)deleteAction:(id)sender
{
	[self.delegate favoritesViewControllerDeleteDataSource:self];
}

#pragma mark - Parent Methods

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
	
	if (editing) {
		self.title = @"Editar Favoritos";
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK"
																				 style:UIBarButtonItemStyleDone
																				target:self
																				action:@selector(doneEditingAction:)];
		self.navigationItem.leftBarButtonItem.enabled = YES;
		self.navigationItem.rightBarButtonItem = nil;
		
		self.navigationController.toolbarHidden = NO;
		UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																					  target:nil
																					  action:nil];
		UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"Borrar Todos"
																	   style:UIBarButtonItemStyleBordered
																	  target:self
																	  action:@selector(deleteOptionsAction:)];
		[self setToolbarItems:[NSArray arrayWithObjects:flexibleItem, deleteItem, nil] animated:YES];
		
	} else {
		self.title = @"Favoritos";
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Editar"
																				 style:UIBarButtonItemStyleBordered
																				target:self
																				action:@selector(editingAction:)];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem  alloc] initWithTitle:@"OK"
																				   style:UIBarButtonItemStyleDone
																				  target:self
																				  action:@selector(dismissAction:)];
		if ([self.favoritesDataSource count] > 0) {
			self.navigationItem.leftBarButtonItem.enabled = YES;
		} else {
			self.navigationItem.leftBarButtonItem.enabled = NO;
		}
		
		self.navigationController.toolbarHidden = YES;
		self.toolbarItems = nil;
	}
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.favoritesDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *CellIdentifier = [NSString stringWithFormat:@"BookCell%d", indexPath.row];
	
	BookTableViewCell *cell = (BookTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[BookTableViewCell alloc] initWithReuseIdentifier:CellIdentifier];
		BookTableView *bookTableView = [[BookTableView alloc] initWithFrame:CGRectZero];
		[cell saveBookTableView:bookTableView];
	}
	
	NSString *textStr = nil;
	NSString *detailTextStr = nil;
	BOOL favorite = YES;
	
	if (self.favoritesType == FavoritesTypeBook) {
		Book *book = [self.favoritesDataSource objectAtIndex:indexPath.row];
		textStr = book.title;
		detailTextStr = book.bookDescription;
		favorite = book.favorite;
	} else {
		Section *section = [self.favoritesDataSource objectAtIndex:indexPath.row];
		textStr = section.title;
		detailTextStr = section.label;
		favorite = YES;
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.showsReorderControl = NO;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	cell.bookTableView.textLabel.text = textStr;
	cell.bookTableView.detailTextLabel.text = detailTextStr;
	cell.bookTableView.favorite = favorite;
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selection = [self.favoritesDataSource objectAtIndex:indexPath.row];
	[self.delegate favoritesViewControllerDidFinish:self save:YES];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
	  toIndexPath:(NSIndexPath *)destinationIndexPath
{	
	id object = [self.favoritesDataSource objectAtIndex:sourceIndexPath.row];
	[self.favoritesDataSource removeObjectAtIndex:sourceIndexPath.row];
	[self.favoritesDataSource insertObject:object atIndex:destinationIndexPath.row];
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// If the table view is asking to commit a delete command...
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// the delegate should remove the object from the data source
		[self.delegate favoritesViewController:self deleteRowAtIndexPath:indexPath];
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

#pragma mark - UIActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		[self deleteAction:actionSheet];
	}
}

@end
