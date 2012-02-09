//
//  BookDetailViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 2/9/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import "BookDetailViewController.h"
#import "Settings.h"

@implementation BookDetailViewController
{
	UIFont *generalFont_;
	UIFont *notesFont_;
}

@synthesize titleLabel = titleLabel_;
@synthesize descriptionLabel = descriptionLabel_;
@synthesize lastUpdatedLabel = lastUpdatedLabel_;
@synthesize notesContainer = notesContainder_;
@synthesize bookTitle = bookTitle_;
@synthesize bookDescription = bookDescription_;
@synthesize bookLastUpdate = bookLastUpdate_;
@synthesize bookNotes = bookNotes_;

- (id)initWithTitle:(NSString *)title description:(NSString *)description lastUpdate:(NSString *)lastUpdate notes:(NSString *)notes
{
	self = [super initWithNibName:@"BookDetailViewController" bundle:nil];
	if (self) {
		bookTitle_ = [[NSString alloc] initWithString:title];;
		bookDescription_ = [[NSString alloc] initWithString:description];
		bookLastUpdate_ = [[NSString alloc] initWithString:lastUpdate];
		bookNotes_ = [[NSString alloc] initWithString:notes];
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
	
	self.title = @"Detalles";
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK"
																			  style:UIBarButtonItemStyleDone
																			 target:self
																			 action:@selector(dismissAction:)];
	
	self.titleLabel.text = self.bookTitle;
	[self.titleLabel sizeToFit];
	self.descriptionLabel.text = self.bookDescription;
	[self.descriptionLabel sizeToFit];
	self.lastUpdatedLabel.text = self.bookLastUpdate;
	[self.lastUpdatedLabel sizeToFit];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	self.titleLabel = nil;
	self.descriptionLabel = nil;
	self.lastUpdatedLabel = nil;
	self.notesContainer = nil;
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

@end
