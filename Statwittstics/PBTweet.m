//
//  PBTweet.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 07/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBTweet.h"

NSString *kPBTEntitiesKey=@"entities";
NSString *kPBTInToReplyScreenNameKey=@"in_reply_to_screen_name";
NSString *kPBTIsRetweetKey=@"retweeted";
NSString *kPBTMediaKey=@"media";
NSString *kPBTMediaURLKey=@"media_url";
NSString *kPBTMentionsKey=@"user_mentions";
NSString *kPBTPostDateKey=@"created_at";
NSString *kPBTScreenName=@"screen_name";
NSString *kPBTSourceKey=@"source";
NSString *kPBTTextKey=@"text";
NSString *kPBTTweetIDKey=@"id_str";

@implementation PBTweet

@synthesize text, postDate, source, isRetweet;
@synthesize mediaURLs, hasPicture;
@synthesize inReplyToScreenName, mentionedScreenNames;
@synthesize tweetID;

-(id)initWithJSONData:(NSDictionary *)jsonString{
    if (self = [super init]) {
        id temp=nil;
        NSDateFormatter *dateFromatter=nil;
        NSMutableArray *tempScreenNames=[NSMutableArray array];
        NSMutableArray *tempMediaURLs=[NSMutableArray array];
        
        //These properties are always present
        text=[[NSString alloc] initWithString:[jsonString objectForKey:kPBTTextKey]];
        source=[[NSString alloc] initWithString:[jsonString objectForKey:kPBTSourceKey]];
        tweetID=[[NSString alloc] initWithString:[jsonString objectForKey:kPBTTweetIDKey]];
        
        //Post date ... yet to be assigned
        //First set the type of format for the date
        dateFromatter=[[NSDateFormatter alloc] init];
        [dateFromatter setDateStyle:NSDateFormatterFullStyle];
        [dateFromatter setDateFormat:@"yyyyMMdd"];
        postDate=[[dateFromatter dateFromString:[jsonString objectForKey:kPBTPostDateKey]] copy];
        
        //Has picture attribute has to be determined from the entities array 
        
        //Ternary operator to set the isRetweet attribute, from a string
        isRetweet=([[jsonString objectForKey:kPBTIsRetweetKey] intValue] ? YES : NO);
        
        //Only create the object if there is something in the dictionary
        if ( (temp=[jsonString objectForKey:kPBTInToReplyScreenNameKey]) != [NSNull null]) {
            inReplyToScreenName=[[NSString alloc] initWithString:temp];
        }
        else {
            inReplyToScreenName=[[NSString alloc] initWithString:@""];
        }
        
        //Check if the mentions array even exists, if you request for an object with a non-existing key
        //the result is going to be nil
        if ( (temp=[[jsonString objectForKey:kPBTEntitiesKey] objectForKey:kPBTMentionsKey]) != nil ) {
            //Go through all the users and get the screen names
            for (NSDictionary *dict in (NSArray *)temp) {
                [tempScreenNames addObject:[dict objectForKey:kPBTScreenName]];
            }
            
            //Finally add everything to the property
            mentionedScreenNames=[[NSArray alloc] initWithArray:tempScreenNames];
        }
        else {
            mentionedScreenNames=[[NSArray alloc] init];
        }
        
        //Check if the media array even exists, if you request for an object with a non-existing key
        //the result is going to be nil
        if ( (temp=[[jsonString objectForKey:kPBTEntitiesKey] objectForKey:kPBTMediaKey]) != nil ) {
            //First thing first, this tweet has media
            hasPicture=YES;
            
            //Go through all the incedences of media
            for (NSDictionary *dict in (NSArray *)temp ) {
                [tempMediaURLs addObject:[NSURL URLWithString:[dict objectForKey:kPBTMediaURLKey]]];
            }
            
            //Finally add everything to the property
            mediaURLs=[[NSArray alloc] initWithArray:tempMediaURLs];
        }
        else {
            mediaURLs=[[NSArray alloc] init];
            hasPicture=NO;
        }
        
        
        
    }
    return self;
}

-(void)dealloc{
    [text release];
    [source release];
    [tweetID release];
    [postDate release];
    [inReplyToScreenName release];
    [mentionedScreenNames release];
    [mediaURLs release];

    [super dealloc];
}

@end
