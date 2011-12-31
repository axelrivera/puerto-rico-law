//
//  SectionManager.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/31/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Section;
@class SectionListViewController;
@class SectionContentViewController;

@interface SectionManager : NSObject

@property (strong, nonatomic) Section *section;
@property (strong, nonatomic) NSArray *siblings;
@property (assign, nonatomic) NSInteger currentIndex;
@property (assign, nonatomic) NSInteger favoriteIndex;
@property (unsafe_unretained, nonatomic) UIBarButtonItem *nextItem;
@property (unsafe_unretained, nonatomic) UIBarButtonItem *prevItem;
@property (unsafe_unretained, nonatomic) id controller;

- (id)initWithSection:(Section *)section siblings:(NSArray *)siblings currentIndex:(NSInteger)currentIndex;

- (void)reloadContentWithCurrentIndex;
- (void)checkItemsAndUpdateFavoriteIndex;
- (void)checkGoNextItem;
- (BOOL)canGoNext;
- (void)checkGoPrevItem;
- (BOOL)canGoPrev;

- (void)updateFavoriteIndex;
- (void)addToFavorites;
- (void)removeFromFavorites;

@end
