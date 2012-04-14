//
//  PBTUser.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 08/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "PBTDefines.h"
#import "PBTweet.h"

//General handler for the blocks, if an error occurs in the in the method where
//the caller is called, the handler won't be called , to avoid conflicts.
typedef void __block (^PBTRequestHandler)(void);

//Twitter API URLs
extern NSString *kPBTUsersShow;
extern NSString *kPBTUserTimeline;

//Keys used for the JSON objects returned by twitter
extern NSString const *kPBTUsernameKey;
extern NSString const *kPBTRealNameKey;
extern NSString const *kPBTDescriptionKey;
extern NSString const *kPBTLocationKey;
extern NSString const *kPBTProfilePictureURLKey;
extern NSString const *kPBTBioURLKey;
extern NSString const *kPBTFollowingKey;
extern NSString const *kPBTFollowersKey;
extern NSString const *kPBTTweetsKey;
extern NSString const *kPBTProtectedKey;

//General constants
extern NSUInteger const kPBTRequestMaximum;

@interface PBTUser : NSObject{
    NSString *username;
    NSString *realName;
    NSString *description;
    NSString *location;
    NSURL *bioURL;
    
    UIImage *profilePic;
    
    NSInteger following;
    NSInteger followers;
    NSInteger tweetCount;
    
    NSArray *tweets;
    
    BOOL requiresAuthentication;
    
    @private
    ACAccount *account;
    
    //Used for the recursive request
    NSMutableArray *_tempArray;
    NSUInteger _remainingTweets;
    NSString *_lastTweetID;
}

//Basic information found in the profile of a Twitter user
@property (nonatomic, retain, readonly) NSString *username;
@property (nonatomic, retain, readonly) NSString *realName;
@property (nonatomic, retain, readonly) NSString *description;
@property (nonatomic, retain, readonly) NSString *location;
@property (nonatomic, retain, readonly) NSURL *bioURL;
@property (nonatomic, retain, readonly) UIImage *profilePic;
@property (nonatomic, assign, readonly) NSInteger following;
@property (nonatomic, assign, readonly) NSInteger followers;
@property (nonatomic, assign, readonly) NSInteger tweetCount;
@property (nonatomic, assign, readonly) BOOL requiresAuthentication;

//A list of PBTweets objects
@property (nonatomic, retain, readonly) NSArray *tweets;

//Grant access to some private features from within the API
@property (nonatomic, retain) ACAccount *account;

//Retrieve the information from twitter, return nil if the user does not exit, plus you can either authorize or not the request
-(id)initWithUsername:(NSString *)theUsername andAuthorizedAccount:(ACAccount *)accountOrNil;

//Once you have initialized the user, request it's data and asynchronously wait for the response
-(void)requestUserData:(PBTRequestHandler)handler;

//The number of tweets will be truncated to 3,200 and is executed asynchronously
-(void)requestMostRecentTweets:(NSInteger)numberOfTweets withHandler:(PBTRequestHandler)handler;

//Requests up to 3200 tweets, this limited is as imposed by the Twitter API and is executed asynchronously
-(void)requestAllTweetsWithHandler:(PBTRequestHandler)handler;

//This method parses the array of tweets looking for tweets containing the indicated string
-(NSArray *)tweetsMentioning:(NSString *)string;

@end
