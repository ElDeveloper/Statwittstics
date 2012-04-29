//
//  PBTUser.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 08/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBTUser.h"

NSUInteger const kPBTRequestMaximum= 3200;

@implementation PBTUser

@synthesize username, realName, description, location, bioURL;
@synthesize imageData;
@synthesize following, followers, tweetCount;
@synthesize requiresAuthentication;
@synthesize tweets;
@synthesize account;

#pragma mark - Object Lifecycle
-(id)init{
    if( self = [super init] ){
        //Set everything to nil or a netural value
        username=nil;
        account=nil;
        realName=nil;
        description=nil;
        location=nil;
        bioURL=nil;
        imageData=nil;
        tweets=nil;
        following=0;
        followers=0;
        tweetCount=0;
        requiresAuthentication=NO;
        
        _lastTweetID=nil;
        _tempArray=nil;
        _vamooseHandler=nil;
    }
    return self;
}

-(id)initWithUsername:(NSString *)theUsername andAuthorizedAccount:(ACAccount *)accountOrNil{
    if (self = [self init]) {
        username=[[NSString alloc] initWithString:theUsername];
        //Keep a copy for yourself only if it is provided
        if (accountOrNil) {
            account=[accountOrNil retain];
        }
    }
    return self;
}

-(id)initWithJSONString:(NSString *)jsonString{
    if ( self = [self init] ) {
        [self loadFromJSONString:jsonString];
    }
    return self;
}

-(void)loadFromJSONString:(id)jsonString{
    id temp=nil;
    
    //Sometimes you have this property, sometimes you don't depending on the type of initialization
    if (username == nil) {
        username=[[NSString alloc] initWithString:[jsonString objectForKey:TAKeyUsername]];
    }
    
    //All these properties are always in the profile of a user
    realName=[[NSString alloc] initWithString:[jsonString objectForKey:TAKeyRealName]];
    following=[[jsonString objectForKey:TAKeyFollowing] intValue];
    tweetCount=[[jsonString objectForKey:TAKeyTweets] intValue];
    
    //These properties might as well be returned as NSNull
    if ( (temp = [jsonString objectForKey:TAKeyDescription]) != [NSNull null] ) {
        description=[[NSString alloc] initWithString:temp];
    }
    else {
        description=[[NSString alloc] initWithString:@""];
    }
    if ( (temp = [jsonString objectForKey:TAKeyLocation]) != [NSNull null] ) {
        location=[[NSString alloc] initWithString:temp];
    }
    else {
        location=[[NSString alloc] initWithString:@""];
    }
    if ( (temp = [jsonString objectForKey:TAKeyBioURL]) != [NSNull null] ) {
        bioURL=[[NSURL alloc] initWithString:temp];
    }
    else {
        bioURL=[[NSURL alloc] initWithString:@""];
    }
    
    //If the user is not protected, you can ask for the number of followers he/she has, the use of the
    //ternary operator is merely to fit everything in one line, and cast the int value to a BOOL
    if ( (requiresAuthentication = ( [[jsonString objectForKey:TAKeyProtected] intValue] ? YES : NO)) ) {
        followers=0;
        
        //Check just in case you have permission to see the profile
        if ([[jsonString objectForKey:TAKeyFollowers] intValue] != 0){
            followers=[[jsonString objectForKey:TAKeyFollowers] intValue];
        }
    }
    else {
        followers=[[jsonString objectForKey:TAKeyFollowers] intValue];
    }
    
}

-(void)dealloc{
    [username release];
    [account release];
    [realName release];
    [description release];
    [location release];
    [bioURL release];
    [imageData release];
    
    [super dealloc];
}

#pragma mark - Data Request Methods
-(void)requestUserData:(PBTRequestHandler)handler{
    //URL, parameters and request object initialized to retrieve the data
    NSURL *userDataRequest=[NSURL URLWithString:TAUUsersShow];
    NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:[self username], TAKeyUsername, @"false", @"include_entities", nil];
    TWRequest *userData=[[TWRequest alloc] initWithURL:userDataRequest parameters:parameters requestMethod:TWRequestMethodGET];
    
    //Authorize if provided
    if (account != nil) {
        [userData setAccount:account];
    }
    
    //Make the call
    [userData performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError *jsonError=nil;
        id jsonString=nil;
        
        //Check for errors in the request
        if (!error) {
            
            //The JSON object is a Dictionary
            jsonString=[NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            
            //Twitter wouldn't return badly serilized JSON objects but if anything
            if (!jsonError) {
                #ifdef JSON_STRINGS_DEBUG
                NSLog(@"PBTUser**:\n%@", jsonString);
                #endif
                
                //Load the information from the JSON string
                [self loadFromJSONString:jsonString];
                
                [self requestProfilePictureWithSize:TAImageSizeBigger andHandler:^{
                    //Finally when everything is done, perform the handler
                    handler();
                }];

            }//JSON error
            else {
                //JSON serialization error management
                NSLog(@"PBTUser(J)**:%@",[jsonError localizedDescription]);
            }
        }//data request error
    }];//Twitter API request block

}

-(void)requestProfilePictureWithSize:(TAImageSize)size andHandler:(PBTRequestHandler)handler{
    NSURL *userDataRequest=[NSURL URLWithString:TAUImageData];
    NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:[self username], TAKeyUsername, size, @"size", nil];
    TWRequest *userData=[[TWRequest alloc] initWithURL:userDataRequest parameters:parameters requestMethod:TWRequestMethodGET];
    
    [userData performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        #ifdef DEBUG
        NSLog(@"PBTUser(I)**:%@", [urlResponse URL]);
        #endif
        
        if (!error) {
            imageData=[[NSData alloc] initWithData:responseData];
            handler();
        }
        else {
            NSLog(@"PBTUser(I)**:%@", [error localizedDescription]);
        }
    }];
}

-(void)requestMostRecentTweets:(NSInteger)numberOfTweets withHandler:(PBTRequestHandler)handler{
    #ifdef DEBUG
    NSLog(@"PBTUSER:**Remaining to get %d", numberOfTweets);
    #endif
    
    //In case the user requests more than what you can actually get
    if ([self tweetCount] < numberOfTweets) {
        numberOfTweets=tweetCount;
    }
    
    //If the total request needs you to ask for more than 200 tweets, truncate the number, using the ternary operator
    NSString *stringNumberOfTweets=[NSString stringWithFormat:@"%d",(numberOfTweets > 200 ? 200 : numberOfTweets)];
    
    //URL, parameters and request object initialized to retrieve the data
    NSURL *userDataRequest=[NSURL URLWithString:TAUUserTimeline];
    NSDictionary *parameters=nil;
    
    //These variables get re-usede in recursive calls, so they shall be initialized every first time this 
    //is called, for the first call you don't have a max_id property so, the dict goes as follows ...
    if (_lastTweetID == nil) {
        _tempArray=[[NSMutableArray alloc] init];
        _remainingTweets=numberOfTweets;
        _vamooseHandler=[handler copy];

        parameters=[NSDictionary dictionaryWithObjectsAndKeys:[self username], TAKeyUsername, 
                    stringNumberOfTweets, @"count", 
                    @"true", @"include_entities", nil];
    }
    else {        
        parameters=[NSDictionary dictionaryWithObjectsAndKeys:[self username], TAKeyUsername, 
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
            
            #ifdef JSON_STRINGS_DEBUG
            NSLog(@"PBTUser**:%@", jsonString);
            #endif
            
            //There is no JSON serialization error, go for it
            if (!jsonError) {
                for (NSDictionary *object in (NSArray *)jsonString) {
                    
                    //Store one tweet in a object, add it to a temporary array, then release it
                    tempTweet=[[PBTweet alloc] initWithJSONData:object];
                    
                    #ifdef VERBOSE_DEBUG
                    NSLog(@"PBTUser:**Twitt text: %@", [tempTweet text]);
                    NSLog(@"PBTUser:**Created at: %@", [tempTweet postDate]);
                    
                    if ( ![[tempTweet inReplyToScreenName] isEqualToString:@""] ) {
                        NSLog(@"PBTUser:**In reply to: %@", [tempTweet inReplyToScreenName]);
                    }
                    
                    if ( [[tempTweet mentionedScreenNames] count] != 0 ) {
                        NSLog(@"PBTUser:**Mentioned users: %@", [tempTweet mentionedScreenNames]);
                    }
                    
                    if ([[tempTweet mediaURLs] count] != 0) {
                        NSLog(@"PBTUser:**Media: %@", [tempTweet mediaURLs]);
                    }
                    #endif
                    
                    _lastTweetID=[tempTweet tweetID];
                    [_tempArray addObject:tempTweet];
                    [tempTweet release];
                }
                
                _remainingTweets=_remainingTweets-[stringNumberOfTweets intValue];
                
                #ifdef DEBUG
                NSLog(@"PBTUser:**Current size %d", [_tempArray count]);
                #endif
                
                //More tweets to retrieve
                if ( _remainingTweets > 0 ) {
                    [self requestMostRecentTweets:_remainingTweets withHandler:^{}];
                }
                else {
                    #ifdef DEBUG
                    NSLog(@"PBTUser:**Last call, total number of tweets %d", [_tempArray count]);
                    #endif
                    
                    //Assign the tweets to the user
                    tweets=[[NSArray alloc] initWithArray:_tempArray];
                    [_tempArray release];
                    _tempArray=nil;
                    
                    //Re-initialize the properties
                    _lastTweetID=nil;
                    _remainingTweets=0;

                    //Finally call the handler, release and re-start the variable
                    _vamooseHandler();
                    [_vamooseHandler release];
                    _vamooseHandler=nil;
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
    if (tweetCount > kPBTRequestMaximum) {
        requestedTwitts=kPBTRequestMaximum;
        NSLog(@"PBTUser**:Warning: Clamping the requested number of tweets to %d.", tweetCount);
    }
    
    //Have to do this in chunks of 200
    [self requestMostRecentTweets:requestedTwitts withHandler:^{
        handler();
    }];
}

-(NSArray *)tweetsMentioningUsername:(NSString *)someUsername{
    //Since this is a return value, we better create an auto-released version of it
    NSMutableArray *outputArray=[NSMutableArray array];
    
    //Do not even search, the tweets haven't been retrieved
    if (tweets == nil) {
        return nil;
    }
    
    //Go through all the tweets 
    for ( PBTweet *tweet in [self tweets] ) {
        //In each tweet go through all the usernames
        for( NSString *oneScreenName in [tweet mentionedScreenNames]){
            //If you find a username in that tweet, add that tweet
            if ([oneScreenName isEqualToString:someUsername]) {
                [outputArray addObject:tweet];
                
                //Do not do any more search this tweet already mentions the desired
                //username, go to the next one
                break;
            }
        }
    }
    
    //Cast to it's un-mutable representation
    return (NSArray *)outputArray;
}

#pragma mark - PBDataSet Methods
-(PBDataSet *)tweetsPerDayDataSet{
    PBDataSet *outDataSet=nil;
    
    NSUInteger totalDays=0, i=0, totalTweets=0, newIndex=0, *bufferArray=NULL;
    NSDate *startDate=nil, *endDate=nil;
    NSMutableArray *xData=nil, *yData=nil;
    
    //General usage constants, helps you build the linear space and plot
    startDate=[[tweets objectAtIndex:0] postDate];
    endDate=[[tweets objectAtIndex:[tweets count]-1] postDate];
    
    //Cast to a unsigned integer
    totalDays=(NSUInteger)PBTDaysBetweenDates(endDate, startDate);
    
    //Actual data holders
    totalTweets=[tweets count];
    xData=[PBTLinspace(0, totalDays, totalDays) retain]; 
    yData=[[NSMutableArray alloc] initWithCapacity:totalDays];

    //printf("The total days is %d, the size of the x array is %d and the size of the y array is %d\n", totalDays, [xData count], [yData count]);
    
    //Get rid of some of the overhead of using a NSArray object and just use a C array
    bufferArray=malloc(sizeof(NSUInteger)*totalDays);
    
    //Just plain and old array cleaning
    for (i=0; i<totalDays; i++) {
        bufferArray[i]=0;
    }
    
    #ifdef DEBUG
    NSLog(@"Value of TotalDays %d", totalDays);
    #endif
    
    //Got through each tweet and count the number of tweets that are in a same day
    for (i=0; i<totalTweets; i++) {
        //Get the current difference
        newIndex=PBTDaysBetweenDates([[tweets objectAtIndex:i] postDate], startDate);
        bufferArray[newIndex]=bufferArray[newIndex]+1;
    }
    
    //Now add these values to the array of the y data
    for (i=0; i<totalDays; i++) {
        [yData addObject:[NSNumber numberWithUnsignedInteger:(NSUInteger)bufferArray[i]]];
    }
    
    NSLog(@"Size of the xdata: %d size of the ydata: %d", [xData count], [yData count]);
    
    //Create the return value
    outDataSet=[[PBDataSet alloc] initWithXData:xData yData:yData andTitle:[NSString stringWithFormat:@"Tweets per Day for %@", [self realName]]];
    [outDataSet setLineColor:[CPTColor whiteColor]];
    
    //Free your mallocs
    free(bufferArray);
    
    [xData release];
    [yData release];
    
    return [outDataSet autorelease];
}

#pragma mark - General Use Functions
NSInteger PBTDaysBetweenDates(NSDate *fromDate, NSDate *toDate){
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate interval:NULL forDate:fromDate];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate interval:NULL forDate:toDate];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];    
}

NSMutableArray* PBTZeros(NSUInteger length){
    NSMutableArray *outArray=[NSMutableArray arrayWithCapacity:length];
    NSUInteger i=0;

    for (i=0; i<length; i++) {
        [outArray addObject:[NSNumber numberWithFloat:0]];
    }
    return outArray;
}

NSMutableArray* PBTLinspace(float from, float to, NSUInteger elements){
    NSMutableArray *outArray=[NSMutableArray arrayWithCapacity:elements];
    NSUInteger i=0;
    float interval=(to-from)/elements;
    
    for (i=0; i<elements; i++) {
        [outArray addObject:[NSNumber numberWithFloat:i*interval]];
    }
    return outArray;
}

void PBTRequestTweets(PBTUser *client, NSUInteger numberOfTweets,  NSString *lastTweetID, NSMutableArray **tweetsBuffer, PBTRequestHandler handler){
    //If the total request needs you to ask for more than 200 tweets, truncate the number, using the ternary operator
    NSString *stringNumberOfTweets=[NSString stringWithFormat:@"%d",(numberOfTweets > 200 ? 200 : numberOfTweets)];
    
    //URL, parameters and request object initialized to retrieve the data
    NSURL *userDataRequest=[NSURL URLWithString:TAUUserTimeline];
    NSDictionary *parameters=nil;
    
    __block PBTUser *_client=client;
    __block NSUInteger _numberOfTweets=numberOfTweets;
    __block NSString *_lastTweetID=lastTweetID;
    __block NSMutableArray *_tweetsBuffer=*(tweetsBuffer);
    PBTRequestHandler _handler;
    
    //These variables get re-usede in recursive calls, so they shall be initialized every first time this 
    //is called, for the first call you don't have a max_id property so, the dict goes as follows ...
    if (lastTweetID == nil) {
        _handler=Block_copy(handler);
        parameters=[NSDictionary dictionaryWithObjectsAndKeys:[client username], TAKeyUsername, 
                    stringNumberOfTweets, @"count", 
                    @"true", @"include_entities", nil];
    }
    else {        
        parameters=[NSDictionary dictionaryWithObjectsAndKeys:[client username], TAKeyUsername, 
                    stringNumberOfTweets, @"count", 
                    @"true", @"include_entities", 
                    _lastTweetID, @"max_id", nil];
    }
    
    //Depending on the run use the parameters initialized
    TWRequest *userData=[[TWRequest alloc] initWithURL:userDataRequest parameters:parameters requestMethod:TWRequestMethodGET];
    
    //Authorize if provided
    if ([client account] != nil) {
        [userData setAccount:[client account]];
    }
    
    [userData performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        id jsonString=nil;
        NSError *jsonError=nil;
        PBTweet *tempTweet=nil;
        
        //There is no connection error, go for it
        if (!error) {
            jsonString=[NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            
            #ifdef JSON_STRINGS_DEBUG
            NSLog(@"PBTUser**:%@", jsonString);
            #endif
            
            //There is no JSON serialization error, go for it
            if (!jsonError) {
                for (NSDictionary *object in (NSArray *)jsonString) {
                    
                    //Store one tweet in a object, add it to a temporary array, then release it
                    tempTweet=[[PBTweet alloc] initWithJSONData:object];
                    
                    #ifdef VERBOSE_DEBUG
                    NSLog(@"PBTUser:**Twitt text: %@", [tempTweet text]);
                    NSLog(@"PBTUser:**Created at: %@", [tempTweet postDate]);
                    
                    if ( ![[tempTweet inReplyToScreenName] isEqualToString:@""] ) {
                        NSLog(@"PBTUser:**In reply to: %@", [tempTweet inReplyToScreenName]);
                    }
                    
                    if ( [[tempTweet mentionedScreenNames] count] != 0 ) {
                        NSLog(@"PBTUser:**Mentioned users: %@", [tempTweet mentionedScreenNames]);
                    }
                    
                    if ([[tempTweet mediaURLs] count] != 0) {
                        NSLog(@"PBTUser:**Media: %@", [tempTweet mediaURLs]);
                    }
                    #endif
                    
                    _lastTweetID=[tempTweet tweetID];
                    [_tweetsBuffer addObject:tempTweet];
                    [tempTweet release];
                }
                
                _numberOfTweets=_numberOfTweets-[stringNumberOfTweets intValue];
                
                #ifdef DEBUG
                NSLog(@"PBTUser:**Current size %d", [_tweetsBuffer count]);
                #endif
                
                //More tweets to retrieve
                if ( _numberOfTweets > 0 ) {
                    PBTRequestTweets(_client, _numberOfTweets, _lastTweetID, &_tweetsBuffer, _handler);
                }
                else {                    
                    #ifdef DEBUG
                    NSLog(@"PBTUser:**Last call, total number of tweets %d", [_tweetsBuffer count]);
                    #endif
                    
                    _handler();
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

@end