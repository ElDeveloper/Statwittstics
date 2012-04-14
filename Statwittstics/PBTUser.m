//
//  PBTUser.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 08/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBTUser.h"

NSString *kPBTUsersShow=        @"https://api.twitter.com/1/users/show.json";
NSString *kPBTUserTimeline=     @"https://api.twitter.com/1/statuses/user_timeline.json";

NSString const *kPBTUsernameKey=      @"screen_name";
NSString const *kPBTRealNameKey=      @"name";
NSString const *kPBTDescriptionKey=   @"description";
NSString const *kPBTLocationKey=      @"location";
NSString const *kPBTProfilePictureURL=@"profile_image_url";
NSString const *kPBTBioURLKey=        @"url";
NSString const *kPBTFollowingKey=     @"friends_count";
NSString const *kPBTFollowersKey=     @"followers_count";
NSString const *kPBTTweetsKey=        @"statuses_count";
NSString const *kPBTProtectedKey=     @"protected";

NSUInteger const kPBTRequestMaximum= 3200;

@implementation PBTUser

@synthesize username, realName, description, location, bioURL;
@synthesize profilePic;
@synthesize following, followers, tweetCount;
@synthesize requiresAuthentication;
@synthesize tweets;
@synthesize account;

-(id)initWithUsername:(NSString *)theUsername andAuthorizedAccount:(ACAccount *)accountOrNil{
    if (self = [super init]) {
        username=[[NSString alloc] initWithString:theUsername];
        profilePic=[UIImage imageNamed:@"DefaultUser.png"];
        
        //Keep a copy for yourself only if it is provided
        if (accountOrNil) {
            account=[accountOrNil retain];
        }
        
        //Set everything to nil or a netural value
        realName=nil;
        description=nil;
        location=nil;
        bioURL=nil;
        profilePic=nil;
        tweets=nil;
        following=0;
        followers=0;
        tweetCount=0;
        requiresAuthentication=NO;
        
        _lastTweetID=nil;
        _tempArray=nil;
    }
    return self;
}

-(void)dealloc{
    [username release];
    [account release];
    [realName release];
    [description release];
    [location release];
    [bioURL release];
    
    [super dealloc];
}

-(void)requestUserData:(PBTRequestHandler)handler{
    //URL, parameters and request object initialized to retrieve the data
    NSURL *userDataRequest=[NSURL URLWithString:kPBTUsersShow];
    NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:[self username], kPBTUsernameKey, @"false", @"include_entities", nil];
    TWRequest *userData=[[TWRequest alloc] initWithURL:userDataRequest parameters:parameters requestMethod:TWRequestMethodGET];
    
    //Authorize if provided
    if (account != nil) {
        [userData setAccount:account];
    }
    
    //Make the call
    [userData performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError *jsonError=nil;
        id jsonString=nil, temp=nil;
        
        //Check for errors in the request
        if (!error) {
            
            //The JSON object is a Dictionary
            jsonString=[NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            
            //Twitter wouldn't return badly serilized JSON objects but if anything
            if (!jsonError) {
                #ifdef VERBOSE_DEBUG
                NSLog(@"%@", jsonString);
                #endif
                
                //All these properties are always in the profile of a user
                realName=[[NSString alloc] initWithString:[jsonString objectForKey:kPBTRealNameKey]];
                following=[[jsonString objectForKey:kPBTFollowingKey] intValue];
                tweetCount=[[jsonString objectForKey:kPBTTweetsKey] intValue];
                
                
                //These properties might as well be returned as NSNull
                if ( (temp = [jsonString objectForKey:kPBTDescriptionKey]) != [NSNull null] ) {
                    description=[[NSString alloc] initWithString:temp];
                }
                else {
                    description=[[NSString alloc] initWithString:@""];
                }
                if ( (temp = [jsonString objectForKey:kPBTLocationKey]) != [NSNull null] ) {
                    location=[[NSString alloc] initWithString:temp];
                }
                else {
                    location=[[NSString alloc] initWithString:@""];
                }
                if ( (temp = [jsonString objectForKey:kPBTBioURLKey]) != [NSNull null] ) {
                    bioURL=[[NSURL alloc] initWithString:temp];
                }
                else {
                    bioURL=[[NSURL alloc] initWithString:@""];
                }
                
                
                //If the user is not protected, you can ask for the number of followers he/she has, the use of the
                //ternary operator is merely to fit everything in one line, and cast the int value to a BOOL
                if ( (requiresAuthentication = ( [[jsonString objectForKey:kPBTProtectedKey] intValue] ? YES : NO)) ) {
                    followers=0;
                }
                else {
                    followers=[[jsonString objectForKey:kPBTFollowersKey] intValue];
                }
                
                //The request of the image won't stop the application, but rather it can ask for the data
                //and get it back sometime soon
                if ( (temp = [jsonString objectForKey:kPBTProfilePictureURL]) != [NSNull null]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSData *tempData=[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]];
                        profilePic=[UIImage imageWithData:tempData];
                    
                        //Finally when everything is done, perform the handler
                        handler();
                    });//profile picture request block
                }
            }//JSON error
        }//data request error
    }];//Twitter API request block

}

-(void)requestMostRecentTweets:(NSInteger)numberOfTweets withHandler:(PBTRequestHandler)handler{
    NSLog(@"Requesting %d", numberOfTweets);
    
    //If the total request needs you to ask for more than 200 tweets, truncate the number, using the ternary operator
    NSString *stringNumberOfTweets=[NSString stringWithFormat:@"%d",(numberOfTweets > 200 ? 200 : numberOfTweets)];
    
    //URL, parameters and request object initialized to retrieve the data
    NSURL *userDataRequest=[NSURL URLWithString:kPBTUserTimeline];
    NSDictionary *parameters=nil;
    
    //These variables get re-usede in recursive calls, so they shall be initialized every first time this 
    //is called, for the first call you don't have a max_id property so, the dict goes as follows ...
    if (_lastTweetID == nil) {
        _tempArray=[[NSMutableArray alloc] init];
        _remainingTweets=numberOfTweets;
        parameters=[NSDictionary dictionaryWithObjectsAndKeys:[self username], kPBTUsernameKey, 
                    stringNumberOfTweets, @"count", 
                    @"true", @"include_entities", nil];
    }
    else {
        parameters=[NSDictionary dictionaryWithObjectsAndKeys:[self username], kPBTUsernameKey, 
                    stringNumberOfTweets, @"count", 
                    @"true", @"include_entities", 
                    _lastTweetID, @"max_id", nil];
    }
    
    //Depending on the run use the parameters initialized
    TWRequest *userData=[[TWRequest alloc] initWithURL:userDataRequest parameters:parameters requestMethod:TWRequestMethodGET];
    
    //Authorize if provided
    if (account != nil) {
        [userData setAccount:account];
    }
    
    [userData performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        id jsonString=nil;
        NSError *jsonError=nil;
        PBTweet *tempTweet=nil;
        
        //There is no connection error, go for it
        if (!error) {
            jsonString=[NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            
            //There is no JSON serialization error, go for it
            if (!jsonError) {
                for (NSDictionary *object in (NSArray *)jsonString) {
                    
                    //Store one tweet in a object, add it to a temporary array, then release it
                    tempTweet=[[PBTweet alloc] initWithJSONData:object];
                    
                    #ifdef VERBOSE_DEBUG
                    NSLog(@"Twitt text: %@", [tempTweet text]);
                    NSLog(@"In reply to: %@", [tempTweet inReplyToScreenName]);
                    NSLog(@"Mentioned users: %@", [tempTweet mentionedScreenNames]);
                    NSLog(@"Media: %@", [tempTweet mediaURLs]);
                    #endif
                    _lastTweetID=[tempTweet tweetID];
                    [_tempArray addObject:tempTweet];
                    [tempTweet release];
                }
                
                _remainingTweets=_remainingTweets-[stringNumberOfTweets intValue];
                NSLog(@"Current size %d", [_tempArray count]);
                
                //More tweets to retrieve
                if ( _remainingTweets != 0 ) {
                    [self requestMostRecentTweets:_remainingTweets withHandler:^{
                        
                    }];
                }
                else {
                    NSLog(@"Last call ...");
                    //Assign the tweets to the user
                    tweets=[[NSArray alloc] initWithArray:(NSArray *)_tempArray];
                    
                    //Re-initialize the properties
                    _lastTweetID=nil;
                    [_tempArray release];
                    _remainingTweets=0;
                    
                    //Finally call the handler
                    NSLog(@"Total count %d", [tweets count]);
                    handler();
                    NSLog(@"What up ...");
                }
            }
            else {
                //JSON serialization error management
                NSLog(@"PBTUser(J)**:%@",[jsonError localizedDescription]);
            }
            
        }
        else {
            //Connection error managment 
            NSLog(@"PBTUser(R)**:%@", [error localizedDescription]);
        }
    }];
}

-(void)requestAllTweetsWithHandler:(PBTRequestHandler)handler{
    NSUInteger requestedTwitts=tweetCount;
    
    //The API is limitted to 3,200 twitts, so clamp that
    if (tweetCount > 3200) {
        requestedTwitts=3200;
        NSLog(@"PBTUser**:Warning: Clamping the requested number of tweets to %d.", tweetCount);
    }
    
    //Have to do this in chunks of 200
    [self requestMostRecentTweets:requestedTwitts withHandler:^{
        handler();
    }];
}

-(NSArray *)tweetsMentioning:(NSString *)string{
    return nil;
}

@end
