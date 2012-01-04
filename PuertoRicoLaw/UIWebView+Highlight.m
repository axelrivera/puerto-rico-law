//
//  UIWebView+Highlight.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 1/4/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import "UIWebView+Highlight.h"

@implementation UIWebView (Highlight)

- (NSInteger)highlightAllOccurencesOfString:(NSString*)str
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self stringByEvaluatingJavaScriptFromString:jsCode];
	
    NSString *startSearch = [NSString stringWithFormat:@"RLPuertoRicoLaw_HighlightAllOccurencesOfString('%@')",str];
    [self stringByEvaluatingJavaScriptFromString:startSearch];
	
    NSString *result = [self stringByEvaluatingJavaScriptFromString:@"RLPuertoRicoLaw_SearchResultCount"];
    return [result integerValue];
}

- (void)removeAllHighlights
{
    [self stringByEvaluatingJavaScriptFromString:@"RLPuertoRicoLaw_RemoveAllHighlights()"];
}

@end
