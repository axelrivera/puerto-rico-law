//
//  SettingsViewController.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableSelectViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UITableViewController <TableSelectViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (unsafe_unretained, nonatomic) id <SettingsViewControllerDelegate> delegate;
@property (strong, nonatomic) UIButton *upgradeButton;

@end

@protocol SettingsViewControllerDelegate

- (void)settingsViewControllerDidFinish:(UIViewController *)controller;

@end
