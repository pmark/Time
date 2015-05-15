//
//  AppDelegate.m
//  Time
//
//  Created by P. Mark Anderson on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 
 PURPOSE:
 
 To record how much time is spent throughout the day on one or more projects 
 so that I can report my hours more accurately 
 and get a better understanding of how time is spent.
 
 */


#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;
@synthesize defaultTimeZone;

- (void)persistentStoreAdded:(NSNotification*)notif
{
    NSLog(@"persistentStoreAdded");
}

- (void) setTimeZone
{
    NSTimeZone *tz = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultTimeZone"];
    
    if (tz)
    {
        self.defaultTimeZone = tz;
    }
    else
    {
        // WRONG.
        self.defaultTimeZone = [NSTimeZone defaultTimeZone];
//        [[NSUserDefaults standardUserDefaults] setValue:self.defaultTimeZone forKey:@"defaultTimeZone"];
//        NSLog(@"Set default time zone: %@", self.defaultTimeZone);
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(persistentStoreAdded:) name:NSAddedPersistentStoresKey object:nil];
    
	NSManagedObjectContext *context = [self managedObjectContext];
    
	if (!context) 
    {
		// Handle the error.
        NSLog(@"\n\nERROR: Unable to get managed object context.\n\n");
	}
    
//    [TestFlight takeOff:@"4478b11d77afaf8ca93f64c42d84e6b8_NTA2MjUyMDEyLTAxLTA0IDEyOjM0OjUzLjI1ODI1MA"];
    
    
    
    ///////
    // TODO: Remove this test.
//    NSDate *alertTime = [NSDate dateWithTimeIntervalSinceNow:10];
//    [self addNotificationAt:alertTime alertBody:@"hi!" soundName:nil badge:3 userInfo:nil];
    ///////
	
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    if (localNotification) 
    {
        NSLog(@"Notification Body: %@",localNotification.alertBody);
        NSLog(@"%@", localNotification.userInfo);
    }
    
    application.applicationIconBadgeNumber = 0;
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification 
{
    NSLog(@"Notification Body: %@", notification.alertBody);
    NSLog(@"%@", notification.userInfo);
    
    application.applicationIconBadgeNumber = 0;
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [self saveContext];
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
    [self saveContext];
}

- (void)saveContext 
{    
    NSLog(@"\n\nSaving data context.\n\n");
    NSError *error = nil;
    
    @try 
    {
        if (managedObjectContext != nil) 
        {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) 
            {
                /*
                 Replace this implementation with code to handle the error appropriately.
                 
                 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
                 */
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                ///abort();
            } 
        }
    }
    @catch (NSException *exception) 
    {
        NSLog(@"ERROR saving core data object context: %@", [exception description]);
    }
}    


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext 
{	
    if (managedObjectContext != nil) 
    {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) 
    {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    else
    {
        NSLog(@"\n\nERROR: Unable to get persistent store coordinator.\n\n");
    }
    
    NSLog(@"Data context created.");
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel 
{	
    if (managedObjectModel != nil) 
    {
        return managedObjectModel;
    }
    
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
    if (persistentStoreCoordinator != nil) 
    {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] 
                                               stringByAppendingPathComponent:@"Clocks.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] 
                                  initWithManagedObjectModel:[self managedObjectModel]];
    
	// Allow inferred migration from the original version of the application.
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                  configuration:nil 
                                                            URL:storeUrl 
                                                        options:options 
                                                          error:&error]) 
    {
        // Handle the error.
        NSLog(@"ERROR connecting to core datastore: %@", [error localizedDescription]);
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

- (NSString *)applicationDocumentsDirectory 
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma -

- (void) addNotificationAt:(NSDate*)fireDate alertBody:(NSString*)alertBody soundName:(NSString*)soundName badge:(NSInteger)badge userInfo:(NSDictionary*)userInfo
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    localNotification.fireDate = fireDate;
    localNotification.alertBody = alertBody;
    localNotification.userInfo = userInfo;
    
    if (badge > 0)
    {
        localNotification.applicationIconBadgeNumber = badge;
    }

    if (!soundName)
    {
        soundName = UILocalNotificationDefaultSoundName;
    }

    localNotification.soundName = soundName;

    NSLog(@"Rescheduling local notification.");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
