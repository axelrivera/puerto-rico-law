//
//  APIBook.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 4/13/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import "APIBook.h"
#import "Book.h"

@implementation APIBook

@synthesize title = title_;
@synthesize name = name_;
@synthesize date = date_;
@synthesize isPurchase = isPurchase_;
@synthesize bookVersion = bookVersion_;
@synthesize md5 = md5_;

- (id)init
{
	self = [super init];
	if (self) {
		// Initialization code
	}
	return self;
}

- (NSString *)zipFile
{
	return [NSString stringWithFormat:@"%@_%d.zip", self.name, [self.bookVersion integerValue]];
}

- (NSString *)plistFile
{
	return [self.name stringByAppendingPathExtension:@"plist"];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Title: %@\rName: %@\rDate: %@\rPurchase %d\rVersion: %@",
			self.title,
			self.name,
			self.date,
			self.isPurchase,
			self.bookVersion];
}

@end
