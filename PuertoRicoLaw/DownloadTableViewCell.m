//
//  DownloadTableViewCellCell.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 5/9/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import "DownloadTableViewCell.h"

@interface DownloadTableViewCell (Private)

@property (strong, readwrite, nonatomic) UILabel *textLabel;
@property (strong, readwrite, nonatomic) UILabel *detailTextLabel;
@property (strong, readwrite, nonatomic) UIButton *downloadButton;
@property (strong, readwrite, nonatomic) UILabel *downloadLabel;

@end

@implementation DownloadTableViewCell
{
	UIFont *textFont_;
	UIFont *detailFont_;
	UIFont *downloadFont_;
}

@synthesize downloadButton = downloadButton_;
@synthesize downloadLabel = downloadLabel_;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	self = [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
	if (self) {
		textFont_ = [UIFont boldSystemFontOfSize:13.0];
		detailFont_ = [UIFont systemFontOfSize:13.0];
		downloadFont_ = [UIFont boldSystemFontOfSize:10.0];
		
		self.textLabel.font = textFont_;
		self.textLabel.numberOfLines = 2.0;
		self.textLabel.textAlignment = UITextAlignmentLeft;
		self.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
		self.detailTextLabel.font = detailFont_;
		self.detailTextLabel.minimumFontSize = 10.0;
		self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		self.detailTextLabel.textAlignment = UITextAlignmentLeft;
		self.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
		
		downloadButton_ = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[downloadButton_ setTitle:@"My Button" forState:UIControlStateNormal];
		downloadLabel_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[self.contentView addSubview:downloadButton_];
		
		downloadLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
		downloadLabel_.font = downloadFont_;
		downloadLabel_.minimumFontSize = 9.0;
		downloadLabel_.adjustsFontSizeToFitWidth = YES;
		downloadLabel_.textAlignment = UITextAlignmentCenter;
		downloadLabel_.lineBreakMode = UILineBreakModeTailTruncation;
		downloadLabel_.textColor = [UIColor darkGrayColor];
		downloadLabel_.backgroundColor = [UIColor whiteColor];
		downloadLabel_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[self.contentView addSubview:downloadLabel_];
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

#define kTextHeight 34.0
#define kDetailTextHeight 17.0
#define kDownloadButtonWidth 80.0
#define kDownloadButtonHeight 37.0
#define kDownloadTextHeight 14.0
#define kVerticalOffset 3.0
#define kHorizontalOffset 5.0
	
	CGRect textFrame;
	CGRect detailFrame;
	CGRect buttonFrame;
	CGRect downloadFrame;
	
	CGFloat contentWidth = self.contentView.frame.size.width;
	
	textFrame = CGRectMake(10.0,
						   3.0,
						   contentWidth - (10.0 + kHorizontalOffset + kDownloadButtonWidth + 10.0),
						   kTextHeight);
	
	detailFrame = CGRectMake(10.0,
							 3.0 + kTextHeight + 3.0,
							 contentWidth - (10.0 + kHorizontalOffset + kDownloadButtonWidth + 10.0),
							 kDetailTextHeight);
	
	buttonFrame = CGRectMake(textFrame.origin.x + textFrame.size.width + kVerticalOffset,
							 3.0,
							 kDownloadButtonWidth,
							 kDownloadButtonHeight);
	
	downloadFrame = CGRectMake(textFrame.origin.x + textFrame.size.width,
							   3.0 + kDownloadButtonHeight + 3.0,
							   kDownloadButtonWidth,
							   kDownloadTextHeight);
	
	self.textLabel.frame = textFrame;
	self.detailTextLabel.frame = detailFrame;
	self.downloadButton.frame = buttonFrame;
	self.downloadLabel.frame = downloadFrame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
