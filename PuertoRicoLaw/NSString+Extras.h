//
//  NSString+Extras.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/26/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extras)

+ (NSString *)htmlStringWithTitle:(NSString *)title body:(NSString *)body;
- (NSString *)md5;

@end
