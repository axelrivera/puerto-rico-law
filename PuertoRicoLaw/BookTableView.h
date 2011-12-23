//
//  BookTableView.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/22/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	BookFavoriteTypeNone,
	BookFavoriteTypeEnabled,
	BookFavoriteTypeDisabled
} BookFavoriteType;

@interface BookTableView : UIView

@property (strong, readonly, nonatomic) UILabel *textLabel;
@property (strong, readonly, nonatomic) UILabel *detailTextLabel;
@property (strong, readonly, nonatomic) UIView *contentView;
@property (strong, readonly, nonatomic) UIImageView *imageView;
@property (assign, nonatomic, getter = isEditing) BOOL editing;
@property (assign, nonatomic, getter = isFavorite) BOOL favorite;

@end
