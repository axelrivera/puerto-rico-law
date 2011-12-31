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
	
	UIBarButtonItem *favoritesItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star.png"]
																	  style:UIBarButtonItemStylePlain
																	 target:self
																	 action:@selector(favoritesAction:)];
	
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
			favoritesItem,
			flexibleItem,
			optionsItem,
			nil];
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
	[viewControllers addObject:[self.navigationController.viewControllers objectAtIndex:0]];
	
	for (Section *mySection in orderedSections) {
		if (mySection.children == nil) {
			SectionContentViewController *contentController =
			[[SectionContentViewController alloc] initWithSection:mySection
												  siblingSections:mySection.parent.children
											  currentSiblingIndex:[mySection indexPositionAtParent]];
			[viewControllers addObject:contentController];
		} else {
			SectionListViewController *sectionController =
			[[SectionListViewController alloc] initWithSection:mySection
													dataSource:mySection.children
											   siblingSections:mySection.parent.children
										   currentSiblingIndex:[mySection indexPositionAtParent]];
			[viewControllers addObject:sectionController];
		}
	}
	[self.navigationController setViewControllers:(NSArray *)viewControllers animated:YES];
}

@end
