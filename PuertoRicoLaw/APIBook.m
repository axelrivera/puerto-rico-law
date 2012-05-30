//
//  APIBook.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 4/13/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import "APIBook.h"

#import "FileHelpers.h"
#import "Book.h"
#import "ZipArchive.h"
#import "NSData+RKAdditions.h"

@implementation APIBook

@synthesize title = title_;
@synthesize name = name_;
@synthesize date = date_;
@synthesize isPurchase = isPurchase_;
@synthesize bookVersion = bookVersion_;
@synthesize md5 = md5_;
@synthesize userData = userData_;
@synthesize fileData = fileData_;

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
	return [NSString stringWithFormat:@"%@.zip", self.name];
}

- (NSString *)plistFile
{
	return [self.name stringByAppendingPathExtension:@"plist"];
}

- (BOOL)writePlistFileToTmp
{
	if (self.name == nil || self.fileData == nil) {
		return NO;
	}
	
	if (![[self.fileData MD5] isEqualToString:self.md5]) {
		NSLog(@"Hash mismatch");
		return NO;
	}
	
	NSString *tmpZipFilepath = pathInTemporaryDirectory([self zipFile]);
	BOOL didWriteFile = [self.fileData writeToFile:tmpZipFilepath atomically:YES];
	if (didWriteFile) {
		ZipArchive *archive = [[ZipArchive alloc] init];
		if ([archive UnzipOpenFile:tmpZipFilepath]) {
			if ([archive UnzipFileTo:pathInTemporaryDirectory(@"") overWrite:YES]) {
				[archive UnzipCloseFile];
				deletePathInTemporaryDirectory([self zipFile]);
				return YES;
			}
		}
	}
	NSLog(@"WTF!");
	return NO;
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
