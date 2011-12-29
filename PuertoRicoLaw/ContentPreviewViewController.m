//
//  ContentPreviewViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/29/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "ContentPreviewViewController.h"
#import "Settings.h"
#import "NSString+Extras.h"

@implementation ContentPreviewViewController

@synthesize webView = webView_;

- (id)init
{
	self = [super initWithNibName:@"ContentPreviewViewController" bundle:nil];
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.webView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSString *body =
	@"<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas vel enim quam, fringilla ullamcorper magna. Suspendisse ac lacus nibh, sed aliquet tellus. Mauris lacinia lorem sed quam blandit luctus. Nulla facilisi. Nulla quis bibendum purus. In molestie, ante sit amet sollicitudin vestibulum, tortor massa mattis tortor, nec congue nisl velit id tortor. Aenean lorem sapien, malesuada id ultrices non, ornare vel elit. In posuere adipiscing lectus, id gravida nunc rutrum vel. Maecenas vehicula quam id elit fringilla blandit blandit nisl condimentum. Phasellus pulvinar, sem vel consequat lacinia, justo diam posuere enim, lacinia consectetur metus nisl eu justo. Morbi vel ante nisi.</p>";
	
	NSString *content = [NSString htmlStringWithTitle:@"Lorem Ipsum" body:body];
	self.webView.scrollView.indicatorStyle = [[Settings sharedSettings] scrollViewIndicator];
	[self.webView loadHTMLString:content baseURL:nil];
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

@end
