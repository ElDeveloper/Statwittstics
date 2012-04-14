//
//  AppDelegate.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 05/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import "HomeViewController.h"
#import "PBTUser.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

/*
 //Ask the account store for the twitter account
 ACAccountStore *astore=[[ACAccountStore alloc] init];
 ACAccountType *twitterAccountType=[astore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
 
 //Ask for permission to use the twitter credentials of the user
 [astore requestAccessToAccountsWithType:twitterAccountType withCompletionHandler:^(BOOL granted, NSError *error) {
 
 //The response will be solved in another thread, this might not be the main thread
 dispatch_async(dispatch_get_main_queue(), ^{
 
 //Request the first twitter account available 
 NSArray *twitterAccounts=[astore accountsWithAccountType:twitterAccountType];
 ACAccount *theAccount=[twitterAccounts objectAtIndex:0];
 
 NSURL *timelineURL=[NSURL URLWithString:@"http://api.twitter.com/1/statuses/home_timeline.json"];
 NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:@"10", @"count", nil];
 TWRequest *myTimeline=[[TWRequest alloc] initWithURL:timelineURL parameters:parameters requestMethod:TWRequestMethodGET];
 [myTimeline setAccount:theAccount];
 
 [myTimeline performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
 NSError *jsonError=nil;
 
 if (responseData != nil) {
 id timelineData=[NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
 NSLog(@"AWESOMESAUCE %@", timelineData);
 }                
 }];//TwitterRequest            
 });//Asynchronous response
 }];//Access for the credentials 
 */