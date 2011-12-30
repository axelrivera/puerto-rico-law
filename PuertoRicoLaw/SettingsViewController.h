//
//  SettingsViewController.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableSelectViewController.h"

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UITableViewController <TableSelectViewControllerDelegate>

@property (unsafe_unretained, nonatomic) id <SettingsViewControllerDelegate> delegate;

@end

@protocol SettingsViewControllerDelegate

- (void)settingsViewControllerDidFinish:(UIViewController *)controller;

@end
