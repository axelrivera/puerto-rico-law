//
//  RLBackgroundStatusView.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 5/13/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLBackgroundStatusView : UIView

@property (assign, readonly, nonatomic, getter=isShowing) BOOL showing;
@property (assign, readwrite, nonatomic, getter=hasIndicator) BOOL indicator;
@property (strong, nonatomic) NSString *title;
@property (strong, readonly, nonatomic) UIView *contentView;
@property (strong, readonly, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, readonly, nonatomic) UILabel *textLabel;

- (void)setTitle:(NSString *)title indicator:(BOOL)indicator;
- (void)show;
- (void)hide;

@end
