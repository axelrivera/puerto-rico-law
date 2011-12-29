//
//  TableSelectViewController.h
//  TipCalculator
//
//  Created by Axel Rivera on 11/3/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TableSelectViewControllerDelegate;

@interface TableSelectViewController : UITableViewController

@property (unsafe_unretained, nonatomic) id <TableSelectViewControllerDelegate> delegate;
@property (assign, nonatomic) NSInteger selectID;
@property (assign, nonatomic) NSInteger currentIndex;
@property (strong, nonatomic) NSArray *tableData;
@property (copy, nonatomic) NSString *tableHeaderTitle;
@property (copy, nonatomic) NSString *tableFooterTitle;

@end

@protocol TableSelectViewControllerDelegate

- (void)tableSelectViewControllerDidFinish:(TableSelectViewController *)controller;

@end
