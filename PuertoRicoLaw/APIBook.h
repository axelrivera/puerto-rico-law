//
//  APIBook.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 4/13/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Book;

@interface APIBook : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) BOOL isPurchase;
@property (strong, nonatomic) NSNumber *bookVersion;
@property (strong, nonatomic) NSString *md5;
@property (strong, nonatomic) id userData;
@property (strong, nonatomic) NSData *fileData;

- (NSString *)zipFile;
- (NSString *)plistFile;
- (BOOL)writePlistFileToTmp;

@end
