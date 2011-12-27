//
//  SectionListViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "SectionListViewController.h"
#import "SectionContentViewController.h"
#import "Book.h"
#import "Section.h"
#import "SectionTableViewCell.h"
#import "BookData.h"

@interface SectionListViewController (Private)

- (void)checkGoNextItem;
- (BOOL)canGoNext;
- (void)checkGoPrevItem;
- (BOOL)canGoPrev;
- (void)reloadContentWithParentSectionAtIndex:(NSInteger)index;
- (NSArray *)toolbarItemsArray;

@end

@implementation SectionListViewController
{
	BookData *bookData_;
	UIView *headerView_;
	UIBarButtonItem *prevItem_;
	UIBarButtonItem *nextItem_;
	NSInteger favoriteIndex_;
}

@synthesize section = section_;
@synthesize sectionDataSource = sectionDataSource_;
@synthesize siblingSections = siblingSections_;
@synthesize currentSiblingSectionIndex = currentSiblingSectionIndex_;

- (id)init
{
	self = [super initWithNibName:@"SectionListViewController" bundle:nil];
	if (self) {
		bookData_ = [BookData sharedBookData];
		currentSiblingSectionIndex_ = 0;
		siblingSections_ = nil;
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
	[self setToolbarItems:[self toolbarItemsArray]];
	prevItem_ = [self.toolbarItems objectAtIndex:kToolbarItemPosition2];
	nextItem_ = [self.toolbarItems objectAtIndex:kToolbarItemPosition3];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	prevItem_ = nil;
	nextItem_ = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	self.title = self.section.label;
	[self checkGoNextItem];
	[self checkGoPrevItem];
	favoriteIndex_ = [bookData_ unsignedIndexOfFavoriteContentWithMd5String:[self.section md5String]];
	NSLog(@"Favorite Index: %i", favoriteIndex_);
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
		//[headerView_ layoutSubviews];
	    return YES;
	}
}

#pragma mark - Private Methods

- (void)checkGoNextItem
{
	if ([self canGoNext]) {
		nextItem_.enabled = YES;
		return;
	}
	nextItem_.enabled = NO;
}

- (BOOL)canGoNext
{
	if (self.currentSiblingSectionIndex + 1 >= [self.siblingSections count]) {
		return NO;
	}
	return YES;
}

- (void)checkGoPrevItem
{
	if ([self canGoPrev]) {
		prevItem_.enabled = YES;
		return;
	}
	prevItem_.enabled = NO;
}

- (BOOL)canGoPrev
{
	if (self.currentSiblingSectionIndex - 1 < 0) {
		return NO;
	}
	return YES;
}

- (void)reloadContentWithParentSectionAtIndex:(NSInteger)index
{
	Section *section = [self.siblingSections objectAtIndex:index];
	if (section.children == nil) {
		NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
		[viewControllers removeLastObject];
		SectionContentViewController *contentController = [[SectionContentViewController alloc] init];
		contentController.section = section;
		contentController.siblingSections = self.siblingSections;
		contentController.currentSiblingSectionIndex = index;
		[viewControllers addObject:contentController];
		[self.navigationController setViewControllers:viewControllers];
		return;
	}
	self.title = section.label;
	self.section = section;
	self.sectionDataSource = section.children;
	[self.tableView reloadData];
	[self.tableView setContentOffset:CGPointZero animated:NO];
	[self checkGoNextItem];
	[self checkGoPrevItem];
	favoriteIndex_ = [bookData_ unsignedIndexOfFavoriteContentWithMd5String:[self.section md5String]];
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
	
	UIBarButtonItem *prevItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_arrow.png"]
																	  style:UIBarButtonItemStylePlain
																	 target:self
																	 action:@selector(prevAction:)];
	
	UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"right_arrow.png"]
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(nextAction:)];
	
	UIBarButtonItem *optionsItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																				 target:self
																				 action:@selector(optionsAction:)];
	
	return [NSArray arrayWithObjects:
			homeItem,
			flexibleItem,
			prevItem,
			flexibleItem,
			nextItem,
			flexibleItem,
			optionsItem,
			nil];
}

#pragma mark - Selector Actions

- (void)homeAction:(id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)optionsAction:(id)sender
{
	NSString *favoriteStr = nil;
	if (favoriteIndex_ >= 0) {
		favoriteStr = kFavoriteContentRemoveTitle;
	} else {
		favoriteStr = kFavoriteContentAddTitle;
	}
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancelar"
											   destructiveButtonTitle:nil
													otherButtonTitles:favoriteStr, nil];
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (void)prevAction:(id)sender
{
	if ([self canGoPrev]) {
		self.currentSiblingSectionIndex--;
		[self reloadContentWithParentSectionAtIndex:self.currentSiblingSectionIndex];
	}
}

- (void)nextAction:(id)sender
{
	if ([self canGoNext]) {
		self.currentSiblingSectionIndex++;
		[self reloadContentWithParentSectionAtIndex:self.currentSiblingSectionIndex];
	}
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sectionDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SectionTableViewCell *cell = (SectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SectionTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
	
	Section *section = [self.sectionDataSource objectAtIndex:indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.textLabel.text = section.label;
	cell.detailTextLabel.text = section.title;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	Section *section = [self.sectionDataSource objectAtIndex:indexPath.row];
	if (section.children == nil) {
		SectionContentViewController *contentController = [[SectionContentViewController alloc] init];
		contentController.section = section;
		contentController.siblingSections = self.sectionDataSource;
		contentController.currentSiblingSectionIndex = indexPath.row;
		[self.navigationController pushViewController:contentController animated:YES];
	} else {
		SectionListViewController *sectionController = [[SectionListViewController alloc] init];
		sectionController.title = section.label;
		sectionController.section = section;
		sectionController.sectionDataSource = section.children;
		sectionController.siblingSections = self.sectionDataSource;
		sectionController.currentSiblingSectionIndex = indexPath.row;
		[self.navigationController pushViewController:sectionController animated:YES];
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	CGRect screenRect = [UIScreen mainScreen].bounds;
	CGRect headerFrame = CGRectMake(0.0, 0.0, screenRect.size.width, 52.0);
	CGRect labelFrame = CGRectMake(10.0, 0.0, screenRect.size.width - 20.0, headerFrame.size.height);
	
	headerView_ = [[UIView alloc] initWithFrame:headerFrame];
	headerView_.backgroundColor = [UIColor clearColor];
	
	UILabel *textLabel = [[UILabel alloc] initWithFrame:labelFrame];
	textLabel.font = [UIFont boldSystemFontOfSize:16.0];
	textLabel.backgroundColor = [UIColor clearColor];
	textLabel.textColor = [UIColor darkGrayColor];
	textLabel.textAlignment = UITextAlignmentCenter;
	textLabel.numberOfLines = 2.0;
	textLabel.lineBreakMode = UILineBreakModeTailTruncation;
	textLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
	textLabel.shadowColor = [UIColor whiteColor];
	textLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	textLabel.text = self.section.title;
	
	[headerView_ addSubview:textLabel];
	
	return headerView_;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 52.0;
}

#pragma mark - UIActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		if (favoriteIndex_ >= 0) {
			[bookData_.favoriteContent removeObjectAtIndex:favoriteIndex_];
			favoriteIndex_ = -1;
		} else {
			NSData *data = [self.section serialize];
			[bookData_.favoriteContent addObject:data];
			favoriteIndex_ = [bookData_.favoriteContent count] - 1;
		}
	}
}

@end
