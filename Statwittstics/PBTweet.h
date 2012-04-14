//
//  PBTweet.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 07/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBTDefines.h"

//API keys 
extern NSString *kPBTEntitiesKey;
extern NSString *kPBTInToReplyScreenNameKey;
extern NSString *kPBTIsRetweetKey;
extern NSString *kPBTMediaKey;
extern NSString *kPBTMediaURLKey;
extern NSString *kPBTMentionsKey;
extern NSString *kPBTPostDateKey;
extern NSString *kPBTScreenName;
extern NSString *kPBTSourceKey;
extern NSString *kPBTTextKey;
extern NSString *kPBTTweetIDKey;

@interface PBTweet : NSObject{
    NSString *text;
    NSDate *postDate;
    NSString *source;    
    BOOL isRetweet;

    NSArray *mediaURLs;
    BOOL hasPicture;
    
    NSString *inReplyToScreenName;
    NSArray *mentionedScreenNames;
    
    NSString *tweetID;
}

//General twitt data
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSDate *postDate;
@property (nonatomic, retain) NSString *source;
@property (nonatomic, assign) BOOL isRetweet;

//Extra twitt data
@property (nonatomic, retain) NSArray *mediaURLs;
@property (nonatomic, assign) BOOL hasPicture;

//Meta-extra twitt data
@property (nonatomic, retain) NSString *inReplyToScreenName;
@property (nonatomic, retain) NSArray *mentionedScreenNames;

@property (nonatomic, retain, readonly) NSString *tweetID;

//Everything is done in this method ... 
-(id)initWithJSONData:(NSDictionary *)jsonString;

@end