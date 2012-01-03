//
//  SectionContentViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "SectionContentViewController.h"
#import "UIViewController+Section.h"
#import "SectionListViewController.h"
#import "FavoritesViewController.h"
#import "Book.h"
#import "Section.h"
#import "Settings.h"
#import "NSString+Extras.h"
#import "SectionManager.h"

@implementation SectionContentViewController

@synthesize webView = webView_;
@synthesize manager = manager_;
@synthesize fileContentStr = fileContentStr_;

- (id)init
{
	self = [super initWithNibName:@"SectionContentViewController" bundle:nil];
	if (self) {
		manager_ = nil;
		fileContentStr_ = nil;
	}
	return self;
}

- (id)initWithSection:(Section *)section siblingSections:(NSArray *)siblings currentSiblingIndex:(NSInteger)index
{
	self = [self init];
	if (self) {
		manager_ = [[SectionManager alloc] initWithSection:section siblings:siblings currentIndex:index];
		manager_.controller = self;
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
	
    [self setToolbarItems:[self sectionToolbarItems] animated:NO];
	self.manager.prevItem = [self.toolbarItems objectAtIndex:kToolbarItemPosition2];
	self.manager.nextItem = [self.toolbarItems objectAtIndex:kToolbarItemPosition3];
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
	[self refresh];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	if ([self.manager.actionSheet isVisible]) {
		[self.manager.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self.webView setNeedsDisplay];
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

#pragma mark - Custom Methods

- (NSString *)htmlStringForSection
{
	return [NSString htmlStringWithTitle:self.manager.section.title body:self.fileContentStr];
}

- (NSString *)htmlStringForEmail
{
	NSString *contentStr = self.fileContentStr;
	
	NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:0];
	Section *section = self.manager.section;
	while (section != nil) {
		[sections addObject:section];
		section = section.parent;
	}
	
	NSMutableString *tmpStr = [[NSMutableString alloc] initWithString:@""];
	for (NSInteger i = [sections count] - 1; i >= 0; i--) {
		Section *currentSection = [sections objectAtIndex:i];
		if (i == [sections count] - 1) {
			[tmpStr appendFormat:@"<p><strong>%@</strong></p>", currentSection.title];
		} else {
			[tmpStr appendFormat:@"<p><strong>%@:</strong> %@</p>", currentSection.label, currentSection.title];
		}
	}
	
	NSString *headerStr = nil;
	if ([tmpStr length] > 0) {
		headerStr = [NSString stringWithFormat:@"<p>%@</p>", tmpStr];
	}
	
	NSString *aboutStr = @"<p>----------<br/>Esta información fue generada con el App Leyes de Puerto Rico para iPhone, "
	@"iPod touch y iPad. Para más información visite http://riveralabs.com</p>";
	
	return [NSString stringWithFormat:@"<html><body>%@%@%@</body></html>", headerStr, contentStr, aboutStr];
}

- (NSString *)fileContentString
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:self.manager.section.contentFile ofType:@"html"];
	return [NSString stringWithContentsOfFile:filePath
									 encoding:NSUTF8StringEncoding
										error:NULL];
}

#pragma mark - Private Methods

- (void)refresh
{
	if ([self.manager.actionSheet isVisible]) {
		[self.manager.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
	}
	
	self.webView.scrollView.indicatorStyle = [[Settings sharedSettings] scrollViewIndicator];
	
	if (self.manager.section == nil) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
		self.title = @"Leyes Puerto Rico";
		self.fileContentStr = nil;
		[self.webView loadHTMLString:@"" baseURL:nil];
		[self.manager checkItemsAndUpdateFavoriteIndex];
		self.navigationController.toolbarHidden = YES;
		return;
	}

	self.navigationItem.rightBarButtonItem.enabled = YES;
	self.title = self.manager.section.label;
	if (self.fileContentStr == nil) {
		self.fileContentStr = [self fileContentString];
		[self.webView loadHTMLString:[self htmlStringForSection] baseURL:nil];
	}
	[self.manager checkItemsAndUpdateFavoriteIndex];
	self.navigationController.toolbarHidden = NO;
}

#pragma mark - Selector Actions

- (void)homeAction:(id)sender
{
	[self goHome];
}

- (void)favoritesAction:(id)sender
{
	[self.manager showFavorites:sender];
}

- (void)optionsAction:(id)sender
{
	[self.manager showOptions:sender];
}

- (void)prevAction:(id)sender
{
	[self.manager showPrev];
}

- (void)nextAction:(id)sender
{
	[self.manager showNext];
}

#pragma mark - UIWebView Delegate Methods

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
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

@end
