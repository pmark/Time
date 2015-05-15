//
//  AppDelegate.h
//  Time
//
//  Created by P. Mark Anderson on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSTimeZone *defaultTimeZone;

- (NSString *)applicationDocumentsDirectory;
- (void)saveContext;
- (void)addNotificationAt:(NSDate*)fireDate alertBody:(NSString*)alertBody soundName:(NSString*)soundName badge:(NSInteger)badge userInfo:(NSDictionary*)userInfo;

@end

#define APP_DELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)
