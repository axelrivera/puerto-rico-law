//
//  NSDateFormatter+Book.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 5/13/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import "NSDateFormatter+Book.h"

static NSDateFormatter *spanishDateFormatter_;

@interface NSDateFormatter (Private)

+ (NSDateFormatter *)spanishDateFormatter;

@end

@implementation NSDateFormatter (Book)

+ (NSDateFormatter *)spanishDateFormatter
{
	if (spanishDateFormatter_ == nil) {
		NSLocale *spanishLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"es_ES"];
		spanishDateFormatter_ = [[NSDateFormatter alloc] init];
		spanishDateFormatter_.locale = spanishLocale;
		spanishDateFormatter_.timeStyle = NSDateFormatterNoStyle;
	}
	return spanishDateFormatter_;
}

+ (NSString *)spanishLongStringFromDate:(NSDate *)date
{
	NSDateFormatter *formatter = [NSDateFormatter spanishDateFormatter];
	formatter.dateStyle = NSDateFormatterLongStyle;
	return [formatter stringFromDate:date];
}

+ (NSString *)spanishMediumStringFromDate:(NSDate *)date
{
	NSDateFormatter *formatter = [NSDateFormatter spanishDateFormatter];
	formatter.dateStyle = NSDateFormatterMediumStyle;
	return [formatter stringFromDate:date];
}

@end
