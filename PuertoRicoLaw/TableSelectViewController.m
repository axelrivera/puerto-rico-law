//
//  TableSelectViewController.m
//  TipCalculator
//
//  Created by Axel Rivera on 11/3/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "TableSelectViewController.h"
#import "Settings.h"

@implementation TableSelectViewController

@synthesize delegate = delegate_;
@synthesize selectID = selectID_;
@synthesize currentIndex = currentIndex_;
@synthesize tableData = tableData_;
@synthesize tableHeaderTitle = tableHeaderTitle_;
@synthesize tableFooterTitle = tableFooterTitle_;

- (id)init
{
    self = [super initWithNibName:@"TableSelectViewController" bundle:nil];
    if (self) {
        selectID_ = 0;
        currentIndex_ = 0;
        tableHeaderTitle_ = nil;
        tableFooterTitle_ = nil;
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [delegate_ tableSelectViewControllerDidFinish:self];
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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [tableData_ objectAtIndex:indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
	if (indexPath.row == self.currentIndex) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSInteger localIndex = self.currentIndex;
	if (localIndex == indexPath.row) {
		return;
	}
	
	NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:localIndex inSection:indexPath.section];
	
	UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
	if (newCell.accessoryType == UITableViewCellAccessoryNone) {
		newCell.accessoryType = UITableViewCellAccessoryCheckmark;
		self.currentIndex = indexPath.row;
	}
	
	UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
	if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
		oldCell.accessoryType = UITableViewCellAccessoryNone;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return tableHeaderTitle_;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return tableFooterTitle_;
}

@end
