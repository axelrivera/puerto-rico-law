//
//  DownloadTableViewCellCell.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 5/9/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadTableViewCell : UITableViewCell

@property (strong, readonly, nonatomic) UIButton *downloadButton;
@property (strong, readonly, nonatomic) UILabel *downloadLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
