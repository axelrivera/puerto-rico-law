//
//  DownloadsViewController.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 5/8/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookData.h"

@protocol DownloadsViewControllerDelegate;

@interface DownloadsViewController : UITableViewController <BookDataUpdateDelegate>

@property (unsafe_unretained, nonatomic) id <DownloadsViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@protocol DownloadsViewControllerDelegate <NSObject>

- (void)downloadsViewControllerDidFinish:(UIViewController *)controller;

@end
