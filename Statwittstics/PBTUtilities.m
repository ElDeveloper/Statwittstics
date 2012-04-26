//
//  PBTUtilities.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 22/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBTUtilities.h"

@implementation PBTUtilities

+(void)user:(PBTUser *)user requestUsersWithKeyword:(NSString *)keyword andResponseHandler:(PBTSearchResult)handler{
    //URL, parameters and request object initialized to retrieve the data, see PBTConstants for the definitions
    NSURL *userSearchURL=[NSURL URLWithString:TAUUsersSearch];
    NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:keyword, TAKeyQuery, nil];
    TWRequest *userSearchRequest=[[TWRequest alloc] initWithURL:userSearchURL parameters:parameters requestMethod:TWRequestMethodGET];
    
    //Authorize if a user has been provided
    if (user != nil) {
        if ( [user account] != nil ) {
            [userSearchRequest setAccount:[user account]];
        }
    }
    
    //Request the data
    [userSearchRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError *jsonError=nil;
        id jsonString=nil;
        NSMutableArray *bufferArray=[NSMutableArray array];
        PBTUser *temp=nil;
        
        NSLog(@"%@", [urlResponse URL]);
        
        //Check for errors in the request
        if (!error) {
            
            //The JSON object is a Dictionary
            jsonString=[NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            
            //Twitter wouldn't return badly serilized JSON objects but if anything
            if (!jsonError) {
                #ifdef JSON_DEBUG
                NSLog(@"USER_SEARCH: %@", jsonString);
                #endif
                
                //Iterate over each of the objects in the JSON string
                for ( NSDictionary *someDictionary in (NSArray *)jsonString ) {
                    //Add each object to the array, the array becomes the retainer of the object
                    temp=[[PBTUser alloc] initWithJSONString:someDictionary];
                    [bufferArray addObject:temp];
                    [temp release];
                    temp=nil;
                }
                
                //Return the contents of the data in a non-mutable autoreleased array
                handler([NSArray arrayWithArray:bufferArray]);
            }
            else {
                //JSON serialization error management
                NSLog(@"PBTUtilities(J)**:%@",[jsonError localizedDescription]);
            }
        }
        else {
            //Request connection error
            NSLog(@"PBTUtilities(R)**:%@",[error localizedDescription]);
        }
    }];
}

@end
