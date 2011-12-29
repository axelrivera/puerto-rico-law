//
//  SettingsViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "SettingsViewController.h"
#import "ContentPreviewViewController.h"
#import "Settings.h"

#define kFontFamilyControllerTag 101
#define kFontSizeControllerTag 102
#define kContentBackgroundControllerTag 103

@implementation SettingsViewController

- (id)init
{
	self = [super initWithNibName:@"SettingsViewController" bundle:nil];
	if (self) {
		self.title = @"Configurar";
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
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK"
																			  style:UIBarButtonItemStyleDone
																			 target:self
																			 action:@selector(dismissAction:)];
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
	[self.tableView reloadData];
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

#pragma mark - Selector Actions

- (void)dismissAction:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)landscapeAction:(id)sender
{
	UISwitch *switchView = (UISwitch *)sender;
	[[Settings sharedSettings] setLandscapeMode:switchView.isOn];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = 0;
    if (section == 0) {
		row = 1;
	} else if (section == 1) {
		row = 4;
	}
	return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		NSString *CellIdentifier = @"SwitchCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			UISwitch *landscapeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
			cell.accessoryView = landscapeSwitch;
		}
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.text = @"Landscape";
		
		UISwitch *switchView = (UISwitch *)cell.accessoryView;
		[switchView addTarget:self action:@selector(landscapeAction:) forControlEvents:UIControlEventValueChanged];
		[switchView setOn:[Settings sharedSettings].landscapeMode animated:NO];
		
		return cell;
	}
	
    NSString *CellIdentifier = @"Value1Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
	NSString *textStr = nil;
	NSString *detailTextStr = nil;
	
	if (indexPath.row == 0) {
		textStr = @"Tipo";
		detailTextStr = [[Settings sharedSettings] fontFamilyString];
	} else if (indexPath.row == 1) {
		textStr = @"Tamaño";
		detailTextStr = [[Settings sharedSettings] fontSizeString];
	} else if (indexPath.row == 2) {
		textStr = @"Background";
		detailTextStr = [[Settings sharedSettings] contentBackgroundString];
	} else if (indexPath.row == 3) {
		textStr = @"Ver Ejemplo";
		detailTextStr = nil;
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.text = textStr;
	cell.detailTextLabel.text = detailTextStr;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    if (indexPath.section == 1) {
		if (indexPath.row == 3) {
			ContentPreviewViewController *previewController = [[ContentPreviewViewController alloc] init];
			previewController.title = @"Ejemplo Contenido";
			[self.navigationController pushViewController:previewController animated:YES];
			return;
		}
		TableSelectViewController *selectController = [[TableSelectViewController alloc] init];
		selectController.delegate = self;
		if (indexPath.row == 0) {
			selectController.selectID = kFontFamilyControllerTag;
			selectController.currentIndex = [Settings sharedSettings].fontFamilyType;
			selectController.tableData = [Settings fontFamilyArray];
			selectController.title = @"Tipo de Font";
		} else if (indexPath.row == 1) {
			selectController.selectID = kFontSizeControllerTag;
			selectController.currentIndex = [Settings sharedSettings].fontSizeType;
			selectController.tableData = [Settings fontSizeArray];
			selectController.title = @"Tamaño de Font";
		} else if (indexPath.row == 2) {
			selectController.selectID = kContentBackgroundControllerTag;
			selectController.currentIndex = [Settings sharedSettings].contentBackgroundType;
			selectController.tableData = [Settings contentBackgroundArray];
			selectController.title = @"Color del Background";
		}
		[self.navigationController pushViewController:selectController animated:YES];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title = nil;
	if (section == 1) {
		title = @"Fonts";
	}
	return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSString *title = nil;
	if (section == 1) {
		title = @"Fonts visibles en el contenido.";
	}
	return title;
}

#pragma mark - UIViewController Delegate Methods

- (void)tableSelectViewControllerDidFinish:(TableSelectViewController *)controller
{
	if (controller.selectID == kFontFamilyControllerTag) {
		[Settings sharedSettings].fontFamilyType = controller.currentIndex;
	} else if (controller.selectID == kFontSizeControllerTag) {
		[Settings sharedSettings].fontSizeType = controller.currentIndex;
	} else if (controller.selectID == kContentBackgroundControllerTag) {
		[Settings sharedSettings].contentBackgroundType = controller.currentIndex;
	}
}

@end
