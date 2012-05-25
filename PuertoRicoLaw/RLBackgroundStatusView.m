//
//  RLBackgroundStatusView.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 5/13/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import "RLBackgroundStatusView.h"

#define kActivityIndicatorWidth 20.0
#define kActivityIndicatorHeight 20.0

@implementation RLBackgroundStatusView

@synthesize showing = showing_;
@synthesize indicator = indicator_;
@synthesize title = title_;
@synthesize contentView = contentView_;
@synthesize activityIndicator = activityIndicator_;
@synthesize textLabel = textLabel_;

- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
		self.opaque = YES;
		
		self.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
		
		self.backgroundColor = [UIColor whiteColor];
		
		[self setTitle:@"Loading..." indicator:YES];
		
        contentView_ = [[UIView alloc] initWithFrame:CGRectZero];
		[self addSubview:contentView_];
		
		activityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		activityIndicator_.hidesWhenStopped = YES;
		[activityIndicator_ startAnimating];
		[contentView_ addSubview:activityIndicator_];
		
		textLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
		textLabel_.backgroundColor = [UIColor clearColor];
		textLabel_.font = [UIFont boldSystemFontOfSize:14.0];
		textLabel_.textColor = [UIColor darkGrayColor];
		textLabel_.textAlignment = UITextAlignmentLeft;
		textLabel_.numberOfLines = 1;
		textLabel_.lineBreakMode = UILineBreakModeTailTruncation;
		//textLabel_.shadowColor = [UIColor whiteColor];
		//textLabel_.shadowOffset = CGSizeMake(0.0, 1.0);
		textLabel_.text = title_;
		[contentView_ addSubview:textLabel_];
		
		[self hide];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
	[self setTitle:title indicator:NO];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
#define kHorizontalPadding 5.0
	
	CGRect bgFrame = self.bounds;
	CGRect contentFrame;
	
	CGFloat contentWidth = 0.0;
	CGFloat activityWidth = 0.0;
	CGFloat activityPadding = 0.0;
	
	if (self.hasIndicator) {
		CGRect activityFrame;
		activityWidth = kActivityIndicatorWidth;
		activityPadding = kHorizontalPadding;
		activityFrame = CGRectMake(0.0, 0.0, kActivityIndicatorWidth, kActivityIndicatorHeight);
		self.activityIndicator.frame = activityFrame;
	}
	
	if (self.title) {
		CGRect textFrame;
		CGSize textSize = [self.title sizeWithFont:self.textLabel.font];
		CGFloat maxTextWidth = self.hasIndicator ? kActivityIndicatorWidth + 20.0 : 20.0;
		CGFloat cappedWidth = bgFrame.size.width - maxTextWidth;
		CGFloat textWidth = textSize.width > cappedWidth ? cappedWidth : textSize.width;
		
		textFrame = CGRectMake(0.0 + activityWidth + activityPadding,
							   0.0,
							   textWidth,
							   kActivityIndicatorHeight);
		self.textLabel.frame = textFrame;
		
		contentWidth = activityWidth + activityPadding + textWidth;
	}
	
	contentFrame = CGRectMake((bgFrame.size.width / 2.0) - (contentWidth / 2.0),
							  (bgFrame.size.height / 2.0) - (kActivityIndicatorHeight / 2.0),
							  contentWidth,
							  kActivityIndicatorHeight);
	self.contentView.frame = contentFrame;
}

#pragma mark - Custom Methods

- (void)setTitle:(NSString *)title indicator:(BOOL)indicator
{
	title_ = title;
	indicator_ = indicator;
	textLabel_.text = title;
	
	if (self.hasIndicator) {
		self.activityIndicator.alpha = 1.0;
	} else {
		self.activityIndicator.alpha = 0.0;
	}
	[self setNeedsLayout];
}

- (void)show
{
	showing_ = YES;
	
	// Making sure I'm on top
	[self.superview bringSubviewToFront:self];
	
	CGRect visibleRect = self.superview.bounds;
	
	if ([self.superview isKindOfClass:[UIScrollView class]]) {
		UIScrollView *scrollView = (UIScrollView *)self.superview;
		[scrollView setScrollEnabled:NO];
		
		// Kill the Scroller
		CGPoint offset = scrollView.contentOffset;
		[scrollView setContentOffset:offset animated:NO];
		
		visibleRect.origin = scrollView.contentOffset;
		visibleRect.size = scrollView.bounds.size;
		CGFloat scale = 1.0 / scrollView.zoomScale;
		visibleRect.origin.x *= scale;
		visibleRect.origin.y *= scale;
		visibleRect.size.width *= scale;
		visibleRect.size.height *= scale;
	}
	
	self.frame = visibleRect;
	[self setNeedsLayout];
	
	[UIView animateWithDuration:0.1 animations:^{
		[activityIndicator_ startAnimating];
		self.alpha = 1.0;
	}];
}

- (void)hide
{
	showing_ = NO;
	[UIView animateWithDuration:0.1 animations:^{
		[activityIndicator_ stopAnimating];
		self.alpha = 0.0;
	}];
	
	[self.superview sendSubviewToBack:self];
	
	if ([self.superview isKindOfClass:[UIScrollView class]]) {
		[(UIScrollView *)self.superview setScrollEnabled:YES];
	}
}

@end
