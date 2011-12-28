//
//  FavoritesSectionTableViewCell.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/27/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "FavoritesSectionTableViewCell.h"

@interface FavoritesSectionTableViewCell (Private)

@property (strong, readwrite, nonatomic) UIView *contentView;
@property (strong, readwrite, nonatomic) UILabel *textLabel;
@property (strong, readwrite, nonatomic) UILabel *detailTextLabel;

@end

@implementation FavoritesSectionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	// The Style will be ignored
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
		self.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
		self.textLabel.numberOfLines = 2;
		self.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
		self.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
		self.detailTextLabel.numberOfLines = 1;
		self.detailTextLabel.minimumFontSize = 12.0;
		self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		self.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
#define kTextHeight 34.0
#define kDetailTextHeight 16.0
	
	CGRect contentFrame = self.contentView.bounds;
	CGFloat contentHeight = kTextHeight + kDetailTextHeight;
	
	self.contentView.frame = CGRectMake(contentFrame.origin.x,
										(self.bounds.size.height / 2.0) - (contentHeight / 2.0),
										contentFrame.size.width,
										contentHeight);
	
	self.textLabel.frame = CGRectMake(10.0,
									  0.0,
									  contentFrame.size.width - (10.0 + 10.0),
									  kTextHeight);
	
	self.detailTextLabel.frame = CGRectMake(10.0,
											kTextHeight,
											contentFrame.size.width - (10.0 + 10.0),
											kDetailTextHeight);
}

@end
