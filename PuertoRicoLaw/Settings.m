//
//  Settings.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/22/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "Settings.h"

#define kFontFamilyTypeHelvetica @"FontFamilyTypeHelvetica"
#define kFontFamilyTypeTimesNewRoman @"FontFamilyTypeTimesNewRoman"

#define kFontSizeTypeSmall @"FontSizeTypeSmall"
#define kFontSizeTypeMedium @"FontSizeTypeMedium"
#define kFontSizeTypeLarge @"FontSizeTypeLarge"

#define kContentBackgroundTypeWhite @"ContentBackgroundTypeWhite"
#define kContentBackgroundTypeBlack @"ContentBackgroundTypeBlack"

// The order of the arguments must match the order of the enum types
#define kFontFamilyStringArgs @"Helvetica",@"Times New Roman"
#define kFontSizeStringArgs @"Pequeño",@"Mediano",@"Grande"
#define kContentBackgroundStringArgs @"Blanco",@"Negro"

#define kSettingsLandscapeModeKey @"RLPuertoRicoLawLandscapeModeKey"
#define kSettingsFontFamilyKey @"RLPuertoRicoLawFontFamilyKey"
#define kSettingsFontSizeKey @"RLPuertoRicoLawFontSizeKey"
#define kSettingsContentBackgroundKey @"RLPuertoRicoLawContentBackgroundKey"

static NSArray *fontFamilyArray_;
static NSArray *fontSizeArray_;
static NSArray *contentBackgroundArray_;

static FontFamilyType const kDefaultValueFontFamily = FontFamilyTypeHelvetica;
static FontSizeType const kDefaultValueFontSize = FontSizeTypeSmall;
static ContentBackgroundType const kDefaultValueContentBackground = ContentBackgroundTypeWhite;
static BOOL const kDefaultValueLandscapeMode = YES;

static Settings *sharedSettings_ = nil;

@interface Settings (Private)

+ (FontFamilyType)fontFamilyTypeForValueString:(NSString *)string;
+ (NSString *)valueStringForFontFamilyType:(FontFamilyType)fontFamilyType;
+ (FontSizeType)fontSizeTypeForValueString:(NSString *)string;
+ (NSString *)valueStringForFontSizeType:(FontSizeType)fontSizeType;
+ (ContentBackgroundType)contentBackgroundTypeForValueString:(NSString *)string;
+ (NSString *)valueStringForContentBackgroundType:(ContentBackgroundType)contentBackgroundType;

@end

@implementation Settings

@synthesize landscapeMode = landscapeMode_;
@synthesize fontFamilyType = fontFamilyType_;
@synthesize fontSizeType = fontSizeType_;
@synthesize contentBackgroundType = contentBackgroundType_;

- (id)init
{
    self = [super init];
    if (self) {
        NSNumber *landscapeMode = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsLandscapeModeKey];
        if (landscapeMode == nil) {
            landscapeMode = [NSNumber numberWithBool:kDefaultValueLandscapeMode];
        }
        landscapeMode_ = [landscapeMode boolValue];
		
		NSString *fontFamilyStr = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsFontFamilyKey];
		if (fontFamilyStr == nil) {
			fontFamilyStr = [[self class] valueStringForFontFamilyType:kDefaultValueFontFamily];
		}
		fontFamilyType_ = [[self class] fontFamilyTypeForValueString:fontFamilyStr];
		
		NSString *fontSizeStr = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsFontSizeKey];
		if (fontSizeStr == nil) {
			fontSizeStr = [[self class] valueStringForFontSizeType:kDefaultValueFontSize];
		}
		fontSizeType_ = [[self class] fontSizeTypeForValueString:fontSizeStr];
		
		NSString *contentBackgroundStr = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsContentBackgroundKey];
		if (contentBackgroundStr == nil) {
			contentBackgroundStr = [[self class] valueStringForContentBackgroundType:kDefaultValueContentBackground];
		}
		contentBackgroundType_ = [[self class] contentBackgroundTypeForValueString:contentBackgroundStr];
	}
	return self;
}

#pragma mark - Custom Setters

- (void)setLandscapeMode:(BOOL)landscapeMode
{
    landscapeMode_ = landscapeMode;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:landscapeMode] forKey:kSettingsLandscapeModeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];    
}

- (void)setFontFamilyType:(FontFamilyType)fontFamilyType
{
	fontFamilyType_ = fontFamilyType;
	[[NSUserDefaults standardUserDefaults] setObject:[[self class] valueStringForFontFamilyType:fontFamilyType]
											  forKey:kSettingsFontFamilyKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setFontSizeType:(FontSizeType)fontSizeType
{
	fontSizeType_ = fontSizeType;
	[[NSUserDefaults standardUserDefaults] setObject:[[self class] valueStringForFontSizeType:fontSizeType]
											  forKey:kSettingsFontSizeKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setContentBackgroundType:(ContentBackgroundType)contentBackgroundType
{
	contentBackgroundType_ = contentBackgroundType;
	[[NSUserDefaults standardUserDefaults] setObject:[[self class] valueStringForContentBackgroundType:contentBackgroundType]
											  forKey:kSettingsContentBackgroundKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Custom Class methods

+ (NSString *)stringForFontFamilyType:(FontFamilyType)fontFamilyType
{
	return [[[self class] fontFamilyArray] objectAtIndex:fontFamilyType]; 
}

+ (NSString *)stringForFontSizeType:(FontSizeType)fontSizeType
{
	return [[[self class] fontSizeArray] objectAtIndex:fontSizeType];
}

+ (NSString *)stringForContentBackgroundType:(ContentBackgroundType)contentBackgroundType
{
	return [[[self class] contentBackgroundArray] objectAtIndex:contentBackgroundType];
}

+ (NSArray *)fontFamilyArray
{
	if (fontFamilyArray_ == nil) {
		fontFamilyArray_ = [[NSArray alloc] initWithObjects:kFontFamilyStringArgs, nil];
	}
	return fontFamilyArray_;
}

+ (NSArray *)fontSizeArray
{
	if (fontSizeArray_ == nil) {
		fontSizeArray_ = [[NSArray alloc] initWithObjects:kFontSizeStringArgs, nil];
	}
	return fontSizeArray_;
}

+ (NSArray *)contentBackgroundArray
{
	if (contentBackgroundArray_ == nil) {
		contentBackgroundArray_ = [[NSArray alloc] initWithObjects:kContentBackgroundStringArgs, nil];
	}
	return contentBackgroundArray_;
}

#pragma mark - Private Class Methods

+ (FontFamilyType)fontFamilyTypeForValueString:(NSString *)string
{
	FontFamilyType type;
	if ([string isEqualToString:kFontFamilyTypeHelvetica]) {
		type = FontFamilyTypeHelvetica;
	} else if ([string isEqualToString:kFontFamilyTypeTimesNewRoman]) {
		type = FontFamilyTypeTimesNewRoman;
	} else {
		type = FontFamilyTypeHelvetica;
	}
	return type;
}

+ (NSString *)valueStringForFontFamilyType:(FontFamilyType)fontFamilyType
{
	NSString *string = nil;
	switch (fontFamilyType) {
		case FontFamilyTypeHelvetica:
			string = kFontFamilyTypeHelvetica;
			break;
		case FontFamilyTypeTimesNewRoman:
			string = kFontFamilyTypeTimesNewRoman;
			break;
		default:
			string = kFontFamilyTypeHelvetica;
			break;
	}
	return string;
}

+ (FontSizeType)fontSizeTypeForValueString:(NSString *)string
{
	FontSizeType type;
	if ([string isEqualToString:kFontSizeTypeSmall]) {
		type = FontSizeTypeSmall;
	} else if ([string isEqualToString:kFontSizeTypeMedium]) {
		type = FontSizeTypeMedium;
	} else if ([string isEqualToString:kFontSizeTypeLarge]) {
		type = FontSizeTypeLarge;
	} else {
		type = FontSizeTypeMedium;
	}
	return type;
}

+ (NSString *)valueStringForFontSizeType:(FontSizeType)fontSizeType
{
	NSString *string = nil;
	switch (fontSizeType) {
		case FontSizeTypeSmall:
			string = kFontSizeTypeSmall;
			break;
		case FontSizeTypeMedium:
			string = kFontSizeTypeMedium;
			break;
		case FontSizeTypeLarge:
			string = kFontSizeTypeLarge;
			break;
		default:
			string = kFontSizeTypeMedium;
			break;
	}
	return string;
}

+ (ContentBackgroundType)contentBackgroundTypeForValueString:(NSString *)string
{
	ContentBackgroundType type;
	if ([string isEqualToString:kContentBackgroundTypeWhite]) {
		type = ContentBackgroundTypeWhite;
	} else if ([string isEqualToString:kContentBackgroundTypeBlack]) {
		type = ContentBackgroundTypeBlack;
	} else {
		type = ContentBackgroundTypeWhite;
	}
	return type;
}

+ (NSString *)valueStringForContentBackgroundType:(ContentBackgroundType)contentBackgroundType
{
	NSString *string = nil;
	switch (contentBackgroundType) {
		case ContentBackgroundTypeWhite:
			string = kContentBackgroundTypeWhite;
			break;
		case ContentBackgroundTypeBlack:
			string = kContentBackgroundTypeBlack;
			break;
		default:
			string = kContentBackgroundTypeWhite;
			break;
	}
	return string;
}

#pragma mark - Custom Methods

- (NSString *)fontFamilyString
{
	return [[self class] stringForFontFamilyType:self.fontFamilyType];
}

- (NSString *)fontSizeString
{
	return [[self class] stringForFontSizeType:self.fontSizeType];
}

- (NSString *)contentBackgroundString
{
	return [[self class] stringForContentBackgroundType:self.contentBackgroundType];
}

- (NSString *)fontFamilyStyleString
{
	NSString *string = nil;
	switch (self.fontFamilyType) {
		case FontFamilyTypeHelvetica:
			string = kFontFamilyHelveticaString;
			break;
		case FontFamilyTypeTimesNewRoman:
			string = kFontFamilyTimesNewRomanString;
			break;
		default:
			string = kFontFamilyHelveticaString;
			break;
	}
	return string;
}

- (NSInteger)fontSizeStylePoints
{
	NSInteger points;
	switch (self.fontSizeType) {
		case FontSizeTypeSmall:
			points = kFontSizeSmallPoints;
			break;
		case FontSizeTypeMedium:
			points = kFontSizeMediumPoints;
			break;
		case FontSizeTypeLarge:
			points = kFontSizeLargePoints;
			break;
		default:
			points = kFontSizeMediumPoints;
			break;
	}
	return points;
}

- (NSString *)contentBackgroundFontColorStyleString
{
	NSString *string = nil;
	switch (self.contentBackgroundType) {
		case ContentBackgroundTypeWhite:
			string = kContentBackgroundWhiteFontColor;
			break;
		case ContentBackgroundTypeBlack:
			string = kContentBackgroundBlackFontColor;
			break;
		default:
			string = kContentBackgroundWhiteFontColor;
			break;
	}
	return string;
}

- (NSString *)contentBackgroundStyleString
{
	NSString *string = nil;
	switch (self.contentBackgroundType) {
		case ContentBackgroundTypeWhite:
			string = kContentBackgroundWhiteColor;
			break;
		case ContentBackgroundTypeBlack:
			string = kContentBackgroundBlackColor;
			break;
		default:
			string = kContentBackgroundWhiteColor;
			break;
	}
	return string;
}

- (UIScrollViewIndicatorStyle)scrollViewIndicator
{
	UIScrollViewIndicatorStyle style;
	switch (self.contentBackgroundType) {
		case ContentBackgroundTypeWhite:
			style = UIScrollViewIndicatorStyleBlack;
			break;
		case ContentBackgroundTypeBlack:
			style = UIScrollViewIndicatorStyleWhite;
			break;
		default:
			style = UIScrollViewIndicatorStyleDefault;
			break;
	}
	return style;
}

#pragma mark - Singleton Methods

+ (Settings *)sharedSettings
{
    @synchronized(self) {
        if (sharedSettings_ == nil) {
            sharedSettings_ = [[self alloc] init];
		}
    }
    return sharedSettings_;
}

@end
