//
//  AppDelegate.m
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/20/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import "AppDelegate.h"
#import "BookViewController.h"
#import "SectionListViewController.h"
#import "BookData.h"
#import "FileHelpers.h"
#import "LocalyticsSession.h"

#define ANALYTICS_ID @"92e8903fd104523f326e1f2-037e2ace-679d-11e1-1dd5-00a68a4c01fc"

#define kResetDataKey @"reset_data_preference"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;
@synthesize bookViewController = _bookViewController;
@synthesize resetDataFlag = _resetDataFlag;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Setup Analytics
	[[LocalyticsSession sharedLocalyticsSession] startSession:ANALYTICS_ID];
	
	// Set Default Preferences
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"NO", kResetDataKey,
								 nil];
	[defaults registerDefaults:appDefaults];
	[defaults synchronize];
	
	// Check Settings Bundle Flags to delete data files if necessary before unarchiving.
	[self checkSettingsBundle];
	
	BookData *bookData = [NSKeyedUnarchiver unarchiveObjectWithFile:bookDataPath()];
	if (bookData == nil) {
		bookData = [BookData sharedBookData];
		[bookData loadBooks];
	}
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	// Override point for customization after application launch.
	
	self.bookViewController = [[BookViewController alloc] init];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		SectionListViewController *listController =
		[[SectionListViewController alloc] initWithSection:nil dataSource:nil siblingSections:nil currentSiblingIndex:-1];
		
		self.bookViewController.delegate = listController;
		UINavigationController *bookNavigationController =
			[[UINavigationController alloc] initWithRootViewController:self.bookViewController];
		UINavigationController *listNavigationController = [[UINavigationController alloc] initWithRootViewController:listController];
		
		self.splitViewController = [[UISplitViewController alloc] init];
		self.splitViewController.viewControllers = [NSArray arrayWithObjects:bookNavigationController, listNavigationController, nil];
		self.splitViewController.delegate = listController;
		self.window.rootViewController = self.splitViewController;
		
	} else {
		self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.bookViewController];
		self.window.rootViewController = self.navigationController;
	}
	
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
	[[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
	
	[self archiveBookData];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
	
	[[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
	
	[self checkSettingsBundle];
	
	if (self.resetDataFlag) {
		deletePathInDocumentDirectory(bookDataPath());
		[BookData sharedBookData].currentBook = nil;
		[[BookData sharedBookData].books removeAllObjects];
		[[BookData sharedBookData].favoriteBooks removeAllObjects];
		[[BookData sharedBookData] loadBooks];
		[self.bookViewController.navigationController popToRootViewControllerAnimated:NO];
		[self.bookViewController.tableView reloadData];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			[self.bookViewController.delegate resetCurrentSection];
			[self.bookViewController.delegate clearCurrentSection];
		}
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
	// Close Localytics Session
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
	
	[self archiveBookData];
}

- (void)archiveBookData
{
	[NSKeyedArchiver archiveRootObject:[BookData sharedBookData] toFile:bookDataPath()];
}

- (void)resetData
{
	NSString *documentsPath = pathInDocumentDirectory(@"");
	NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:documentsPath];
	for (NSString *filename in fileEnumerator) {
		if ([filename hasSuffix:@".data"]) {
			deletePathInDocumentDirectory(filename);
		}
	}
}

- (void)checkSettingsBundle
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	
	self.resetDataFlag = [defaults boolForKey:kResetDataKey];
	
	if (self.resetDataFlag == YES) {
		[defaults setBool:NO forKey:kResetDataKey];
		[self resetData];
	}
}

@end
