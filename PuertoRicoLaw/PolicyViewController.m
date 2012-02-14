//
//  PolicyViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 2/14/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import "PolicyViewController.h"
#import "Settings.h"

@implementation PolicyViewController

@synthesize webView = webView_;

- (id)init
{
    self = [super initWithNibName:@"PolicyViewController" bundle:nil];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.contentSizeForViewInPopover = kMainPopoverSize;
		}
		self.title = @"Términos";
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
    
	NSString *path = [[NSBundle mainBundle] pathForResource:@"terminos" ofType:@"htm"];
	NSURL *url = [[NSURL alloc] initWithString:path];
	NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url
													 cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
												 timeoutInterval:30];
	[self.webView loadRequest:urlRequest];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.webView = nil;
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

@end
