//
//  SectionContentViewController.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoritesViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "SectionSelectionDelegate.h"

@class Section;
@class SectionManager;

@interface SectionContentViewController : UIViewController
<SectionSelectionDelegate, FavoritesViewControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UISplitViewControllerDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) SectionManager *manager;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (id)initWithSection:(Section *)section siblingSections:(NSArray *)siblings currentSiblingIndex:(NSInteger)index;

@end
