//
//  BookTableViewCell.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/22/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BookTableView;

@interface BookTableViewCell : UITableViewCell

@property (strong, readonly, nonatomic) BookTableView *bookTableView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)saveBookTableView:(BookTableView *)bookTableView;
- (void)redisplay;

@end
