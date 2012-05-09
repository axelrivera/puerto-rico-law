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
#import "BookData.h"

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UITableViewController
<BookDataUpdateDelegate, TableSelectViewControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (unsafe_unretained, nonatomic) id <SettingsViewControllerDelegate> delegate;
@property (strong, nonatomic) UIButton *updateButton;

@end

@protocol SettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerDidFinish:(UIViewController *)controller;

@end
