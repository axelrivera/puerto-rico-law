//
//  SectionListViewController.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoritesViewController.h"

@class Book;
@class Section;

@interface SectionListViewController : UITableViewController <FavoritesViewControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) Section *section;
@property (strong, nonatomic) NSArray *sectionDataSource;
@property (strong, nonatomic) NSArray *siblingSections;
@property (assign, nonatomic) NSInteger currentSiblingSectionIndex;

@end
