//
//  PBTweet.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 07/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBTweet.h"

@implementation PBTweet

@synthesize text, postDate, source, isRetweet;
@synthesize mediaURLs, hasPicture;
@synthesize inReplyToScreenName, mentionedScreenNames;
@synthesize tweetID;

-(id)initWithJSONData:(NSDictionary *)jsonString{
    if (self = [super init]) {
        id temp=nil;
        NSDateFormatter *dateFormatter=nil;
        NSLocale *usLocale=nil;
        NSMutableArray *tempScreenNames=[NSMutableArray array];
        NSMutableArray *tempMediaURLs=[NSMutableArray array];
        
        //These properties are always present
        text=[[NSString alloc] initWithString:[jsonString objectForKey:TAKeyText]];
        source=[[NSString alloc] initWithString:[jsonString objectForKey:TAKeySource]];
        tweetID=[[NSString alloc] initWithString:[jsonString objectForKey:TAKeyTweetID]];
        
        //The date come from twitter in the following format Mon Apr 16 00:57:16 +0000 2012
        //therefore, our formatter has to know it is a US formatted date
        dateFormatter=[[NSDateFormatter alloc] init];
        usLocale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:usLocale]; 
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        
        //For further information look here: http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns
        [dateFormatter setDateFormat: @"EEE MMM dd HH:mm:ss +0000 yyyy"];
        
        //Assign the post date 
        postDate=[[dateFormatter dateFromString:[jsonString objectForKey:TAKeyPostDate]] copy];
        
        //Ternary operator to set the isRetweet attribute, from a string
        isRetweet=([[jsonString objectForKey:TAKeyIsRetweet] intValue] ? YES : NO);
        
        //Only create the object if there is something in the dictionary
        if ( (temp=[jsonString objectForKey:TAKeyInToReplyScreenName]) != [NSNull null]) {
            inReplyToScreenName=[[NSString alloc] initWithString:temp];
        }
        else {
            inReplyToScreenName=[[NSString alloc] initWithString:@""];
        }
        
        //Check if the mentions array even exists, if you request for an object with a non-existing key
        //the result is going to be nil
        if ( (temp=[[jsonString objectForKey:TAKeyEntities] objectForKey:TAKeyMentions]) != nil ) {
            //Go through all the users and get the screen names
            for (NSDictionary *dict in (NSArray *)temp) {
                [tempScreenNames addObject:[dict objectForKey:TAKeyScreenName]];
            }
            
            //Finally add everything to the property
            mentionedScreenNames=[[NSArray alloc] initWithArray:tempScreenNames];
        }
        else {
            mentionedScreenNames=[[NSArray alloc] init];
        }
        
        //Check if the media array even exists, if you request for an object with a non-existing key
        //the result is going to be nil
        if ( (temp=[[jsonString objectForKey:TAKeyEntities] objectForKey:TAKeyMedia]) != nil ) {
            //First thing first, this tweet has media
            hasPicture=YES;
            
            //Go through all the incedences of media
            for (NSDictionary *dict in (NSArray *)temp ) {
                [tempMediaURLs addObject:[NSURL URLWithString:[dict objectForKey:TAKeyMediaURL]]];
            }
            
            //Finally add everything to the property
            mediaURLs=[[NSArray alloc] initWithArray:tempMediaURLs];
        }
        else {
            mediaURLs=[[NSArray alloc] init];
            hasPicture=NO;
        }
        
        //Date memory management
        [usLocale release];
        [dateFormatter release];
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
