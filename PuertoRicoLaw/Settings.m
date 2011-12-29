//
//  Settings.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/22/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "Settings.h"

#define kDefault

#define kSettingsLandscapeModeKey @"RLPuertoRicoLawLandscapeModeKey"

static BOOL const kDefaultValueLandscapeMode = YES;

static Settings *sharedSettings_;

@implementation Settings

@synthesize landscapeMode = landscapeMode_;

- (id)init
{
    self = [super init];
    if (self) {
        NSNumber *landscapeMode = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsLandscapeModeKey];
        if (landscapeMode == nil) {
            landscapeMode = [NSNumber numberWithBool:kDefaultValueLandscapeMode];
        }
        self.landscapeMode = [landscapeMode boolValue];
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

#pragma mark - Singleton Methods

+ (Settings *)sharedSettings
{
	if (sharedSettings_ == nil) {
		sharedSettings_ = [[super allocWithZone:NULL] init];
	}
	return sharedSettings_;
}

+ (id)allocWithZone:(NSZone *)zone
{
	return [self sharedSettings];
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

@end
