//
//  BookTableViewCell.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/22/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "BookTableViewCell.h"
#import "BookTableView.h"

@implementation BookTableViewCell

@synthesize bookTableView = bookTableView_;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{	
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		// Initialization Code
	}
	return self;
}

- (void)saveBookTableView:(BookTableView *)bookTableView
{
	[bookTableView_ removeFromSuperview];
	bookTableView_ = bookTableView;
	CGRect tvFrame = CGRectMake(0.0,
								0.0,
								self.contentView.bounds.size.width, self.contentView.bounds.size.height);
	bookTableView_.frame = tvFrame;
	bookTableView_.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	[self.contentView addSubview:bookTableView_];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	self.bookTableView.editing = editing;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)redisplay
{
	[self.bookTableView setNeedsDisplay];
}

@end
