//
//  StatwittsticsUtils.m
//  Statwittstics
//
//  Created by Yoshiki Vázquez Baeza on 05/01/13.
//  Copyright (c) 2013 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "StatwittsticsUtils.h"
#import <Accounts/Accounts.h>

@implementation StatwittsticsUtils

+(BOOL)arrayOfAccounts:(NSArray *)accounts containsUsername:(NSString *)testUsername {
	for (ACAccount *anAccount in accounts){
		if ([[anAccount username] isEqualToString:testUsername]){
			return YES;
		}
	}
	return NO;
}

+(ACAccount *)accountForUsername:(NSString *)testUsername inArrayOfAccounts:(NSArray *)accounts{
	for (ACAccount *anAccount in accounts) {
		if ([[anAccount username] isEqualToString:testUsername]) {
			return anAccount;
		}
	}
	return nil;
}

+(void)writeNewDefaultUser:(NSString *)aUsername{
	NSString *settingsFilePath=[StatwittsticsUtils preferencesFilePath];
	NSMutableDictionary *info=nil;

	#ifdef DEBUG
	NSLog(@"Writting to: %@", settingsFilePath);
	#endif

	if ([[NSFileManager defaultManager] fileExistsAtPath:settingsFilePath]) {
		info=[[NSMutableDictionary alloc] initWithContentsOfFile:settingsFilePath];
	}
	else{
		info=[[NSMutableDictionary alloc] init];
	}

	[info setObject:aUsername forKey:StatwittsticsSettingsResearcherKey];
	[info writeToFile:settingsFilePath atomically:YES];
	[info release];
}

+(NSString *)readDefaultUser{
	NSMutableDictionary *info=nil;
	NSString *settingsFilePath=[StatwittsticsUtils preferencesFilePath];

	// Return the most unlikely username string possible
	NSString *outString=StatwittsticsSettingsResearcherPlaceholderKey;

	#ifdef DEBUG
	NSLog(@"Reading from: %@", settingsFilePath);
	#endif

	if ([[NSFileManager defaultManager] fileExistsAtPath:settingsFilePath]) {
		info=[[NSMutableDictionary alloc] initWithContentsOfFile:settingsFilePath];

		// Only if the object is not nil, create a new string
		if ([info objectForKey:StatwittsticsSettingsResearcherKey]) {
			outString=[NSString stringWithString:[info objectForKey:StatwittsticsSettingsResearcherKey]];
		}

		[info release];
	}

	return outString;
}

+(NSString *)preferencesFilePath{
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory=[paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:StatwittsticsSettingsFileName];
}


@end
