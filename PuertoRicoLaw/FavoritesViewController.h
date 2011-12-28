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

@interface FavoritesViewController : UITableViewController

@property (unsafe_unretained, nonatomic) id <FavoritesViewControllerDelegate> delegate;
@property (assign, readonly, nonatomic) FavoritesType favoritesType;
@property (strong, nonatomic) NSMutableArray *favoritesDataSource;
@property (assign, nonatomic) id selection;

- (id)initWithFavoritesType:(FavoritesType)type;

@end

@protocol FavoritesViewControllerDelegate

- (void)favoritesViewControllerDidFinish:(FavoritesViewController *)controller save:(BOOL)save;

@end
