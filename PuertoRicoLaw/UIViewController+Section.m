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

@implementation UIViewController (Section)

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
	
	UIBarButtonItem *position4 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star.png"]
																	  style:UIBarButtonItemStylePlain
																	 target:self
																	 action:@selector(favoritesAction:)];
	
	UIBarButtonItem *position5 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																			   target:self
																			   action:@selector(optionsAction:)];
	
	return [NSArray arrayWithObjects:
			fixedItem,
			position1,
			flexibleItem,
			position2,
			flexibleItem,
			position3,
			flexibleItem,
			position4,
			flexibleItem,
			position5,
			fixedItem,
			nil];
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
			SectionListViewController *sectionController =
			[[SectionListViewController alloc] initWithSection:mySection
													dataSource:mySection.children
											   siblingSections:mySection.parent.children
										   currentSiblingIndex:[mySection indexPositionAtParent]];
			sectionController.title = mySection.label;
			[viewControllers addObject:sectionController];
		}
	}
	[self.navigationController setViewControllers:viewControllers animated:NO];
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
