//
//  StatwittsticsUtils.h
//  Statwittstics
//
//  Created by Yoshiki Vázquez Baeza on 05/01/13.
//  Copyright (c) 2013 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatwittsticsDefines.h"

@class ACAccount;

@interface StatwittsticsUtils : NSObject

+(BOOL)arrayOfAccounts:(NSArray *)accounts containsUsername:(NSString *)testUsername;
+(ACAccount *)accountForUsername:(NSString *)testUsername inArrayOfAccounts:(NSArray *)accounts;

+(void)writeNewDefaultUser:(NSString *)aUsername;
+(NSString *)readDefaultUser;

@end
