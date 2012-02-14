//
//  InformationViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 2/13/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import "InformationViewController.h"
#import "Settings.h"
#import "PolicyViewController.h"
#import "RLAppsViewController.h"

@implementation InformationViewController

- (id)init
{
    self = [super initWithNibName:@"InformationViewController" bundle:nil];
    if (self) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.contentSizeForViewInPopover = kMainPopoverSize;
		}
		self.title = @"Información";
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger rows = 1;
	if (section == 1) {
		rows = 3;
	}
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	NSString *textStr = nil;
	NSString *detailStr = nil;
	
	if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			textStr = @"Website";
			detailStr = @"riveralabs.com";
		} else if (indexPath.row == 1) {
			textStr = @"Twitter";
			detailStr = @"@RiveraLabs";
		} else if (indexPath.row == 2) {
			textStr = @"Más de Rivera Labs";
			detailStr = nil;
		}
	} else {
		if (indexPath.section == 0) {
			textStr = @"Términos y Condiciones";
			detailStr = nil;
		} else if (indexPath.section == 2) {
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			textStr = @"Versión";
			detailStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		} else if (indexPath.section == 3) {
			textStr = @"Icon";
			detailStr = @"James Lynn";
		}
	}
	
	cell.textLabel.text = textStr;
	cell.detailTextLabel.text = detailStr;
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0) {
		PolicyViewController *policyViewController = [[PolicyViewController alloc] init];
		[self.navigationController pushViewController:policyViewController animated:YES];
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://riveralabs.com/leyes/"]];
		} else if (indexPath.row == 1) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/riveralabs"]];
		} else if (indexPath.row == 2) {
			RLAppsViewController *appsViewController = [[RLAppsViewController alloc] init];
			[self.navigationController pushViewController:appsViewController animated:YES];
		}
	} else if (indexPath.section == 3) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.jameslynn.com"]];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title = nil;
	if (section == 1) {
		title = @"Rivera Labs";
	} else if (section == 3) {
		title = @"Créditos";
	}
	return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSString *title = nil;
	if (section == 3) {
		title = [NSString stringWithFormat:
				 @"Leyes Puerto Rico %@\n"
				 @"Copyright © 2012; Rivera Labs",
				 [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
	}
	return title;
}

@end
