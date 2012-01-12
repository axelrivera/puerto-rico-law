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

@interface SettingsViewController (Private)

- (void)displayComposerSheetTo:(NSArray *)toRecipients subject:(NSString *)subject body:(NSString *)body;

@end

@implementation SettingsViewController

@synthesize delegate = delegate_;

- (id)init
{
	self = [super initWithNibName:@"SettingsViewController" bundle:nil];
	if (self) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.contentSizeForViewInPopover = kMainPopoverSize;
		}
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
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.navigationItem.hidesBackButton = YES;
	}
	
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

#pragma mark - Private Methods

- (void)displayComposerSheetTo:(NSArray *)toRecipients subject:(NSString *)subject body:(NSString *)body
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	if (toRecipients) {
		[picker setToRecipients:toRecipients];
	}
	
	[picker setSubject:subject];
	[picker setMessageBody:body isHTML:YES];
	[self presentModalViewController:picker animated:YES];
}

#pragma mark - Selector Actions

- (void)dismissAction:(id)sender
{
	[self.delegate settingsViewControllerDidFinish:self];
}

- (void)landscapeAction:(id)sender
{
	UISwitch *switchView = (UISwitch *)sender;
	[[Settings sharedSettings] setLandscapeMode:switchView.isOn];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = 0;
    if (section == 0) {
		row = 1;
	} else if (section == 1) {
		row = 4;
	} else if (section == 2) {
		row = 2;
	} else if (section == 3) {
		row = 1;
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
	} else if (indexPath.section == 2) {
		NSString *CellIdentifier = @"ButtonCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		
		NSString *textStr = nil;
		
		if (indexPath.row == 0) {
			textStr = @"Recomiendanos a tus Amigos";
		} else {
			textStr = @"Enviar Sugerencias";
		}
		
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.text = textStr;
		
		return cell;
	}
	
    NSString *CellIdentifier = @"Value1Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
	NSString *textStr = nil;
	NSString *detailTextStr = nil;
	
	if (indexPath.section == 1) {
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
	} else {
		textStr = @"Sobre Rivera Labs";
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
	} else if (indexPath.section == 2) {
		NSArray *toRecipients = nil;
		NSString *subjectStr = nil;
		NSString *bodyStr = nil;
		if (indexPath.row == 0) {
			subjectStr = @"Te Recomiendo el App Leyes Puerto Rico para iPhone, iPod touch y iPad";
			bodyStr =
				@"Estoy usando el app Leyes Puerto Rico. Lo puedes bajar buscando "
				@"\"Leyes Puerto Rico\" en el App Store.  Visita http://riveralabs.com/leyes/ para más información.";
		} else {
			toRecipients = [NSArray arrayWithObject:@"apps@riveralabs.com"];
			subjectStr = @"Enviar Sugerencia - Leyes Puerto Rico";
			bodyStr = @"He estado usando el app Leyes Puerto Rico y me gustaría enviar las siguientes sugerencias.<br />";
		}
		[self displayComposerSheetTo:toRecipients subject:subjectStr body:bodyStr];
	} else if (indexPath.section == 3) {
		
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
	} else if (section == 2) {
		title = @"Envianos sugerencias sobre mejoras o leyes que deseas que incluyamos.";
	} else if (section == 3) {
		title = [NSString stringWithFormat:
				 @"Leyes Puerto Rico %@\n"
				 @"Copyright © 2012; Rivera Labs",
				 [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
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

#pragma mark - MFMailComposeViewController Delegate

// Dismisses the email composition interface when users tap Cancel or Send.
// Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError*)error
{	
	NSString *errorString = nil;
	
	BOOL showAlert = NO;
	// Notifies users about errors associated with the interface
	switch (result)  {
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
			errorString = [NSString stringWithFormat:@"E-mail failed: %@", 
						   [error localizedDescription]];
			showAlert = YES;
			break;
		default:
			errorString = [NSString stringWithFormat:@"E-mail was not sent: %@", 
						   [error localizedDescription]];
			showAlert = YES;
			break;
	}
	
	[self dismissModalViewControllerAnimated:YES];
	
	if (showAlert == YES) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"E-mail Error"
														message:errorString
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[alert show];
	}
}

@end
