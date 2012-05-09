//
//  FavoritesViewController.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	FavoritesTypeSection,
	FavoritesTypeBook
} FavoritesType;

@protocol FavoritesViewControllerDelegate;

@interface FavoritesViewController : UITableViewController <UIActionSheetDelegate>

@property (unsafe_unretained, nonatomic) id <FavoritesViewControllerDelegate> delegate;
@property (assign, readonly, nonatomic) FavoritesType favoritesType;
@property (strong, nonatomic) NSMutableArray *favoritesDataSource;
@property (strong, nonatomic) id selection;

- (id)initWithFavoritesType:(FavoritesType)type;

@end

@protocol FavoritesViewControllerDelegate <NSObject>

- (void)favoritesViewControllerDidFinish:(FavoritesViewController *)controller save:(BOOL)save;
- (void)favoritesViewControllerDeleteDataSource:(FavoritesViewController *)controller;
- (void)favoritesViewController:(FavoritesViewController *)controller deleteRowAtIndexPath:(NSIndexPath *)indexPath;

@end
