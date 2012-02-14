//
//  RLAppsViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 2/14/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import "RLAppsViewController.h"
#import "Settings.h"

@implementation RLAppsViewController

- (id)init
{
    self = [super initWithNibName:@"RLAppsViewController" bundle:nil];
    if (self) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.contentSizeForViewInPopover = kMainPopoverSize;
		}
		self.title = @"Apps";
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

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	self.modalInPopover = YES;
	self.navigationController.toolbarHidden = YES;
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
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *textStr;
	UIImage *image;
	
	if (indexPath.row == 0) {
		textStr = @"Lotería Puerto Rico";
		image = [UIImage imageNamed:@"loteria_icon.png"];
	} else if (indexPath.row == 1) {
		textStr = @"Friendly Tip Calculator";
		image = [UIImage imageNamed:@"ftc_icon.png"];
	}
	
	cell.textLabel.text = textStr;
	cell.imageView.image = image;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString *storeStr = @"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8";
	NSString *appStr = nil;
	if (indexPath.row == 0) {
		appStr = [NSString stringWithFormat:storeStr, @"414027930"];
	} else if (indexPath.row == 1) {
		appStr = [NSString stringWithFormat:storeStr, @"487270554"];
	}
	
	if (appStr) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStr]];
	}
}

@end
