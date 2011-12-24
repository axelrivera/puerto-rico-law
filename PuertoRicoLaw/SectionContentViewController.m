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
	self.webView = nil;
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
	
	UIBarButtonItem *optionsItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																				 target:self
																				 action:@selector(optionsAction:)];
	
	return [NSArray arrayWithObjects:
			homeItem,
			flexibleItem,
			prevItem,
			flexibleItem,
			nextItem,
			flexibleItem,
			optionsItem,
			nil];
}

#pragma mark - Selector Actions

- (void)homeAction:(id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)optionsAction:(id)sender
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancelar"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Enviar E-mail", @"Agregar a Favoritos", nil];
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (void)prevAction:(id)sender
{
	
}

- (void)nextAction:(id)sender
{
	
}

#pragma mark - UIWebView Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - UIActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
}

@end
