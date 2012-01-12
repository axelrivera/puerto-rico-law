//
//  AppDelegate.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BookViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UISplitViewController *splitViewController;
@property (strong, nonatomic) BookViewController *bookViewController;
@property (assign, nonatomic) BOOL resetDataFlag;

- (void)archiveBookData;
- (void)resetData;
- (void)checkSettingsBundle;

@end
