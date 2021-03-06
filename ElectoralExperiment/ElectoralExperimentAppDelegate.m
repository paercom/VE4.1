//
//  ElectoralExperimentAppDelegate.m
//  ElectoralExperiment
//
//  Created by Stefan Agapie on 10/19/11.
//  Copyright 2011 Stefan Agapie. All rights reserved.
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.

//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "ElectoralExperimentAppDelegate.h"
#import "RootViewController.h"
#import "MySingelton.h"

@implementation ElectoralExperimentAppDelegate


@synthesize window=_window;

@synthesize navigationController=_navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
        
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    
    //self.navigationController = [[UINavigationController alloc] initWithNibName:@"MainWindow-iPad" bundle:nil];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    NSLog(@" ...... Root View Controller: <<< %@ >>> ......",[self.navigationController visibleViewController]);
    
    // handles any url's sent to this app; will become active for files and weblinks //
    id rootViewController = [self.navigationController visibleViewController];
    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if ( url != nil && [url isFileURL]) {
       
        if ( [rootViewController isKindOfClass:[RootViewController class]] ) {
            [rootViewController handleOpenURL:url];
        }        
    }
    
    return YES;
}

- (BOOL) application:(UIApplication *) application handleOpenURL:(NSURL *)url
{
    
    // handles any url's sent to this app; will become active for files and weblinks //
    id rootViewController = [self.navigationController visibleViewController];
    if ( url != nil && [url isFileURL]) {
        
        if ( [rootViewController isKindOfClass:[RootViewController class]] ) {
            [rootViewController handleOpenURL:url];
        }
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // everytime we resign active we pop to the root view since an Open URL request may occure... //
    [self.navigationController popToRootViewControllerAnimated:NO];
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
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

@end
