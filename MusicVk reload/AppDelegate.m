//
//  AppDelegate.m
//  MusicVk reload
//
//  Created by David Dreval on 09.02.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import "AppDelegate.h"
#import "GHRevealViewController.h"
#import "GHMenuViewController.h"
#import "GHMenuCell.h"
#import "GHRootViewController.h"
#import "NavController.h"
#import "ItunesViewController.h"
#import "ViewController.h"
#import "PlayerViewController.h"
#import "PlayListView.h"
#import "VkAudioViewController.h"
#import "RESideMenu.h"
#import "SettingsView.h"
#import "SearchView.h"

#pragma mark -
#pragma mark Private Interface
@interface AppDelegate ()
@property (nonatomic, strong) GHRevealViewController *revealController;
@property (nonatomic, strong) GHMenuViewController *menuController;
@property (nonatomic, retain) PlayerViewController *playerVC;
@property (nonatomic, retain) NavController *menuVC;
@end


@implementation AppDelegate
#pragma mark Properties
@synthesize window, viewController;
@synthesize revealController, menuController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize controllers;


+ (NSInteger)OSVersion
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	//[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
	NSLog(@"managed object = %@", self.managedObjectContext);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openPlayer)
                                                 name:@"openPlayer"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openMenu)
                                                 name:@"openMenu"
                                               object:nil];
    _playerVC = [[PlayerViewController alloc]initWithRevealBlock:nil andManagedObject:self.managedObjectContext];
    controllers = @[
                             @[
                                 [[NavController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"Сохраненные" withRevealBlock:nil andManagedObject:self.managedObjectContext]],
                                 [[NavController alloc] initWithRootViewController:[[PlayListView alloc] initWithTitle:@"Плейлисты" withRevealBlock:nil andManagedObject:self.managedObjectContext]],
                                 [[NavController alloc] initWithRootViewController:[[SettingsView alloc] initWithTitle:@"Настройки" withRevealBlock:nil andManagedObject:self.managedObjectContext]],
                                 ],
                             @[
                                 [[NavController alloc] initWithRootViewController:[[VkAudioViewController alloc] initWithTitle:@"Аудиозаписи Vk" withRevealBlock:nil andManagedObject:self.managedObjectContext]],
                                 [[NavController alloc] initWithRootViewController:[[ItunesViewController alloc] initWithTitle:@"Itunes/Песни" withRevealBlock:nil andManagedObject:self.managedObjectContext]],
                                 [[NavController alloc] initWithRootViewController:[[VkAudioViewController alloc] initWithTitle:@"Рекомендации Vk" withRevealBlock:nil andManagedObject:self.managedObjectContext]],
                                 [[NavController alloc] initWithRootViewController:[[SearchView alloc] initWithTitle:@"Поиск Vk" withRevealBlock:nil andManagedObject:self.managedObjectContext]],
                                // [[NavController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"Аудиозаписи друзей Vk" withRevealBlock:nil andManagedObject:self.managedObjectContext]],
                                 ]
                             ];
    _menuVC = controllers[0][0];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = _menuVC;
    self.window.backgroundColor = [UIColor whiteColor];
     
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) openPlayer {
    _menuVC = self.window.rootViewController;
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ self.window.rootViewController = _playerVC; }
                    completion:nil];
}

- (void) openMenu {
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ self.window.rootViewController = _menuVC; }
                    completion:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
	if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
        NSLog(@"UIEventSubtypeRemoteControlPlayPause");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerPlay" object:nil];
	}
	if (event.subtype == UIEventSubtypeRemoteControlPlay) {
        NSLog(@"UIEventSubtypeRemoteControlPlay");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerPlay" object:nil];
	}
	if (event.subtype == UIEventSubtypeRemoteControlPause) {
        NSLog(@"UIEventSubtypeRemoteControlPause");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerPlay" object:nil];
	}
	if (event.subtype == UIEventSubtypeRemoteControlStop) {
		NSLog(@"UIEventSubtypeRemoteControlStop");
		//[player stop];
	}
	if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
		NSLog(@"UIEventSubtypeRemoteControlNextTrack");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerFwd" object:nil];
	}
	if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
		NSLog(@"UIEventSubtypeRemoteControlPreviousTrack");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerRwd" object:nil];
	}
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"coreDataModel" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MusicVk.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
