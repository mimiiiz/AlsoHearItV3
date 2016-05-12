//
//  AppDelegate.m
//  Also Hear It
//
//  Created by Thanachaporn on 9/18/2558 BE.
//  Copyright © 2558 Thanachaporn. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "ASUser.h"
#import "Channel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate{
    ASUser *currentUser;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [Parse enableLocalDatastore];
    
    [Parse setApplicationId:@"a0krOULyEuI1AX9NWceyb6h8bLhMZypwyHiQwKbq"
                  clientKey:@"NHThM9E2eSy2QuxEbvRaM0oFUP1LkKPyyZLpjCKq"];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    currentUser = [ASUser currentUser];
    if (currentUser) {
        if ([currentUser.type isEqualToString:@"announcer"]) {
            self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Announcer" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }else if ([currentUser.type isEqualToString:@"deaf"] ){
            self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Deaf" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }else if ([currentUser.type isEqualToString:@"admin"]){
            self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Admin" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"admin"];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

@end
