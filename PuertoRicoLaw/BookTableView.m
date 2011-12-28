//
//  BookTableView.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/22/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "BookTableView.h"

@interface BookTableView (Private)

- (void)checkAndLoadFavoriteImage;
- (void)loadBookFavoriteImageForType:(BookFavoriteType)type;

@end

@implementation BookTableView

@synthesize textLabel = textLabel_;
@synthesize detailTextLabel = detailTextLabel_;
@synthesize contentView = contentView_;
@synthesize imageView = imageView_;
@synthesize favorite = favorite_;
@synthesize editing = editing_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		
		favorite_ = NO;
		editing_ = NO;
		
		contentView_ = [[UIView alloc] initWithFrame:CGRectZero];
		contentView_.backgroundColor = [UIColor clearColor];
		contentView_.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
		[self addSubview:contentView_];
		
		imageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
		[contentView_ addSubview:imageView_];
		
        textLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
		textLabel_.font = [UIFont boldSystemFontOfSize:14.0];
		textLabel_.backgroundColor = [UIColor clearColor];
		textLabel_.textAlignment = UITextAlignmentLeft;
		textLabel_.textColor = [UIColor blackColor];
		textLabel_.highlightedTextColor = [UIColor whiteColor];
		textLabel_.numberOfLines = 2;
		textLabel_.lineBreakMode = UILineBreakModeWordWrap;
		textLabel_.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
		[contentView_ addSubview:textLabel_];
		
		detailTextLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
		detailTextLabel_.font = [UIFont italicSystemFontOfSize:14.0]; 
		detailTextLabel_.textAlignment = UITextAlignmentLeft;
		detailTextLabel_.backgroundColor = [UIColor clearColor];
		detailTextLabel_.textColor = [UIColor lightGrayColor];
		detailTextLabel_.highlightedTextColor = [UIColor whiteColor];
		detailTextLabel_.numberOfLines = 1;
		detailTextLabel_.lineBreakMode = UILineBreakModeTailTruncation;
		detailTextLabel_.minimumFontSize = 12.0;
		detailTextLabel_.adjustsFontSizeToFitWidth = YES;
		detailTextLabel_.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
		[contentView_ addSubview:detailTextLabel_];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

#define kImageViewWidthHeight 13.0
#define kTextLabelHeight 34.0
#define kDetailTextLabelHeight 16.0
	
	contentView_.frame = CGRectMake(10.0,
									(self.bounds.size.height / 2.0) - ((kTextLabelHeight + kDetailTextLabelHeight) / 2.0),
									self.bounds.size.width - 20.0,
									kTextLabelHeight + kDetailTextLabelHeight);
	
	imageView_.frame = CGRectMake(0.0,
								  (contentView_.frame.size.height / 2.0) - (kImageViewWidthHeight / 2.0),
								  kImageViewWidthHeight,
								  kImageViewWidthHeight);
	
	textLabel_.frame = CGRectMake(kImageViewWidthHeight + 10.0,
								  0.0,
								  contentView_.bounds.size.width - (kImageViewWidthHeight + 10.0),
								  kTextLabelHeight);
	
	detailTextLabel_.frame = CGRectMake(kImageViewWidthHeight + 10.0,
										kTextLabelHeight,
										contentView_.bounds.size.width - (kImageViewWidthHeight + 10.0),
										kDetailTextLabelHeight);
}

- (void)setFavorite:(BOOL)favorite
{
	favorite_ = favorite;
	[self checkAndLoadFavoriteImage];
}

- (void)setEditing:(BOOL)editing
{
	editing_ = editing;
	[self checkAndLoadFavoriteImage];
}

- (void)checkAndLoadFavoriteImage
{
	if (self.isEditing) {
		if (self.isFavorite) {
			[self loadBookFavoriteImageForType:BookFavoriteTypeEnabled];
		} else {
			[self loadBookFavoriteImageForType:BookFavoriteTypeDisabled];
		}
	} else {
		if (self.isFavorite) {
			[self loadBookFavoriteImageForType:BookFavoriteTypeEnabled];
		} else {
			[self loadBookFavoriteImageForType:BookFavoriteTypeNone];
		}
	}
}

- (void)loadBookFavoriteImageForType:(BookFavoriteType)type
{
	NSString *imageStr = nil;
	switch (type) {
		case BookFavoriteTypeEnabled:
			imageStr = @"star_cell_selected.png";
			break;
		case BookFavoriteTypeDisabled:
			imageStr = @"star_cell.png";
			break;
		default:
			break;
	}
	self.imageView.image = [UIImage imageNamed:imageStr];
}

@end
