//
//  NSDateFormatter+Book.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 5/13/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (Book)

+ (NSString *)spanishLongStringFromDate:(NSDate *)date;
+ (NSString *)spanishMediumStringFromDate:(NSDate *)date;

@end
