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
#import "RLBackgroundStatusView.h"
#import "APIBook.h"
#import "NSDateFormatter+Book.h"
#import "MBProgressHUD.h"

#define kSegmentedControlItemWidth 100.0

@interface DownloadsViewController (Private)

- (NSArray *)toolbarItemsArray;
- (NSArray *)segmentedControlTitles;
- (void)checkEmptyView;

@end

@implementation DownloadsViewController
{
	RLBackgroundStatusView *backgroundLoadingView_;
	RLBackgroundStatusView *backgroundEmptyView_;
	UISegmentedControl *segmentedControl_;
	UIBarButtonItem *downloadButtonItem_;
	UIBarButtonItem *refreshButtonItem_;
	MBProgressHUD *HUD_;
}

@synthesize delegate = delegate_;
@synthesize downloadsTableView = downloadsTableView_;
@synthesize dataSource = dataSource_;

- (id)init
{
	self = [super initWithNibName:@"DownloadsViewController" bundle:nil];
	if (self) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.contentSizeForViewInPopover = kMainPopoverSize;
		}
	}
	return self;
}

- (void)dealloc
{
	self.downloadsTableView = nil;
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
	
	self.downloadsTableView.rowHeight = 64.0;
	
	backgroundLoadingView_ = [[RLBackgroundStatusView alloc] init];
	[backgroundLoadingView_ setTitle:@"Loading..." indicator:YES];
	[self.view addSubview:backgroundLoadingView_];
	
	backgroundEmptyView_ = [[RLBackgroundStatusView alloc] init];
	[self.view addSubview:backgroundEmptyView_];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loadBooksNotificationAction:)
												 name:BookManagerDidLoadBooksNotification
											   object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:BookManagerDidLoadBooksNotification object:nil];
	
	backgroundLoadingView_ = nil;
	backgroundEmptyView_ = nil;
	downloadButtonItem_ = nil;
	refreshButtonItem_ = nil;
	segmentedControl_ = nil;
	self.downloadsTableView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	segmentedControl_.selectedSegmentIndex = [[BookData sharedBookData] downloadsSegmentedControlIndex];
	[self performSelector:@selector(segmentedControlChangedIndex:) withObject:nil];
	
	[BookData sharedBookData].delegate = self;
	
	if ([BookData sharedBookData].booksFromAPI == nil) {
		[[BookData sharedBookData] getBooksFromAPI];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	self.modalInPopover = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[BookData sharedBookData].delegate = nil;
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
	return [NSArray arrayWithObjects:@"Actualizar", @"Tienda", nil];
}

- (void)checkEmptyView
{
	if ([self.dataSource count] > 0) {
		[backgroundEmptyView_ hide];
	} else {
		[backgroundEmptyView_ show];
	}
}

#pragma mark - Selector Actions

- (void)segmentedControlChangedIndex:(id)sender
{
	[[BookData sharedBookData] setDownloadsSegmentedControlIndex:[segmentedControl_ selectedSegmentIndex]];
	
	if ([segmentedControl_ selectedSegmentIndex] == 0) {
		self.title = @"Actualizar Leyes";
		[backgroundEmptyView_ setTitle:@"No hay actualizaciones disponibles." indicator:NO];
		self.dataSource = [[BookData sharedBookData] booksAvailableForUpdate];
		downloadButtonItem_.enabled = YES;
	} else {
		self.title = @"Tienda de Leyes";
		[backgroundEmptyView_ setTitle:@"No hay leyes disponibles para instalar." indicator:NO];
		self.dataSource = [[BookData sharedBookData] booksAvailableforInstall];
		downloadButtonItem_.enabled = NO;
	}
	
	[self.downloadsTableView reloadData];
	[self checkEmptyView];
}

- (void)refreshAction:(id)sender
{
	[[BookData sharedBookData] getBooksFromAPI];
}

- (void)dismissAction:(id)sender
{
	[self.delegate downloadsViewControllerDidFinish:self];
}

- (void)downloadAllAction:(id)sender
{
	
}

- (void)downloadBookAction:(id)sender
{
	APIBook *book = [self.dataSource objectAtIndex:[sender tag]];
	[[BookData sharedBookData] downloadAndInstallBook:book];
}

- (void)loadBooksNotificationAction:(NSNotification *)notification
{
	NSLog(@"%@", [BookData sharedBookData].booksFromAPI);
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
	
	APIBook *book = [self.dataSource objectAtIndex:indexPath.row];
	book.userData = [NSNumber numberWithInteger:indexPath.row];
	
	NSString *buttonTitle = nil;
	NSString *dateSubstring = nil;
	if ([segmentedControl_ selectedSegmentIndex] == 0) {
		buttonTitle = @"Actualizar";
		dateSubstring = @"Actualizado";
	} else {
		buttonTitle = @"Instalar";
		dateSubstring = @"Fecha";
	}
	
	NSString *dateStr = [NSString stringWithFormat:@"%@: %@",
						 dateSubstring,
						 [NSDateFormatter spanishMediumStringFromDate:book.date]];
	
	cell.textLabel.text = book.title;
	cell.detailTextLabel.text = dateStr;
	
	[cell.downloadButton setTitle:buttonTitle forState:UIControlStateNormal];
	cell.downloadButton.tag = indexPath.row;
	[cell.downloadButton addTarget:self action:@selector(downloadBookAction:) forControlEvents:UIControlEventTouchUpInside];
	cell.downloadLabel.text = @"GRATIS";
    
    return cell;
}

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

#pragma mark - BookDataUpdateDelegate Methods

- (void)didBeginCheckingForUpdate
{
	[backgroundLoadingView_ show];
}

- (void)willBeginInstallingAPIBook:(APIBook *)book
{
	HUD_ = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
	
	HUD_.removeFromSuperViewOnHide = YES;
	HUD_.dimBackground = YES;
	
	NSString *labelStr = nil;
	if ([segmentedControl_ selectedSegmentIndex] == 0) {
		labelStr = @"Actualizando...";
	} else {
		labelStr = @"Instalando...";
	}
	HUD_.labelText = labelStr;
}

- (void)didFinishInstallingAPIBook:(APIBook *)book
{
	// I should put an error in this delegate method
	[[BookData sharedBookData] loadBookWithName:book.name];
	[HUD_ hide:YES];
	HUD_ = nil;
	
	NSInteger bookIndex = [book.userData integerValue];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:bookIndex inSection:0];
	
	[self.dataSource removeObjectAtIndex:indexPath.row];
	[self.downloadsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
								   withRowAnimation:UITableViewScrollPositionBottom];
	[self.downloadsTableView reloadData];
	[self checkEmptyView];
}

- (void)didLoadBooksForUpdate:(NSArray *)books
{
	[backgroundLoadingView_ hide];
	[self performSelector:@selector(segmentedControlChangedIndex:) withObject:nil];
}

- (void)didFailToLoadBooksForUpdate:(NSError *)error
{
	[backgroundLoadingView_ hide];
	[self checkEmptyView];
}

@end
