//
//  SearchViewController.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 1/3/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSArray *searchDataSource;

@end
