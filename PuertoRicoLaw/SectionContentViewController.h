//
//  SectionContentViewController.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionSelectionDelegate.h"

@class Section;
@class SectionManager;

@interface SectionContentViewController : UIViewController <SectionSelectionDelegate, UISplitViewControllerDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) SectionManager *manager;
@property (strong, nonatomic) NSString *fileContentStr;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (id)initWithSection:(Section *)section siblingSections:(NSArray *)siblings currentSiblingIndex:(NSInteger)index;

- (NSString *)htmlStringForSection;
- (NSString *)htmlStringForEmail;
- (NSString *)fileContentString;
- (void)refresh;

@end
