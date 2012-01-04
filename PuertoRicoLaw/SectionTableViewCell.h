//
//  SectionTableViewCell.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/24/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	RLTableCellStyleSection,
	RLTableCellStyleSectionSubtitle
} RLTableCellStyle;

@interface SectionTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *subtitleTextLabel;

- (id)initWithRLStyle:(RLTableCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
