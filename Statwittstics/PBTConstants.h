//
//  PBTConstants.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 15/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <Foundation/Foundation.h>

//Twitter API image sizes
typedef NSString* const TAImageSize;
extern TAImageSize TAImageSizeMini;         //24px. x 24px. size image representation
extern TAImageSize TAImageSizeNormal;       //48px. x 48px. size image representation
extern TAImageSize TAImageSizeBigger;       //73px. x 73px. size image representation
extern TAImageSize TAImageSizeOriginal;     //Unknown size image representation

//Twitter API URL string representations
typedef NSString* TAUString;
extern TAUString TAUUsersShow;      //Returns the profile information for a user
extern TAUString TAUUserTimeline;   //Returns the N most recent statuses for a user
extern TAUString TAUImageData;      //Returns the data representation of the profile picture of a user
extern TAUString TAUUsersLookup;    //Returns up to 100 users worth of extended information
extern TAUString TAUUsersSearch;    //Returns the first 100 users matching a query (no operators accepted)

//Twitter API keys used for the JSON dictionaries that represent a user
typedef NSString* const TAKey;
extern TAKey TAKeyUsername;
extern TAKey TAKeyRealName;
extern TAKey TAKeyDescription;
extern TAKey TAKeyLocation;
extern TAKey TAKeyProfilePictureURL;
extern TAKey TAKeyBioURL;
extern TAKey TAKeyFollowing;
extern TAKey TAKeyFollowers;
extern TAKey TAKeyTweets;
extern TAKey TAKeyProtected;
extern TAKey TAKeyQuery;

//Keys used for the JSON dictionaries that represent a tweet
extern TAKey TAKeyEntities;
extern TAKey TAKeyInToReplyScreenName;
extern TAKey TAKeyIsRetweet;
extern TAKey TAKeyMedia;
extern TAKey TAKeyMediaURL;
extern TAKey TAKeyMentions;
extern TAKey TAKeyPostDate;
extern TAKey TAKeyScreenName;
extern TAKey TAKeySource;
extern TAKey TAKeyText;
extern TAKey TAKeyTweetID;

@interface PBTConstants : NSObject
@end
