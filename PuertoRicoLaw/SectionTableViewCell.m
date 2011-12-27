//
//  SectionTableViewCell.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/24/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "SectionTableViewCell.h"

@interface SectionTableViewCell (Private)

@property (strong, readwrite, nonatomic) UILabel *textLabel;
@property (strong, readwrite, nonatomic) UILabel *detailTextLabel;

@end

@implementation SectionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	// The Style will be ignored
    self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseIdentifier];
    if (self) {
		self.textLabel.font = [UIFont boldSystemFontOfSize:12.0];
		self.textLabel.minimumFontSize = 10.0;
		self.textLabel.adjustsFontSizeToFitWidth = YES;
		self.detailTextLabel.font = [UIFont boldSystemFontOfSize:13.0];
		self.detailTextLabel.numberOfLines = 2.0;
		self.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

#define kTextWidth 70.0
#define kTextDetailHeight 30.0
	
	self.textLabel.frame = CGRectMake(10.0,
									  (self.contentView.bounds.size.height / 2.0) - (kTextDetailHeight / 2.0),
									  kTextWidth,
									  kTextDetailHeight);
	
	self.detailTextLabel.frame = CGRectMake(10.0 + kTextWidth + 10.0,
											(self.contentView.bounds.size.height / 2.0) - (kTextDetailHeight / 2.0),
											self.contentView.bounds.size.width - (10.0 + kTextWidth + 10.0 + 10.0),
											kTextDetailHeight);
}

@end
