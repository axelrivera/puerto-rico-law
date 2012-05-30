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
#import "RLCustomButton.h"

#define kSegmentedControlItemWidth 150.0

@interface DownloadsViewController (Private)

- (NSArray *)toolbarItemsArray;
- (NSArray *)segmentedControlTitles;
- (void)checkEmptyView;
- (void)downloadAll;

@end

@implementation DownloadsViewController
{
	RLBackgroundStatusView *backgroundLoadingView_;
	RLBackgroundStatusView *backgroundEmptyView_;
	UISegmentedControl *segmentedControl_;
	MBProgressHUD *HUD_;
	BOOL isDownloadingAll_;
	NSInteger remainingDownloads_;
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
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;	
	backgroundLoadingView_ = nil;
	backgroundEmptyView_ = nil;
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
					  segmentedItem,
					  flexibleItem,
					  nil];
	return array;
}

- (NSArray *)segmentedControlTitles
{
	return [NSArray arrayWithObjects:@"Actualizar", @"Instalar", nil];
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
	} else {
		self.title = @"Leyes Nuevas";
		[backgroundEmptyView_ setTitle:@"No hay leyes disponibles para instalar." indicator:NO];
		self.dataSource = [[BookData sharedBookData] booksAvailableforInstall];
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

- (void)downloadBookAction:(id)sender
{
	isDownloadingAll_ = NO;
	remainingDownloads_ = 1;
	APIBook *book = [self.dataSource objectAtIndex:[sender tag]];
	[[BookData sharedBookData] downloadAndInstallBook:book];
}

- (void)showHUD
{
	HUD_ = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
	HUD_.removeFromSuperViewOnHide = YES;
	HUD_.dimBackground = NO;
	
	NSString *labelStr = nil;
	if ([segmentedControl_ selectedSegmentIndex] == 0) {
		labelStr = @"Actualizando...";
	} else {
		labelStr = @"Instalando...";
	}
	HUD_.labelText = labelStr;
}

- (void)downloadAll
{
	isDownloadingAll_ = YES;
	remainingDownloads_ = [self.dataSource count];
	for (APIBook *book in self.dataSource) {
		[[BookData sharedBookData] downloadAndInstallBook:book];
	}
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
	cell.downloadLabel.text = @"GRATIS";
	[cell.downloadButton addTarget:self action:@selector(downloadBookAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - BookDataUpdateDelegate Methods

- (void)willBeginLoadingBooks
{
	[backgroundLoadingView_ show];
}

- (void)willBeginInstallingBook:(APIBook *)book
{
	NSLog(@"Installing Book!!!");
	if (!isDownloadingAll_ && remainingDownloads_ > 0) {
		[self performSelector:@selector(showHUD) withObject:nil afterDelay:0.2];
	} else {
		if (remainingDownloads_ == [self.dataSource count]) {
			[self performSelector:@selector(showHUD) withObject:nil afterDelay:0.2];
		}
	}
}

- (void)didFinishInstallingBook:(APIBook *)book
{
	NSLog(@"Finished!!!");
	if (!isDownloadingAll_) {
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
	} else {
		[[BookData sharedBookData] loadBookWithName:book.name];
		NSLog(@"Count %d for Book %@", remainingDownloads_, book.name);
		remainingDownloads_--;
		if (remainingDownloads_ == 0) {
			NSLog(@"Hud: %@", HUD_);
			NSLog(@"Hud should hide");
			[self.dataSource removeAllObjects];
			[self.downloadsTableView reloadData];
			//[self checkEmptyView];
			[HUD_ hide:YES];
			HUD_ = nil;
			isDownloadingAll_ = NO;
			remainingDownloads_ = -1;
		}
	}
}

- (void)didLoadBooks:(NSArray *)books
{
	[backgroundLoadingView_ hide];
	[self performSelector:@selector(segmentedControlChangedIndex:) withObject:nil];
	[[BookData sharedBookData] downloadBooks:[BookData sharedBookData].booksAvailableForUpdate];
}

- (void)didFailToLoadBooks:(NSError *)error
{
	[backgroundLoadingView_ hide];
	[self checkEmptyView];
}

@end
