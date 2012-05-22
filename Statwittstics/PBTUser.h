//
//  PBTUser.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 08/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBTDefines.h"
#import "PBTweet.h"
#import "PBTUtilities.h"
#import "PBKit.h"

//General handler for the blocks, if an error occurs in the in the method where
//the caller is called, the handler won't be called , to avoid conflicts.
typedef void __block (^PBTRequestHandler)(void);

//General constants
extern NSUInteger const kPBTRequestMaximum;

@interface PBTUser : NSObject{
    NSString *username;
    NSString *realName;
    NSString *description;
    NSString *location;
    NSURL *bioURL;
    
    NSData *imageData;
    
    NSInteger following;
    NSInteger followers;
    NSInteger tweetCount;
    
    NSArray *tweets;
    
    BOOL requiresAuthentication;
    BOOL isVerified;
    
    @private ACAccount *account;
    
    //Used for the recursive request
    @private NSMutableArray *_tempArray;
    @private NSUInteger _remainingTweets;
    @private NSString *_lastTweetID;
    @private PBTRequestHandler _vamooseHandler;
}

//Basic information found in the profile of a Twitter user
@property (nonatomic, retain, readonly) NSString *username;
@property (nonatomic, retain, readonly) NSString *realName;
@property (nonatomic, retain, readonly) NSString *description;
@property (nonatomic, retain, readonly) NSString *location;
@property (nonatomic, retain, readonly) NSURL *bioURL;
@property (atomic, retain) NSData *imageData;
@property (nonatomic, assign, readonly) NSInteger following;
@property (nonatomic, assign, readonly) NSInteger followers;
@property (nonatomic, assign, readonly) NSInteger tweetCount;
@property (nonatomic, assign, readonly) BOOL requiresAuthentication;
@property (nonatomic, assign, readonly) BOOL isVerified;

//A list of PBTweets objects
@property (nonatomic, retain, readonly) NSArray *tweets;

//Grant access to some private features from within the API
@property (nonatomic, retain) ACAccount *account;

//Basic constructor
-(id)init;

//Various forms of initializing the object
-(id)initWithUsername:(NSString *)theUsername andAuthorizedAccount:(ACAccount *)accountOrNil;
-(id)initWithJSONString:(id)jsonString;

//Generalize the loading of a user from a JSON string
-(void)loadFromJSONString:(NSString *)jsonString;

//Once you have initialized the user, request it's data and asynchronously wait for the response
-(void)requestUserData:(PBTRequestHandler)handler;

//Request the profile picture of the current user, with a specified size, this is done asynchronously
-(void)requestProfilePictureWithSize:(TAImageSize)size andHandler:(PBTRequestHandler)handler;

//The number of tweets will be truncated to 3,200 and is executed asynchronously
-(void)requestMostRecentTweets:(NSInteger)numberOfTweets withHandler:(PBTRequestHandler)handler;

//Requests up to 3200 tweets, this limited is as imposed by the Twitter API and is executed asynchronously
-(void)requestAllTweetsWithHandler:(PBTRequestHandler)handler;

//This method parses the array of tweets looking for tweets containing the indicated string
-(NSArray *)tweetsMentioningUsername:(NSString *)someUsername;

//Returns a PBDataSet, containing the tweets per unit of time specified by the
//calendarUnit parameter, currently only (day/week/month) are supported
-(PBDataSet *)dataSetOfTweetsPerCalendarUnit:(NSCalendarUnit)calendarUnit;

-(PBDataSet *)dataSetOfTweetsForHourPerDay;

//Recursive way to request as many tweets as needed, requesting them in chunks of 200 tweets
void PBTRequestTweets(PBTUser *client, NSUInteger numberOfTweets,  NSString *lastTweetID, NSMutableArray **tweetsBuffer, PBTRequestHandler handler);

@end
