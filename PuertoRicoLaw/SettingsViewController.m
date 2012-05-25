//
//  SettingsViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "SettingsViewController.h"
#import "ContentPreviewViewController.h"
#import "InformationViewController.h"
#import "Settings.h"
#import "EndorsementView.h"
#import "APIBook.h"
#import "Book.h"
#import "MBProgressHUD.h"

#define kFontFamilyControllerTag 101
#define kFontSizeControllerTag 102
#define kContentBackgroundControllerTag 103

@interface SettingsViewController (Private)

- (void)displayComposerSheetTo:(NSArray *)toRecipients subject:(NSString *)subject body:(NSString *)body;

@end

@implementation SettingsViewController
{
	MBProgressHUD *HUD_;
}

@synthesize delegate = delegate_;
@synthesize updateButton = updateButton_;

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
	
	self.updateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.updateButton setTitle:@"Actualizar Contenido" forState:UIControlStateNormal];
	[self.updateButton setTitle:@"En Proceso..." forState:UIControlStateSelected];
	[self.updateButton setTitle:@"Actualización No Disponible" forState:UIControlStateDisabled];
	[self.updateButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
	self.updateButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.updateButton addTarget:self action:@selector(checkUpdateAction:) forControlEvents:UIControlEventTouchDown];
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
	
	if (![[RKObjectManager sharedManager].client isNetworkReachable]) {
		self.updateButton.enabled = NO;
	}
	
	[[BookData sharedBookData] setDelegate:self];
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	self.modalInPopover = YES;
	self.navigationController.toolbarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[BookData sharedBookData] cancelAllBookRequests];
	[[BookData sharedBookData] setDelegate:nil];
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

- (void)checkUpdateAction:(id)sender
{
	[[BookData sharedBookData] getBooksFromAPI];
}

- (void)updateBooksAction:(id)sender
{
}

#pragma mark - BookDataUpdate Delegate Methods

- (void)willBeginLoadingBooks
{
	NSLog(@"Did start checking for Update");
	self.updateButton.selected = YES;
}

- (void)didLoadBooks:(NSArray *)books
{
	BOOL updateAvailable = NO;
	
	NSDictionary *currentBooks = [[BookData sharedBookData] booksDictionary];
	
	for (APIBook *apiBook in books) {
		Book *book = [currentBooks objectForKey:apiBook.name];
		if (book && [apiBook.bookVersion integerValue] > [book.bookVersion integerValue]) {
			updateAvailable = YES;
			break;
		}
	}
	
	UIAlertView *alertView = nil;
	if (updateAvailable) {
		alertView = [[UIAlertView alloc] initWithTitle:@"Actualización Disponible"
											   message:@"Hay actualizaciones disponibles. Oprima OK para actualizar el contenido de las leyes instaladas."
											  delegate:self
									 cancelButtonTitle:@"Cancelar"
									 otherButtonTitles:@"OK", nil];
	} else {
		alertView = [[UIAlertView alloc] initWithTitle:@"No hay Actualizaciones"
											   message:@"El contenido de todas las leyes está actualizado."
											  delegate:nil
									 cancelButtonTitle:@"OK"
									 otherButtonTitles:nil];
	}
	
	[alertView show];
	
	self.updateButton.selected = NO;
}

- (void)didFailToLoadBooks:(NSError *)error
{
	self.updateButton.selected = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = 0;
    if (section == 0) {
		row = 1;
	} else if (section == 1) {
		row = 1;
	} else if (section == 2) {
		row = 4;
	} else if (section == 3) {
		row = 2;
	} else if (section == 4) {
		row = 1;
	} else if (section == 5) {
		row = 1;
	}
	return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		NSString *CellIdentifier = @"UpgradeCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
			backView.backgroundColor = [UIColor clearColor];
			cell.backgroundView = backView;
			CGRect contentFrame = cell.contentView.bounds;
			CGRect buttonFrame = CGRectMake(contentFrame.origin.x,
											contentFrame.origin.y,
											contentFrame.size.width - 20.0,
											44.0);
			cell.contentView.frame = buttonFrame;
			self.updateButton.frame = buttonFrame;
			[cell.contentView addSubview:self.updateButton];
		}
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		return cell;
	} else if (indexPath.section == 1) {
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
	} else if (indexPath.section == 3) {
		NSString *CellIdentifier = @"ButtonCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		
		NSString *textStr = nil;
		
		if (indexPath.row == 0) {
			textStr = @"Recomendar a un Amigo";
		} else {
			textStr = @"Enviar Sugerencias";
		}
		
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.text = textStr;
		
		return cell;
	} else if (indexPath.section == 5) {
		NSString *CellIdentifier = @"EndorsementCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
			backView.backgroundColor = [UIColor clearColor];
			cell.backgroundView = backView;
			CGRect contentFrame = cell.contentView.bounds;
			CGRect endorsementFrame = CGRectMake(contentFrame.origin.x,
												 contentFrame.origin.y,
												 contentFrame.size.width,
												 153.0);
			cell.contentView.frame = endorsementFrame;
			EndorsementView *endorsementView = [[EndorsementView alloc] initWithFrame:endorsementFrame];
			[cell.contentView addSubview:endorsementView];
		}
		
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		return cell;
	}
	
    NSString *CellIdentifier = @"Value1Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
	NSString *textStr = nil;
	NSString *detailTextStr = nil;
	
	if (indexPath.section == 2) {
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
		textStr = @"Información";
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
	
    if (indexPath.section == 2) {
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
	} else if (indexPath.section == 3) {
		NSArray *toRecipients = nil;
		NSString *subjectStr = nil;
		NSString *bodyStr = nil;
		if (indexPath.row == 0) {
			subjectStr = @"Te Recomiendo el App Leyes Puerto Rico para iPhone, iPod touch y iPad";
			bodyStr =
				@"Estoy usando el app Leyes Puerto Rico para iPhone, iPod touch y iPad. Lo puedes bajar buscando "
				@"\"Leyes Puerto Rico\" en el App Store o visita http://riveralabs.com/leyes/ para más información.";
		} else {
			toRecipients = [NSArray arrayWithObject:@"apps@riveralabs.com"];
			subjectStr = @"Enviar Sugerencia - Leyes Puerto Rico";
			bodyStr = @"He estado usando el app Leyes Puerto Rico y me gustaría enviar las siguientes sugerencias.<br />";
		}
		[self displayComposerSheetTo:toRecipients subject:subjectStr body:bodyStr];
	} else if (indexPath.section == 4) {
		InformationViewController *infoController = [[InformationViewController alloc] init];
		[self.navigationController pushViewController:infoController animated:YES];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title = nil;
	if (section == 2) {
		title = @"Fonts";
	}
	return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSString *title = nil;
	if (section == 0) {
		title = @"Oprime para actualizar el contenido con enmiendas o corrección de errores.";
	} else if (section == 2) {
		title = @"Fonts visibles en el contenido.";
	} else if (section == 3) {
		title = @"Envianos sugerencias sobre mejoras o leyes que te parecen importantes.";
	} else if (section == 5) {
		title = [NSString stringWithFormat:
				 @"Leyes Puerto Rico %@\n"
				 @"Copyright © 2012; Rivera Labs",
				 [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
	}
	return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = 44.0;
	if (indexPath.section == 5) {
		height = 153.0;
	}
	return height;
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
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[alert show];
	}
}

#pragma mark UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		[self performSelector:@selector(updateBooksAction:) withObject:nil];
		HUD_ = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
		
		//HUD_.removeFromSuperViewOnHide = YES;
		HUD_.dimBackground = YES;
		HUD_.labelText = @"Actualizando...";
	}
}

@end
