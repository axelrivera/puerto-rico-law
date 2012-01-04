//
//  UIWebView+Highlight.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 1/4/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (Highlight)

- (NSInteger)highlightAllOccurencesOfString:(NSString *)str;
- (void)removeAllHighlights;

@end
