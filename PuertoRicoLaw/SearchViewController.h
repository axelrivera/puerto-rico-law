//
//  SearchViewController.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 1/3/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UITableViewController

@property (unsafe_unretained, nonatomic) IBOutlet UISearchBar *searchBar;
@property (unsafe_unretained, nonatomic) IBOutlet UISearchDisplayController *searchController;

@end
