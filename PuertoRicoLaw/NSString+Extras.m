//
//  NSString+Extras.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/26/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "NSString+Extras.h"
#import <CommonCrypto/CommonDigest.h>
#import "Settings.h"

@implementation NSString (Extras)

+ (NSString *)htmlStringWithTitle:(NSString *)title body:(NSString *)body
{
	Settings *settings = [Settings sharedSettings];
	NSString *stylesheet = [NSString stringWithFormat:
							@"<style type=\"text/css\">"
							@"body {background-color:%@;color:%@;font-family:%@;font-size:%ipt;}"
							@"h2 {font-size:1.3em; margin-bottom: 0.8em;}"
							@"</style>",
							[settings contentBackgroundStyleString],
							[settings contentBackgroundFontColorStyleString],
							[settings fontFamilyStyleString],
							[settings fontSizeStylePoints]];
	
	return [NSString stringWithFormat:
			@"<html>"
			@"<head>"
			@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"
			@"%@"
			@"</head>"
			@"<body><h2>%@</h2>%@</body></html>",
			stylesheet,
			title,
			body];
}

- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];  
}

@end
