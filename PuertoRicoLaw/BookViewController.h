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

@interface BookViewController : UITableViewController
<FavoritesViewControllerDelegate, SettingsViewControllerDelegate, BookDetailViewControllerDelegate>

@property (unsafe_unretained, nonatomic) id <SectionSelectionDelegate> delegate;

- (void)handleBookUpdate:(id)notification;

@end
