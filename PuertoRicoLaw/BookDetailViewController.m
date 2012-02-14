//
//  BookDetailViewController.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 2/9/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import "BookDetailViewController.h"
#import "Settings.h"

@interface BookDetailViewController (Private)

- (void)adjustContentSize;

@end

@implementation BookDetailViewController

@synthesize delegate = delegate_;
@synthesize scrollView = scrollView_;
@synthesize titleLabel = titleLabel_;
@synthesize descriptionLabel = descriptionLabel_;
@synthesize lastUpdatedLabel = lastUpdatedLabel_;
@synthesize notesLabel = notesLabel_;
@synthesize bookTitle = bookTitle_;
@synthesize bookDescription = bookDescription_;
@synthesize bookLastUpdate = bookLastUpdate_;
@synthesize bookNotes = bookNotes_;

- (id)initWithTitle:(NSString *)title description:(NSString *)description lastUpdate:(NSString *)lastUpdate notes:(NSString *)notes
{
	self = [super initWithNibName:@"BookDetailViewController" bundle:nil];
	if (self) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.contentSizeForViewInPopover = kMainPopoverSize;
		}
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
	
#define MAX_LABEL_HEIGHT 9999.0
	
	CGSize contentSize = self.view.bounds.size;
	
	// Setup Title Label
	
	CGSize titleSize = [self.bookTitle sizeWithFont:[UIFont boldSystemFontOfSize:17.0]
								  constrainedToSize:CGSizeMake(contentSize.width - 20.0, MAX_LABEL_HEIGHT)];
	
	CGRect titleFrame = CGRectMake(10.0, 10.0, contentSize.width - 20.0, titleSize.height);
	
	self.titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
	self.titleLabel.backgroundColor = [UIColor clearColor];
	self.titleLabel.textColor = [UIColor blackColor];
	self.titleLabel.textAlignment = UITextAlignmentCenter;
	self.titleLabel.numberOfLines = 0;
	self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
	self.titleLabel.adjustsFontSizeToFitWidth = NO;
	self.titleLabel.text = self.bookTitle;
	
	// Setup Title Divider
	
	CGRect titleDivFrame = CGRectMake(0.0,
									  titleFrame.origin.y + titleFrame.size.height + 10.0,
									  contentSize.width,
									  1.0);
	UIView *titleDivider = [[UIView alloc] initWithFrame:titleDivFrame];
	titleDivider.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
	
	// Setup Description Label
	
	CGSize descriptionSize = [self.bookDescription sizeWithFont:[UIFont systemFontOfSize:14.0]
											  constrainedToSize:CGSizeMake(contentSize.width - 20.0, MAX_LABEL_HEIGHT)];
	
	CGRect descriptionFrame = CGRectMake(10.0,
										 titleDivFrame.origin.y + titleDivFrame.size.height + 10.0,
										 contentSize.width - 20.0,
										 descriptionSize.height);
	
	self.descriptionLabel = [[UILabel alloc] initWithFrame:descriptionFrame];
	self.descriptionLabel.font = [UIFont systemFontOfSize:14.0];
	self.descriptionLabel.backgroundColor = [UIColor clearColor];
	self.descriptionLabel.textColor = [UIColor blackColor];
	self.descriptionLabel.textAlignment = UITextAlignmentLeft;
	self.descriptionLabel.numberOfLines = 0;
	self.descriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
	self.descriptionLabel.adjustsFontSizeToFitWidth = NO;
	self.descriptionLabel.text = self.bookDescription;
	
	// Setup Last Updated Label
	
	CGRect updateFrame = CGRectMake(10.0,
									descriptionFrame.origin.y + descriptionFrame.size.height + 5.0,
									0.0,
									0.0);
	
	self.lastUpdatedLabel = [[UILabel alloc] initWithFrame:updateFrame];
	self.lastUpdatedLabel.font = [UIFont systemFontOfSize:14.0];
	self.lastUpdatedLabel.backgroundColor = [UIColor clearColor];
	self.lastUpdatedLabel.textColor = [UIColor lightGrayColor];
	self.lastUpdatedLabel.textAlignment = UITextAlignmentLeft;
	self.lastUpdatedLabel.adjustsFontSizeToFitWidth = NO;
	self.lastUpdatedLabel.text = self.bookLastUpdate;
	
	[self.lastUpdatedLabel sizeToFit];
	
	updateFrame = self.lastUpdatedLabel.frame;
	
	// Setup Description Divider
	
	CGRect descDivFrame = CGRectMake(0.0,
									  updateFrame.origin.y + updateFrame.size.height + 10.0,
									  contentSize.width,
									  1.0);
	UIView *descDivider = [[UIView alloc] initWithFrame:descDivFrame];
	descDivider.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
	
	// Setup Notes Title Label
	
	NSString *notesTitleStr = @"Notas:";
	
	CGRect notesTitleFrame = CGRectMake(10.0,
										descDivFrame.origin.y + descDivFrame.size.height + 10.0,
										0.0,
										0.0);
	
	UILabel *notesTitleLabel = [[UILabel alloc] initWithFrame:notesTitleFrame];
	notesTitleLabel.font = [UIFont boldSystemFontOfSize:17.0];
	notesTitleLabel.backgroundColor = [UIColor clearColor];
	notesTitleLabel.textColor = [UIColor blackColor];
	notesTitleLabel.textAlignment = UITextAlignmentLeft;
	notesTitleLabel.adjustsFontSizeToFitWidth = NO;
	notesTitleLabel.text = notesTitleStr;
	
	[notesTitleLabel sizeToFit];
	
	notesTitleFrame = notesTitleLabel.frame;
	
	// Setup Notes Label
	
	CGSize notesSize = [self.bookNotes sizeWithFont:[UIFont systemFontOfSize:13.0]
											  constrainedToSize:CGSizeMake(contentSize.width - 20.0, MAX_LABEL_HEIGHT)];
	
	CGRect notesFrame = CGRectMake(10.0,
								   notesTitleFrame.origin.y + notesTitleFrame.size.height + 10.0,
								   contentSize.width - 20.0,
								   notesSize.height);
	
	self.notesLabel = [[UILabel alloc] initWithFrame:notesFrame];
	self.notesLabel.font = [UIFont systemFontOfSize:13.0];
	self.notesLabel.backgroundColor = [UIColor clearColor];
	self.notesLabel.textColor = [UIColor blackColor];
	self.notesLabel.textAlignment = UITextAlignmentLeft;
	self.notesLabel.numberOfLines = 0;
	self.notesLabel.lineBreakMode = UILineBreakModeWordWrap;
	self.notesLabel.adjustsFontSizeToFitWidth = NO;
	self.notesLabel.text = self.bookNotes;
	
	// Setup Autoresizing
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
		titleDivider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
		descDivider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.notesLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|
											UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	}
	
	// Add Subviews
	
	[self.scrollView addSubview:self.titleLabel];
	[self.scrollView addSubview:titleDivider];
	[self.scrollView addSubview:self.descriptionLabel];
	[self.scrollView addSubview:self.lastUpdatedLabel];
	[self.scrollView addSubview:descDivider];
	[self.scrollView addSubview:notesTitleLabel];
	[self.scrollView addSubview:self.notesLabel];
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
		// The iPad version uses a Popover. No rotation required.
	    return NO;
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		[self adjustContentSize];
	}
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	self.delegate = nil;
	self.scrollView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self adjustContentSize];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	self.modalInPopover = YES;
}

#pragma mark - Selector Actions

- (void)dismissAction:(id)sender
{
	[self.delegate detailsViewControllerDidFinish:self];
}

#pragma mark - Private Methods

- (void)adjustContentSize
{
	CGFloat endY = self.notesLabel.frame.origin.y + self.notesLabel.frame.size.height;
	
	CGSize scrollViewSize = self.view.bounds.size;
	if (endY >= self.view.bounds.size.height) {
		scrollViewSize = CGSizeMake(self.view.bounds.size.width, endY + 10.0);
	}
	self.scrollView.contentSize = scrollViewSize;
}

@end
