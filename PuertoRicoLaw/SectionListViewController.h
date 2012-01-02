//
//  SectionListViewController.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionSelectionDelegate.h"

@class Book;
@class Section;
@class SectionManager;
@class SectionContentViewController;

@interface SectionListViewController : UITableViewController <SectionSelectionDelegate, UISplitViewControllerDelegate>

@property (strong, nonatomic) SectionManager *manager;
@property (strong, nonatomic) NSArray *sectionDataSource;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;


- (id)initWithSection:(Section *)section
		   dataSource:(NSArray *)data
	  siblingSections:(NSArray *)siblings
  currentSiblingIndex:(NSInteger)index;

- (void)refresh;

@end
