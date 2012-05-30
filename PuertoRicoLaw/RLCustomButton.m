//
//  RLCustomButton.m
//
//  Created by Axel Rivera on 8/23/11.
//  Copyright 2011 Axel Rivera. All rights reserved.
//

#import "RLCustomButton.h"

@interface RLCustomButton (Private)

- (id)initCustomButton;

@end

@implementation RLCustomButton

+ (RLCustomButton *)customButton
{
	return [[RLCustomButton alloc] initCustomButton];
}

#pragma mark - Initialize Methods

- (id)initCustomButton
{
	self = [super initWithFrame:CGRectZero];
	if (self) {
		CALayer *layer = self.layer;
		
		layer.cornerRadius = 8.0f;
		layer.masksToBounds = YES;
		layer.borderWidth = 1.0f;
		layer.borderColor = [UIColor darkGrayColor].CGColor;
		
		gradientLayer_ = [CAGradientLayer layer];
		
		gradientLayer_.colors = [NSArray arrayWithObjects:
								 (id)[UIColor colorWithWhite:1.0f alpha:0.6f].CGColor,
								 (id)[UIColor colorWithWhite:1.0f alpha:0.4].CGColor,
								 (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
								 (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
								 (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
								 (id)[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f].CGColor,
								 nil];
		
		gradientLayer_.locations = [NSArray arrayWithObjects:
									[NSNumber numberWithFloat:0.0f],
									[NSNumber numberWithFloat:0.05f],
									[NSNumber numberWithFloat:0.5f],
									[NSNumber numberWithFloat:0.5f],
									[NSNumber numberWithFloat:0.8f],
									[NSNumber numberWithFloat:1.0f],
									nil];
		
		[self.layer addSublayer:gradientLayer_];
		
		highlightLayer_ = [CALayer layer];
		
		CGFloat colorValue = 65.0f / 255.0f;
		highlightLayer_.backgroundColor = [UIColor colorWithRed:colorValue green:colorValue blue:colorValue alpha:0.75f].CGColor;
		highlightLayer_.hidden = YES;
		
		[self.layer insertSublayer:highlightLayer_ below:gradientLayer_];
		
		// Bring Title Label to Top
		[self bringSubviewToFront:self.titleLabel];
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	gradientLayer_.frame = self.layer.bounds;
	highlightLayer_.frame = self.layer.bounds;
}

#pragma mark - Highlight button while touched

- (void)setHighlighted:(BOOL)highlight
{
	highlightLayer_.hidden = !highlight;
	[super setHighlighted:highlight];
}

@end
