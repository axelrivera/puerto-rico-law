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
#import "FavoritesSectionTableViewCell.h"
#import "BookTableView.h"

@interface FavoritesViewController (Private)

@property (assign, readwrite, nonatomic) FavoritesType favoritesType;

@end

@implementation FavoritesViewController

@synthesize favoritesDataSource = favoritesDataSource_;
@synthesize favoritesType = favoritesType_;

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
	
	self.title = @"Favoritos";
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Regresar"
																			 style:UIBarButtonItemStyleDone
																			target:self
																			action:@selector(dismissAction:)];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"trash_mini.png"]
																			  style:UIBarButtonItemStyleBordered
																			 target:self
																			 action:@selector(deleteAction:)];
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

#pragma mark - Selector Actions

- (void)dismissAction:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)deleteAction:(id)sender
{
	
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.favoritesDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.favoritesType == FavoritesTypeBook) {
		NSString *CellIdentifier = [NSString stringWithFormat:@"BookCell%d", indexPath.row];
		
		BookTableViewCell *cell = (BookTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[BookTableViewCell alloc] initWithReuseIdentifier:CellIdentifier];
			BookTableView *bookTableView = [[BookTableView alloc] initWithFrame:CGRectZero];
			[cell saveBookTableView:bookTableView];
		}
		
		Book *book = [self.favoritesDataSource objectAtIndex:indexPath.row];
		
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.showsReorderControl = NO;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		cell.bookTableView.textLabel.text = book.title;
		cell.bookTableView.detailTextLabel.text = book.bookDescription;
		cell.bookTableView.favorite = book.favorite;
		
		return cell;

	}
	
	NSString *CellIdentifier = @"ContentCell";
	
	FavoritesSectionTableViewCell *cell = (FavoritesSectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[FavoritesSectionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
	
	Section *section = [self.favoritesDataSource objectAtIndex:indexPath.row];
	
	cell.textLabel.text = section.title;
	cell.detailTextLabel.text = section.label;
	
	return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
