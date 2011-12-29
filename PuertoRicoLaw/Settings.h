//
//  Settings.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/22/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Settings : NSObject

#define kFontFamilyHelveticaString @"Helvetica,Sans-serif"
#define kFontFamilyTimesNewRomanString @"Times New Roman,Serif"

typedef enum {
	FontFamilyTypeHelvetica,
	FontFamilyTypeTimesNewRoman
} FontFamilyType;

#define kFontSizeSmallPoints 12
#define kFontSizeMediumPoints 14
#define kFontSizeLargePoints 16

typedef enum {
	FontSizeTypeSmall,
	FontSizeTypeMedium,
	FontSizeTypeLarge
} FontSizeType;

#define kContentBackgroundWhiteFontColor @"#000000"
#define kContentBackgroundWhiteColor @"#FFFFFF"
#define kContentBackgroundBlackFontColor @"#FFFFFF"
#define kContentBackgroundBlackColor @"#000000"

typedef enum {
	ContentBackgroundTypeWhite,
	ContentBackgroundTypeBlack
} ContentBackgroundType;

@property (assign, nonatomic) BOOL landscapeMode;
@property (assign, nonatomic) FontFamilyType fontFamilyType;
@property (assign, nonatomic) FontSizeType fontSizeType;
@property (assign, nonatomic) ContentBackgroundType contentBackgroundType;

+ (Settings *)sharedSettings;

+ (NSString *)stringForFontFamilyType:(FontFamilyType)fontFamilyType;
+ (NSString *)stringForFontSizeType:(FontSizeType)fontSizeType;
+ (NSString *)stringForContentBackgroundType:(ContentBackgroundType)contentBackgroundType;

+ (NSArray *)fontFamilyArray;
+ (NSArray *)fontSizeArray;
+ (NSArray *)contentBackgroundArray;

- (NSString *)fontFamilyString;
- (NSString *)fontSizeString;
- (NSString *)contentBackgroundString;

- (NSString *)fontFamilyStyleString;
- (NSInteger)fontSizeStylePoints;
- (NSString *)contentBackgroundFontColorStyleString;
- (NSString *)contentBackgroundStyleString;

- (UIScrollViewIndicatorStyle)scrollViewIndicator;

@end
