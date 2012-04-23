//
//  PBTUtilities.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 22/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBTUtilities.h"

@implementation PBTUtilities

+(void)requestUsersWithKeyword:(NSString *)keyword andResponseHandler:(PBTSearchResult)handler{
    //URL, parameters and request object initialized to retrieve the data
    NSURL *userDataRequest=[NSURL URLWithString:TAUUsersLookup];
    NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:@"", TAKeyUsername, @"false", @"include_entities", nil];
    TWRequest *userData=[[TWRequest alloc] initWithURL:userDataRequest parameters:parameters requestMethod:TWRequestMethodGET];
    
    
    //Request the data
    [userData performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
    
    
    }];
}

@end
