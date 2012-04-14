//
//  AppDelegate.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 05/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    [[self window] setBackgroundColor:[UIColor whiteColor]];
    
    //The home view controller
    HomeViewController *viewController=[[HomeViewController alloc] initWithNibName:@"Home" bundle:nil];
    
    //Main navigation controller, holds everything in this application
    UINavigationController *navController=[[UINavigationController alloc] initWithRootViewController:viewController];
    [[navController navigationBar] setTintColor:[UIColor blackColor]];
    [viewController release];
    
    [[self window] setRootViewController:navController];
    [navController release];
    
    [[self window] makeKeyAndVisible];
    
    
    //Ask the account store for the twitter account
    ACAccountStore *astore=[[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType=[astore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    //Ask for permission to use the twitter credentials of the user
    [astore requestAccessToAccountsWithType:twitterAccountType withCompletionHandler:^(BOOL granted, NSError *error){
            
        //Request the first twitter account available 
        NSArray *twitterAccounts=[astore accountsWithAccountType:twitterAccountType];
        ACAccount *theAccount=[twitterAccounts objectAtIndex:0];
    
        //Twitter test
        PBTUser *testUser=nil;
        NSArray *array=[NSArray arrayWithObjects:@"analaurad", nil];
        
        for (NSString *plel in array) {
            testUser=[[PBTUser alloc] initWithUsername:plel andAuthorizedAccount:theAccount];
            [testUser requestUserData:^{
                
                #ifdef DEBUG
                NSLog(@"The real name is %@, annoyingly tweeted %d", [testUser realName], [testUser tweetCount]);
                NSLog(@"Has %d followers and %d friends", [testUser followers], [testUser following]);
                NSLog(@"The URL is: %@", [testUser bioURL]);
                NSLog(@"The location is: %@", [testUser location]);
                NSLog(@"The bio is: %@", [testUser description]);
                #endif
                
                [testUser requestMostRecentTweets:3 withHandler:^{
                    NSLog(@"Requested 3, returned %d", [[testUser tweets] count]);
                }];
                
            }];
            //[testUser release];
        }
            
    }];
    
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

@end
