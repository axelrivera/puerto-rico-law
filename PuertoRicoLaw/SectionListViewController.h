//
//  SectionListViewController.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Book;
@class Section;

@interface SectionListViewController : UITableViewController <UIActionSheetDelegate>

@property (strong, nonatomic) Section *section;
@property (strong, nonatomic) NSArray *sectionDataSource;
@property (strong, nonatomic) NSArray *parentSections;
@property (assign, nonatomic) NSInteger currentSectionIndex;

@end
