//
//  DownloadsViewController.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 5/8/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DownloadsViewControllerDelegate;

@interface DownloadsViewController : UITableViewController

@property (unsafe_unretained, nonatomic) id <DownloadsViewControllerDelegate> delegate;

@end

@protocol DownloadsViewControllerDelegate <NSObject>

- (void)downloadsViewControllerDidFinish:(UIViewController *)controller;

@end
