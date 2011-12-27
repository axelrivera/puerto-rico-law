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

@interface FavoritesViewController : UITableViewController

@property (assign, readonly, nonatomic) FavoritesType favoritesType;
@property (strong, nonatomic) NSMutableArray *favoritesDataSource;

- (id)initWithFavoritesType:(FavoritesType)type;

@end
