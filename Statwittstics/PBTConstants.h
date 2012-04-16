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
extern TAImageSize TAImageSizeMini;
extern TAImageSize TAImageSizeNormal;
extern TAImageSize TAImageSizeBigger;
extern TAImageSize TAImageSizeOriginal;

//Twitter API URL string representations
typedef NSString* TAUString;
extern TAUString TAUUsersShow;
extern TAUString TAUUserTimeline;
extern TAUString TAUImageData;

//Keys used for the JSON objects returned by twitter
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

@interface PBTConstants : NSObject
@end
