//
//  UIViewController+Section.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/31/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoritesViewController.h"

@class Section;

@interface UIViewController (Section)

+ (NSDateFormatter *)dateFormatter;

- (NSArray *)sectionToolbarItems;
- (NSArray *)searchToolbarItems;
- (void)reloadControllerWithSection:(Section *)section;

- (void)goHome;
- (void)goHomeAnimated:(BOOL)animated;

@end
