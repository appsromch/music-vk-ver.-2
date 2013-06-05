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
#import "ViewController.h"
#import "PlayerViewController.h"
#import "PlayListView.h"
#import "VkAudioViewController.h"

#pragma mark -
#pragma mark Private Interface
@interface AppDelegate ()
@property (nonatomic, strong) GHRevealViewController *revealController;
@property (nonatomic, strong) GHMenuViewController *menuController;
@end


@implementation AppDelegate
#pragma mark Properties
@synthesize window, viewController;
@synthesize revealController, menuController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
	UIColor *bgColor = [UIColor colorWithRed:(15.0f/255.0f) green:(15.0f/255.0f) blue:(15.0f/255.0f) alpha:1.0f];
	self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
	self.revealController.view.backgroundColor = bgColor;
	RevealBlock revealBlock = ^(){
		[self.revealController toggleSidebar:!self.revealController.sidebarShowing
									duration:kGHRevealSidebarDefaultAnimationDuration];
	};
	NSLog(@"managed object = %@", self.managedObjectContext);
	NSArray *headers = @[
                      [NSNull null],
                      @"Вконтакте"
                      ];
	NSArray *controllers = @[
                          @[
                              [[NavController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"Сохраненные" withRevealBlock:revealBlock andManagedObject:self.managedObjectContext]],
                              [[NavController alloc] initWithRootViewController:[[PlayListView alloc] initWithTitle:@"Плейлисты" withRevealBlock:revealBlock andManagedObject:self.managedObjectContext]],
                              [[NavController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"Настройки" withRevealBlock:revealBlock andManagedObject:self.managedObjectContext]],
                              ],
                          @[
                              [[NavController alloc] initWithRootViewController:[[VkAudioViewController alloc] initWithTitle:@"Аудиозаписи Vk" withRevealBlock:revealBlock andManagedObject:self.managedObjectContext]],
                              [[NavController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"Плейлисты Vk" withRevealBlock:revealBlock andManagedObject:self.managedObjectContext]],
                              [[NavController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"Рекомендации Vk" withRevealBlock:revealBlock andManagedObject:self.managedObjectContext]],
                              [[NavController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"Поиск Vk" withRevealBlock:revealBlock andManagedObject:self.managedObjectContext]],
                              [[NavController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"Аудиозаписи друзей Vk" withRevealBlock:revealBlock andManagedObject:self.managedObjectContext]],
                              ]
                          ];
	NSArray *cellInfos = @[
                        @[
                            @{kSidebarCellImageKey: [UIImage imageNamed:@"navSaved.png"],kSidebarCellHighlightedImageKey: [UIImage imageNamed:@"navSavedS.png"] ,kSidebarCellTextKey: NSLocalizedString(@"Сохраненные", @"")},
                            @{kSidebarCellImageKey: [UIImage imageNamed:@"navList.png"],kSidebarCellHighlightedImageKey: [UIImage imageNamed:@"navListS.png"] ,kSidebarCellTextKey: NSLocalizedString(@"Плейлисты", @"")},
                            @{kSidebarCellImageKey: [UIImage imageNamed:@"set.png"],kSidebarCellHighlightedImageKey: [UIImage imageNamed:@"setS.png"] ,kSidebarCellTextKey: NSLocalizedString(@"Настройки", @"")},
                            ],
                        @[
                            @{kSidebarCellTextKey: NSLocalizedString(@"Аудиозаписи", @"")},
                            @{kSidebarCellTextKey: NSLocalizedString(@"Плейлисты", @"")},
                            @{kSidebarCellTextKey: NSLocalizedString(@"Рекомендации", @"")},
                            @{kSidebarCellTextKey: NSLocalizedString(@"Поиск", @"")},
                            @{kSidebarCellTextKey: NSLocalizedString(@"Аудиозаписи друзей", @"")},
                            ]
                        ];
	
	// Add drag feature to each root navigation controller
	[controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
		[((NSArray *)obj) enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2){
			UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.revealController
																						 action:@selector(dragContentView:)];
			panGesture.cancelsTouchesInView = YES;
			//[((UINavigationController *)obj2).navigationBar addGestureRecognizer:panGesture];
            [((UINavigationController *)obj2).view addGestureRecognizer:panGesture];
		}];
	}];
      
    PlayerViewController *playerVC = [[PlayerViewController alloc]initWithRevealBlock:revealBlock andManagedObject:self.managedObjectContext];
    
    NavController *playerNC = [[NavController alloc] initWithRootViewController:playerVC];
   // [playerNC.navigationBar setBackgroundImage:[UIImage imageNamed:@"playerNavBg.png"] forBarMetrics:UIBarMetricsDefault];
   // [playerNC.navigationBar setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.05]];
    [playerNC.navigationBar setHidden:YES];
    
	self.menuController = [[GHMenuViewController alloc] initWithSidebarViewController:self.revealController
																		withSearchBar:nil
																		  withHeaders:headers
																	  withControllers:controllers
																		withCellInfos:cellInfos
                                                                           withPlayer:playerNC];
	
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = self.revealController;
    [self.window makeKeyAndVisible];
    return YES;
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
