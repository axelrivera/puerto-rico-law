//
//  SectionContentViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "SectionContentViewController.h"
#import "Section.h"

@interface SectionContentViewController (Private)

- (NSString *)htmlStringForSection;
- (NSArray *)toolbarItemsArray;

@end

@implementation SectionContentViewController

@synthesize webView = webView_;
@synthesize section = section_;

- (id)init
{
	self = [super initWithNibName:@"SectionContentViewController" bundle:nil];
	if (self) {
		
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
    [self setToolbarItems:[self toolbarItemsArray] animated:NO];
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
	self.title = self.section.label;
	[self.webView loadHTMLString:[self htmlStringForSection] baseURL:nil];
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

- (NSString *)htmlStringForSection
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:self.section.contentFile ofType:@"html"];
	NSString *contentStr = [NSString stringWithContentsOfFile:filePath
													 encoding:NSUTF8StringEncoding
														error:NULL]; 
	NSString *htmlString = [NSString stringWithFormat:@"<html><body></body><h2>%@</h2>%@</html>", self.section.title, contentStr];
	return htmlString;
}

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
	
	UIBarButtonItem *optionsAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																				   target:self
																				   action:@selector(optionsAction:)];
	
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
			optionsAction,
			nil];
}

#pragma mark - Selector Actions

- (void)homeAction:(id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)optionsAction:(id)sender
{
	
}

- (void)prevAction:(id)sender
{
	
}

- (void)nextAction:(id)sender
{
	
}

#pragma mark - UIWebView Delegate Methods

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
	return YES;
}

@end
