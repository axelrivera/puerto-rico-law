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

@class Section;

@interface SectionContentViewController : UIViewController
<FavoritesViewControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UISplitViewControllerDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) Section *section;
@property (strong, nonatomic) NSArray *siblingSections;
@property (assign, nonatomic) NSInteger currentSiblingSectionIndex;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end
