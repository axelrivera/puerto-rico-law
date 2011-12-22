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

@interface SectionListViewController (Private)

- (NSArray *)toolbarItemsArray;

@end

@implementation SectionListViewController

@synthesize sectionTitle = sectionTitle_;
@synthesize sectionDataSource = sectionDataSource_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:@"SectionListViewController" bundle:nil];
	if (self) {
		// Initialization Code
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
	self.title = self.sectionTitle;
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

#pragma mark - Private Methods

- (NSArray *)toolbarItemsArray
{
	UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				  target:nil
																				  action:nil];
	
	UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
																			   target:nil
																			   action:nil];
	fixedItem.width = 50.0;
	
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
	
	return [NSArray arrayWithObjects:
			homeItem,
			flexibleItem,
			prevItem,
			fixedItem,
			nextItem,
			flexibleItem,
			nil];
}

#pragma mark - Selector Actions

- (void)homeAction:(id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)prevAction:(id)sender
{
	
}

- (void)nextAction:(id)sender
{
	
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sectionDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
	
	Section *section = [self.sectionDataSource objectAtIndex:indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0];
	cell.textLabel.text = section.label;
	cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0];
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
		[self.navigationController pushViewController:contentController animated:YES];
	} else {
		SectionListViewController *sectionController = [[SectionListViewController alloc] init];
		sectionController.sectionTitle = section.label;
		sectionController.sectionDataSource = section.children;
		[self.navigationController pushViewController:sectionController animated:YES];
	}
}

@end
