//
//  BookViewController.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoritesViewController.h"
#import "SettingsViewController.h"
#import "SectionSelectionDelegate.h"
#import "BookDetailViewController.h"
#import "DownloadsViewController.h"

@interface BookViewController : UITableViewController
<DownloadsViewControllerDelegate, FavoritesViewControllerDelegate, SettingsViewControllerDelegate,
BookDetailViewControllerDelegate, UIActionSheetDelegate>

@property (unsafe_unretained, nonatomic) id <SectionSelectionDelegate> delegate;

- (void)handleBookUpdate:(id)notification;

@end
