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

@interface SectionListViewController : UITableViewController

@property (weak, nonatomic) Book *book;
@property (weak, nonatomic) Section *section;

@end
