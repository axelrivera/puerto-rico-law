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
{
	UIFont *textFont_;
	UIFont *detailFont_;
	UIFont *subtextFont_;
	UIFont *subtitleFont_;
}

@synthesize subtextLabel = subtextLabel_;
@synthesize subtitleTextLabel = subtitleTextLabel_;

- (id)initWithRLStyle:(RLTableCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	// The Style will be ignored
    self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseIdentifier];
    if (self) {
		textFont_ = [UIFont boldSystemFontOfSize:13.0];
		detailFont_ = [UIFont boldSystemFontOfSize:13.0];
		subtextFont_ = [UIFont systemFontOfSize:13.0];
		
		self.textLabel.font = textFont_;
		self.textLabel.minimumFontSize = 10.0;
		self.textLabel.adjustsFontSizeToFitWidth = YES;
		self.textLabel.textAlignment = UITextAlignmentLeft;
		self.detailTextLabel.font = detailFont_;
		self.detailTextLabel.numberOfLines = 2.0;
		self.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
		
		subtextLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
		subtextLabel_.font = subtextFont_;
		subtextLabel_.minimumFontSize = 10.0;
		subtextLabel_.adjustsFontSizeToFitWidth = YES;
		subtextLabel_.textAlignment = UITextAlignmentRight;
		subtextLabel_.backgroundColor = [UIColor clearColor];
		subtextLabel_.textColor = [UIColor lightGrayColor	];
		subtextLabel_.highlightedTextColor = [UIColor whiteColor];
		subtextLabel_.numberOfLines = 1;
		subtextLabel_.lineBreakMode = UILineBreakModeTailTruncation;
		subtextLabel_.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
		[self.contentView addSubview:subtextLabel_];
		
		subtitleTextLabel_ = nil;
		if (style == RLTableCellStyleSectionSubtitle) {
			subtitleFont_ = [UIFont systemFontOfSize:13.0];
			
			subtitleTextLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
			subtitleTextLabel_.font = subtextFont_;
			subtitleTextLabel_.textAlignment = UITextAlignmentLeft;
			subtitleTextLabel_.backgroundColor = [UIColor clearColor];
			subtitleTextLabel_.textColor = [UIColor lightGrayColor];
			subtitleTextLabel_.highlightedTextColor = [UIColor whiteColor];
			subtitleTextLabel_.numberOfLines = 1;
			subtitleTextLabel_.lineBreakMode = UILineBreakModeTailTruncation;
			subtitleTextLabel_.adjustsFontSizeToFitWidth = NO;
			subtitleTextLabel_.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
			[self.contentView addSubview:subtitleTextLabel_];
		}		
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

#define kTextHeight 17.0
#define kTextDetailHeight 34.0
#define kSubtitleTextHeight 17.0
#define kVerticalOffset 3.0
	
	CGRect textFrame;
	CGRect detailFrame;
	CGRect subtextFrame;
	
	CGFloat contentWidth = self.contentView.frame.size.width;
	
	// Padding between textFrame and subtextFrame is 6.0. When positioning either one in the x-axis
	// only 3.0 is used since we are using the center as the reference
	textFrame = CGRectMake(10.0,
						   3.0,
						   (contentWidth / 2.0) - (10.0 + 3.0),
						   kTextHeight);
	
	subtextFrame = CGRectMake(10.0 + textFrame.size.width + 6.0,
							  3.0,
							  (contentWidth / 2.0) - (10.0 + 3.0),
							  kTextHeight);
	
	NSString *detailStr = self.detailTextLabel.text;
	CGSize detailSize = [detailStr sizeWithFont:detailFont_
							  constrainedToSize:CGSizeMake(contentWidth - 20.0, kTextDetailHeight)
								  lineBreakMode:UILineBreakModeTailTruncation];
	detailFrame = CGRectMake(10.0,
							 3.0 + kTextHeight + kVerticalOffset,
							 contentWidth - 20.0,
							 detailSize.height);
	
	self.textLabel.frame = textFrame;	
	self.detailTextLabel.frame = detailFrame;
	self.subtextLabel.frame = subtextFrame;
	
	if (self.subtitleTextLabel != nil) {
		CGRect subtitleFrame = CGRectMake(10.0,
										  detailFrame.origin.y + detailFrame.size.height,
										  contentWidth - 20.0,
										  kSubtitleTextHeight);
		self.subtitleTextLabel.frame = subtitleFrame;
	}
}

@end
