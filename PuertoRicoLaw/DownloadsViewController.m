//
//  DownloadsViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 5/8/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import "DownloadsViewController.h"
#import "Settings.h"
#import "DownloadTableViewCell.h"
#import "BookData.h"

#define kSegmentedControlItemWidth 100.0

@interface DownloadsViewController (Private)

- (NSArray *)toolbarItemsArray;
- (NSArray *)segmentedControlTitles;

@end

@implementation DownloadsViewController
{
	UISegmentedControl *segmentedControl_;
	UIBarButtonItem *downloadButtonItem_;
	UIBarButtonItem *refreshButtonItem_;
}

@synthesize delegate = delegate_;
@synthesize dataSource = dataSource_;

- (id)init
{
	self = [super initWithNibName:@"DownloadsViewController" bundle:nil];
	if (self) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.contentSizeForViewInPopover = kMainPopoverSize;
		}
		self.title = @"Downloads";
		
		dataSource_ = [[NSMutableArray alloc] initWithCapacity:0];
		
		NSDictionary *dictionary = nil;
		
		dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
					  @"This is a long title because I want to see what happens when I have a very long title", @"title",
					  @"Subtitle 1", @"subtitle",
					  @"Instalar", @"button_title",
					  @"GRATIS", @"download_text",
					  nil];
		
		[dataSource_ addObject:dictionary];
		
		dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
					  @"Title 2", @"title",
					  @"Subtitle 2", @"subtitle",
					  @"Actualizar", @"button_title",
					  @"GRATIS", @"download_text",
					  nil];
		
		[dataSource_ addObject:dictionary];
		
		dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
					  @"Title 3", @"title",
					  @"Subtitle 3", @"subtitle",
					  @"Instalado", @"button_title",
					  @"GRATIS", @"download_text",
					  nil];
		
		[dataSource_ addObject:dictionary];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.navigationItem.hidesBackButton = YES;
	}
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK"
																			  style:UIBarButtonItemStyleDone
																			 target:self
																			 action:@selector(dismissAction:)];
	
	downloadButtonItem_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
																		target:self
																		action:@selector(downloadAllAction:)];
	
	refreshButtonItem_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																	   target:self
																	   action:@selector(refreshAction:)];
	
	segmentedControl_ = [[UISegmentedControl alloc] initWithItems:[self segmentedControlTitles]];
	segmentedControl_.segmentedControlStyle = UISegmentedControlStyleBar;
	for (NSInteger i = 0; i < [segmentedControl_ numberOfSegments]; i++) {
		[segmentedControl_ setWidth:kSegmentedControlItemWidth forSegmentAtIndex:i];
	}
	[segmentedControl_ addTarget:self
						  action:@selector(segmentedControlChangedIndex:)
				forControlEvents:UIControlEventValueChanged];
	
	self.navigationController.toolbarHidden = NO;
	[self setToolbarItems:[self toolbarItemsArray]];
	
	self.tableView.rowHeight = 64.0;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	downloadButtonItem_ = nil;
	refreshButtonItem_ = nil;
	segmentedControl_ = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	segmentedControl_.selectedSegmentIndex = [[BookData sharedBookData] downloadsSegmentedControlIndex];
	[self performSelector:@selector(segmentedControlChangedIndex:) withObject:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	self.modalInPopover = YES;
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

- (NSArray *)toolbarItemsArray
{
	UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				  target:nil
																				  action:nil];
	
	UIBarButtonItem *segmentedItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl_];
	
	NSArray *array = [NSArray arrayWithObjects:
					  flexibleItem,
					  refreshButtonItem_,
					  flexibleItem,
					  segmentedItem,
					  flexibleItem,
					  downloadButtonItem_,
					  flexibleItem,
					  nil];
	return array;
}

- (NSArray *)segmentedControlTitles
{
	return [NSArray arrayWithObjects:@"Instaladas", @"Tienda", nil];
}

#pragma mark - Selector Actions

- (void)segmentedControlChangedIndex:(id)sender
{
	[[BookData sharedBookData] setDownloadsSegmentedControlIndex:[segmentedControl_ selectedSegmentIndex]];
	NSLog(@"Segmented Control Action");
}

- (void)refreshAction:(id)sender
{
	
}

- (void)dismissAction:(id)sender
{
	[self.delegate downloadsViewControllerDidFinish:self];
}

- (void)downloadAllAction:(id)sender
{
	
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    DownloadTableViewCell *cell = (DownloadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[DownloadTableViewCell alloc] initWithReuseIdentifier:CellIdentifier];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	NSDictionary *dictionary = [self.dataSource objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [dictionary objectForKey:@"title"];
	cell.detailTextLabel.text = [dictionary objectForKey:@"subtitle"];
	
	[cell.downloadButton setTitle:[dictionary objectForKey:@"button_title"] forState:UIControlStateNormal];
	
	if (indexPath.row == 2) {
		cell.downloadButton.enabled = NO;
	}
	
	cell.downloadLabel.text = [dictionary objectForKey:@"download_text"];
    
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
