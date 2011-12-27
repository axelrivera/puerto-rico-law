//
//  FavoritesViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "FavoritesViewController.h"
#import "BookData.h"
#import "Book.h"
#import "Section.h"

@interface FavoritesViewController (Private)

- (void)setFavoritesDataSource;

@end

@implementation FavoritesViewController
{
	BookData *bookData_;
	NSMutableArray *favoritesDataSource_;
	UISegmentedControl *segmentedControl_;
}

- (id)init
{
	self = [super initWithNibName:@"FavoritesViewController" bundle:nil];
	if (self) {
		self.title = @"Favoritos";
		bookData_ = [BookData sharedBookData];
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
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Regresar"
																			 style:UIBarButtonItemStyleDone
																			target:self
																			action:@selector(dismissAction:)];
	
	NSArray *segmentedControlItems = [NSArray arrayWithObjects:@"Leyes", @"Contenido", nil];
	segmentedControl_ = [[UISegmentedControl alloc] initWithItems:segmentedControlItems];
	segmentedControl_.segmentedControlStyle = UISegmentedControlStyleBar;
	[segmentedControl_ setWidth:150.0 forSegmentAtIndex:0];
	[segmentedControl_ setWidth:150.0 forSegmentAtIndex:1];
	[segmentedControl_ addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventValueChanged];
	
	UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				  target:nil
																				  action:nil];
	UIBarButtonItem *segmentedItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl_];
	self.navigationController.toolbarHidden = NO;
	[self setToolbarItems:[NSArray arrayWithObjects:flexibleItem, segmentedItem, flexibleItem, nil]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	segmentedControl_ = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	segmentedControl_.selectedSegmentIndex = bookData_.favoritesSegmentedControlIndex;
	[self setFavoritesDataSource];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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

- (void)setFavoritesDataSource
{
	if (segmentedControl_.selectedSegmentIndex == 0) {
		favoritesDataSource_ = bookData_.favoriteBooks;
	} else {
		favoritesDataSource_ = bookData_.favoriteContent;
	}
}

#pragma mark - Selector Actions

- (void)dismissAction:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)controlAction:(id)sender
{
	bookData_.favoritesSegmentedControlIndex = segmentedControl_.selectedSegmentIndex;
	[self setFavoritesDataSource];
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [favoritesDataSource_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (segmentedControl_.selectedSegmentIndex == 0) {
		NSString *CellIdentifier = @"BookCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		
		Book *book = [favoritesDataSource_ objectAtIndex:indexPath.row];
		
		cell.textLabel.text = book.title;
		
		return cell;
	}
	
	NSString *CellIdentifier = @"ContentCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	Section *section = [[Section alloc] initWithData:[favoritesDataSource_ objectAtIndex:indexPath.row]];
	
	cell.textLabel.text = section.title;
	
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
