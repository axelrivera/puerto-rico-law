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

@synthesize subtitleTextLabel = subtitleTextLabel_;

- (id)initWithRLStyle:(RLTableCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
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
		
		subtitleTextLabel_ = nil;
		if (style == RLTableCellStyleSectionSubtitle) {
			subtitleTextLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
			subtitleTextLabel_.font = [UIFont italicSystemFontOfSize:12.0]; 
			subtitleTextLabel_.textAlignment = UITextAlignmentLeft;
			subtitleTextLabel_.backgroundColor = [UIColor whiteColor];
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

#define kTextWidth 70.0
#define kTextIpadWidth 100.0
#define kTextDetailHeight 30.0
#define kSubtitleTextHeight 16.0
	
	CGRect textFrame;
	CGRect detailFrame;
	CGRect subtitleFrame;
	
	CGFloat textWidth = kTextWidth;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		textWidth = kTextIpadWidth;
	}
	
	if (self.subtitleTextLabel == nil) {
		textFrame = CGRectMake(10.0,
							   (self.contentView.frame.size.height / 2.0) - (kTextDetailHeight / 2.0),
							   textWidth,
							   kTextDetailHeight);
		
		detailFrame = CGRectMake(10.0 + textWidth + 10.0,
								 (self.contentView.frame.size.height / 2.0) - (kTextDetailHeight / 2.0),
								 self.contentView.frame.size.width - (10.0 + textWidth + 10.0 + 10.0),
								 kTextDetailHeight);
		
		subtitleFrame = CGRectZero;
	} else {
		textFrame = CGRectMake(10.0,
							   10.0,
							   textWidth,
							   kTextDetailHeight);
		
		detailFrame = CGRectMake(10.0 + textWidth + 5.0,
								 10.0,
								 self.contentView.frame.size.width - (10.0 + textWidth + 5.0 + 10.0),
								 kTextDetailHeight);
		
		subtitleFrame = CGRectMake(10.0,
								   10.0 + kTextDetailHeight,
								   self.contentView.frame.size.width - (10.0 + 10.0),
								   kSubtitleTextHeight);
		
	}
	
	self.textLabel.frame = textFrame;	
	self.detailTextLabel.frame = detailFrame;
	
	if (!CGRectEqualToRect(subtitleFrame, CGRectZero)) {
		self.subtitleTextLabel.frame = subtitleFrame;
	}

}

@end
