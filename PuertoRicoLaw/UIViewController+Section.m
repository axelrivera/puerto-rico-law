//
//  UIViewController+Section.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/31/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "UIViewController+Section.h"
#import "SectionManager.h"
#import "Section.h"
#import "SectionListViewController.h"
#import "SectionContentViewController.h"

static NSDateFormatter *dateFormatter_;

@implementation UIViewController (Section)

+ (NSDateFormatter *)dateFormatter
{
	if (dateFormatter_ == nil) {
		NSLocale *spanishLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"es_ES"];
		dateFormatter_ = [[NSDateFormatter alloc] init];
		dateFormatter_.locale = spanishLocale;
		dateFormatter_.timeStyle = NSDateFormatterNoStyle;
		dateFormatter_.dateStyle = NSDateFormatterLongStyle;
	}
	return dateFormatter_;
}

- (NSArray *)sectionToolbarItems
{	
	CGFloat fixedWidth = 0.0;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		fixedWidth = 100.0;
	}
	
	UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
																			   target:nil
																			   action:nil];
	fixedItem.width = fixedWidth;
	
	UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				  target:nil
																				  action:nil];
	
	UIBarButtonItem *position1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"orgchart.png"]
													style:UIBarButtonItemStylePlain
												   target:self
												   action:@selector(homeAction:)];
		
	UIBarButtonItem *position2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_arrow.png"]
																 style:UIBarButtonItemStylePlain
																target:self
																action:@selector(prevAction:)];
	
	UIBarButtonItem *position3 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"right_arrow.png"]
																 style:UIBarButtonItemStylePlain
																target:self
																action:@selector(nextAction:)];
	
	UIBarButtonItem *position4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																			   target:self
																			   action:@selector(optionsAction:)];
	
	UIBarButtonItem *position5 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star.png"]
																  style:UIBarButtonItemStylePlain
																 target:self
																 action:@selector(favoritesAction:)];
	
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
	
	[array addObject:fixedItem];
	[array addObject:position1];
	[array addObject:flexibleItem];
	[array addObject:position2];
	[array addObject:flexibleItem];
	[array addObject:position3];
	[array addObject:flexibleItem];
	[array addObject:position4];
	[array addObject:flexibleItem];
	[array addObject:position5];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		UIBarButtonItem *position6 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info.png"]
																	  style:UIBarButtonItemStylePlain
																	 target:self
																	 action:@selector(detailsAction:)];
		[array addObject:flexibleItem];
		[array addObject:position6];
	}
	
	[array addObject:fixedItem];
	
	return array;
}

- (NSArray *)searchToolbarItems
{
	CGFloat fixedWidth = 0.0;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		fixedWidth = 100.0;
	}
	
	UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
																			   target:nil
																			   action:nil];
	fixedItem.width = fixedWidth;
	
	UIBarButtonItem *position1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"orgchart.png"]
																  style:UIBarButtonItemStylePlain
																 target:self
																 action:@selector(homeAction:)];
	
	return [NSArray arrayWithObjects:fixedItem, position1, nil];
}

- (void)reloadControllerWithSection:(Section *)section
{
	NSMutableArray *reversedSections = [[NSMutableArray alloc] initWithCapacity:0];
	NSMutableArray *orderedSections = [[NSMutableArray alloc] initWithCapacity:0];
	
	Section *tmpSection = section;
	while (tmpSection != nil) {
		[reversedSections addObject:tmpSection];
		tmpSection = tmpSection.parent;
	}
	
	NSEnumerator *reverseEnumerator = [reversedSections reverseObjectEnumerator];
	id object;
	while (object = [reverseEnumerator nextObject]) {
		[orderedSections addObject:object];
	}
	
	NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:0];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		[viewControllers addObject:[self.navigationController.viewControllers objectAtIndex:0]];
	}
	
	for (Section *mySection in orderedSections) {
		if (mySection.children == nil) {
			SectionContentViewController *contentController =
			[[SectionContentViewController alloc] initWithSection:mySection
												  siblingSections:mySection.parent.children
											  currentSiblingIndex:[mySection indexPositionAtParent]];
			contentController.title = mySection.label;
			[viewControllers addObject:contentController];
		} else {
			if (!(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && mySection.parent == nil)) {
				SectionListViewController *sectionController =
				[[SectionListViewController alloc] initWithSection:mySection
														dataSource:mySection.children
												   siblingSections:mySection.parent.children
											   currentSiblingIndex:[mySection indexPositionAtParent]];
				sectionController.title = mySection.label;
				[viewControllers addObject:sectionController];
			}
		}
	}
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// The first object is the same for all
		id currentRootController =
			[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
		[viewControllers insertObject:currentRootController atIndex:0];
		[self.navigationController setViewControllers:viewControllers animated:NO];
	} else {
		[self.navigationController setViewControllers:viewControllers animated:NO];
	}
}

- (void)goHome
{
	[self goHomeAnimated:YES];
}

- (void)goHomeAnimated:(BOOL)animated
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.navigationController popToRootViewControllerAnimated:animated];
		return;
	}
	UIViewController *controller = [[self.navigationController viewControllers] objectAtIndex:1];
	[self.navigationController popToViewController:controller animated:animated];
}

@end
