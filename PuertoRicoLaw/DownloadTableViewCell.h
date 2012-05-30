//
//  DownloadTableViewCellCell.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 5/9/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RLCustomButton;

@interface DownloadTableViewCell : UITableViewCell

@property (strong, readonly, nonatomic) RLCustomButton *downloadButton;
@property (strong, readonly, nonatomic) UILabel *downloadLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
