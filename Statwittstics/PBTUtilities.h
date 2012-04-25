//
//  PBTUtilities.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 22/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBTDefines.h"
#import "PBTUser.h"

@interface PBTUtilities : NSObject

//General handler for the blocks, if an error occurs in the in the method where
//the caller is called, the handler won't be called , to avoid conflicts.
typedef void __block (^PBTSearchResult)(NSArray *arrayOfSubjects);

//These utilities requier of a vailid PBTUser, otherwise you won't be able to make the request
+(void)user:(PBTUser *)user requestUsersWithKeyword:(NSString *)keyword andResponseHandler:(PBTSearchResult)handler;

@end
