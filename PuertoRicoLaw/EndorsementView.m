//
//  EndorsementView.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 3/1/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import "EndorsementView.h"

@implementation EndorsementView

@synthesize titleLabel = titleLabel_;
@synthesize imageView = imageView_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
				
		self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		self.titleLabel.backgroundColor = [UIColor clearColor];
		self.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
		self.titleLabel.textAlignment = UITextAlignmentCenter;
		self.titleLabel.textColor = [UIColor darkGrayColor];
		self.titleLabel.shadowColor = [UIColor whiteColor];
		self.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		self.titleLabel.numberOfLines = 2;
		self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
		self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.titleLabel.text = @"Endosado por el Colegio de Abogados de Puerto Rico";
		[self addSubview:self.titleLabel];
		
		self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"abogados_logo.png"]];
		[self addSubview:self.imageView];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	self.titleLabel.frame = CGRectMake(0.0, 0.0, self.frame.size.width, 42.0);
	
	CGRect imageFrame = self.imageView.frame;
	self.imageView.frame = CGRectMake((self.frame.size.width / 2.0) - (imageFrame.size.width / 2.0),
									  52.0,
									  imageFrame.size.width,
									  imageFrame.size.height);
	
}

@end
