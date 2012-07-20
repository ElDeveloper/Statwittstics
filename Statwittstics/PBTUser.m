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
@synthesize requiresAuthentication, isVerified;
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
        tweets=[[NSMutableArray alloc] init];
        following=0;
        followers=0;
        tweetCount=0;
        requiresAuthentication=NO;
        isVerified=NO;
        
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
    
    
    //If the user is verified, choose from the value 
    isVerified=[[jsonString objectForKey:TAKeyVerified] boolValue];
}

-(void)dealloc{
    [username release];
    [account release];
    [realName release];
    [description release];
    [location release];
    [bioURL release];
    [imageData release];
    [tweets release];
    
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
                
                //Now request the image
                [self requestProfilePictureWithSize:TAImageSizeBigger andHandler:^(NSError *error){
                    
                    //Errors can also happen in this request, just notify them if so
                    if (!error) {
                        //Finally when everything is done, perform the handler
                        handler(nil);
                    }
                    else {
                        NSLog(@"PBTUser(REQUEST:IMAGE)**:%@", [error localizedDescription]);
                        handler([[error copy] autorelease]);
                    }
                }];

            }//JSON error
            else {
                //JSON serialization error management
                NSLog(@"PBTUser(JSON)**:%@",[jsonError localizedDescription]);
                handler([[jsonError copy] autorelease]);
            }
        }
        else {
            //Data request error
            NSLog(@"PBTUser(REQUEST)**:%@", [error localizedDescription]);
            handler([[error copy] autorelease]);
        }//data request error
    }];//Twitter API request block

    [userData release];
}

-(void)requestProfilePictureWithSize:(TAImageSize)size andHandler:(PBTRequestHandler)handler{
    NSURL *userDataRequest=[NSURL URLWithString:TAUImageData];
    NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:[self username], TAKeyUsername, size, @"size", nil];
    TWRequest *userData=[[TWRequest alloc] initWithURL:userDataRequest parameters:parameters requestMethod:TWRequestMethodGET];
    
    [userData performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        #ifdef DEBUG
        NSLog(@"PBTUser(REQUEST):%s**:%@", __PRETTY_FUNCTION__,[urlResponse URL]);
        #endif
        
        if (!error) {
            imageData=[[NSData alloc] initWithData:responseData];
            handler(nil);
        }
        else {
            NSLog(@"PBTUser(REQUEST):%s**:%@", __PRETTY_FUNCTION__,[error localizedDescription]);
            
            //Make a copy and autorelease the error object
            handler([[error copy] autorelease]);
        }
    }];
    
    [userData release];
}

-(void)requestMostRecentTweets:(NSInteger)numberOfTweets withHandler:(PBTRequestHandler)handler{
    NSString *stringNumberOfTweets=nil;
    
    //URL, parameters and request object initialized to retrieve the data
    NSURL *userDataRequest=[NSURL URLWithString:TAUUserTimeline];
    NSDictionary *parameters=nil;
    
    #ifdef DEBUG
    NSLog(@"PBTUSER:**Requested %d tweets", numberOfTweets);
    #endif
    
    //Regardless the number of tweets requested on this call you must always
    //truncate to the kPBTRequestMaximum, then worry about other constraints
    if (numberOfTweets > kPBTRequestMaximum) {
        numberOfTweets=kPBTRequestMaximum;
    }
    
    //These variables get re-usede in recursive calls, so they shall be init-
    //ialized every first time this is called, 
    if (_tempArray == nil) {
        //In case the user requests more than what you can actually get
        if ([[self tweets] count] < numberOfTweets) {
            numberOfTweets=numberOfTweets-[[self tweets] count];
        }
        else{ 
            #ifdef DEBUG
            NSLog(@"No need to make a request, already have the required tweets");
            #endif
            
            handler(nil);
            return;
        }
        
        if (numberOfTweets <= 0) {
            return;
        }
        
        #ifdef DEBUG
        NSLog(@"PBTUSER:**Requesting %d tweets", numberOfTweets);
        #endif
        
        _tempArray=[[NSMutableArray alloc] init];
        _remainingTweets=numberOfTweets;
        _vamooseHandler=[handler copy];
    }    
    
    //If the total request needs you to ask for more than 200 tweets, truncate the number, using the ternary operator
    stringNumberOfTweets=[NSString stringWithFormat:@"%d",(numberOfTweets > 200 ? 200 : numberOfTweets)];

    //For the first call you don't have a max_id property so, the dict goes as follows ...
    if (_lastTweetID == nil) {
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
            jsonString=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
            
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
                    //Don't know if we should behave somehow
                    [self requestMostRecentTweets:_remainingTweets withHandler:^(NSError *error) {}];
                }
                else {
                    #ifdef DEBUG
                    NSLog(@"PBTUser:**Last call, total number of tweets %d", [_tempArray count]);
                    #endif
                    
                    //Assign the tweets to the user
                    //tweets=[[NSMutableArray alloc] initWithArray:_tempArray];
                    [tweets addObjectsFromArray:_tempArray];
                    tweetCount=[tweets count];
                    
                    [_tempArray release];
                    _tempArray=nil;
                    
                    //Re-initialize the properties
                    //_lastTweetID=nil;
                    _remainingTweets=0;

                    //Finally call the handler, release and re-start the variable
                    _vamooseHandler(nil);
                    [_vamooseHandler release];
                    _vamooseHandler=nil;
                }
            }
            else {
                //JSON serialization error management
                NSLog(@"PBTUser(JSON)%s**:%@",__PRETTY_FUNCTION__, [jsonError localizedDescription]);
                
                //Manage the memory you know you won't be using
                [_tempArray release];
                _vamooseHandler([[jsonError copy] autorelease]);
                [_vamooseHandler release];
                _vamooseHandler=nil;
            }
            
        }
        else {
            //Connection error managment 
            NSLog(@"PBTUser(REQUEST)%s**::%@",__PRETTY_FUNCTION__, [error localizedDescription]);
            
            //Manage the memory you know you won't be using
            [_tempArray release];
            _vamooseHandler([[error copy] autorelease]);
            [_vamooseHandler release];
            _vamooseHandler=nil;
        }
    }];
    
    [userData release];
}

-(void)requestAllTweetsWithHandler:(PBTRequestHandler)handler{
    NSUInteger requestedTwitts=tweetCount;
    
    //The API is limitted to 3,200 twitts, so clamp that
    if (tweetCount > kPBTRequestMaximum) {
        requestedTwitts=kPBTRequestMaximum;
        NSLog(@"PBTUser**:Warning: Clamping the requested number of tweets to %d.", tweetCount);
    }
    
    //Have to do this in chunks of 200
    [self requestMostRecentTweets:requestedTwitts withHandler:^(NSError *error){
        handler([[error copy] autorelease]);
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

-(PBDataSet *)dataSetOfTweets:(NSUInteger)numberOfTweets byCalendarUnit:(NSCalendarUnit)calendarUnit{
    PBDataSet *outDataSet=nil;    
    NSUInteger calendarPoints=0, i=0, totalTweets=0, newIndex=0, *bufferArray=NULL;
    NSDate *startDate=nil, *endDate=nil;
    NSMutableArray *xData=nil, *yData=nil;
    NSMutableString *dataSetTitleHolder=nil;
    NSArray *tempArray=nil, *truncatedArray=nil;
    NSRange truncatedRange;
    
    //Truncate to the available tweets, this is mainly to patch an inconsistency
    //encountered with the Twitter API when requesting twitts
    if ( numberOfTweets > [[self tweets] count]) {
        numberOfTweets=[[self tweets] count];
    }
    numberOfTweets=numberOfTweets-1;
    
    #ifdef DEBUG
    NSLog(@"Trimming to a size of %d", numberOfTweets+1);
    #endif
    
    //Chop down the array to what is required
    truncatedRange.location=0;
    truncatedRange.length=numberOfTweets;
    truncatedArray=[[NSArray alloc] initWithArray:[tweets subarrayWithRange:truncatedRange]];
    
    //General usage constants, helps you build the linear space and plot
    startDate=[[truncatedArray objectAtIndex:0] postDate];
    endDate=[[truncatedArray objectAtIndex:[truncatedArray count]-1] postDate];
    
    dataSetTitleHolder=[NSString stringWithFormat:@"Tweets From %@ To %@", 
                        PBTStringFromTwitterDateWithFormat(endDate, @"MMM/dd/yyyy"),  
                        PBTStringFromTwitterDateWithFormat(startDate, @"MMM/dd/yyyy")];
    
    //Cast to a unsigned integer
    calendarPoints=(NSUInteger)PBTCalendarUnitsBetweenDates(endDate, startDate, calendarUnit);
    
    //Actual data holders
    totalTweets=[truncatedArray count];
    xData=[PBTLinspace(0, calendarPoints, calendarPoints) retain]; 
    yData=[[NSMutableArray alloc] initWithCapacity:calendarPoints];
    
    //Get rid of some of the overhead of using a NSArray object and just use a C array
    bufferArray=malloc(sizeof(NSUInteger)*calendarPoints);
    
    //Just plain and old array cleaning
    for (i=0; i<calendarPoints; i++) {
        bufferArray[i]=0;
    }
    
    #ifdef DEBUG
    NSLog(@"Value of TotalPoints %d", calendarPoints);
    #endif
    
    //Got through each tweet and count the number of tweets that are in a same week
    for (i=0; i<totalTweets; i++) {
        //Get the current difference
        newIndex=PBTCalendarUnitsBetweenDates([[truncatedArray objectAtIndex:i] postDate], startDate, calendarUnit);
        bufferArray[newIndex]=bufferArray[newIndex]+1;
    }
    
    //Now add these values to the array of the y data
    for (i=0; i<calendarPoints; i++) { //EXC_BAD_ACCESS code=1
        [yData addObject:[NSNumber numberWithUnsignedInteger:*(bufferArray+i)]];
    }
    
    //Set the order of the results being from newest to oldest
    tempArray=[[[yData reverseObjectEnumerator] allObjects] copy];
    [yData removeAllObjects];
    [yData addObjectsFromArray:tempArray];
    
    //Create the return value
    outDataSet=[[PBDataSet alloc] initWithXData:xData yData:yData andTitle:[NSString stringWithFormat:@"%@ For %@",dataSetTitleHolder, [self realName]]];
    [outDataSet setLineColor:[CPTColor whiteColor]];
    
    //Free your mallocs
    free(bufferArray);
    
    [xData release];
    [yData release];
    [truncatedArray release]; //truncatedArray is causing problems
    [tempArray release];
    
    return [outDataSet autorelease];
}

-(PBDataSet *)dataSetOfTweetsAtHourAtDay:(NSUInteger)numberOfTweets{
    PBDataSet *outDataset=nil;

    NSString *endDate=nil;
    NSString *beginDate=nil;
    
    NSMutableArray *xDataArray=[[NSMutableArray alloc] init];
    NSMutableArray *yDataArray=[[NSMutableArray alloc] init];
    
    NSInteger hourRepresentation=0;
    NSInteger dayOfWeek=0;
    
    NSArray *truncatedArray=nil;
    NSRange truncatedRange;
    
    //Truncate to the available tweets, this is mainly to patch an inconsistency
    //encountered with the Twitter API when requesting twitts
    if (numberOfTweets > [[self tweets] count]) {
        numberOfTweets=[[self tweets] count];
    }
    numberOfTweets=numberOfTweets-1;
    
    #ifdef DEBUG
    NSLog(@"Trimming to a size of %d", numberOfTweets+1);
    #endif
    
    //Chop down the array to what is required
    truncatedRange.location=0;
    truncatedRange.length=numberOfTweets;
    truncatedArray=[[NSArray alloc] initWithArray:[tweets subarrayWithRange:truncatedRange]];
    
    
    endDate=[NSString stringWithString:PBTStringFromTwitterDateWithFormat([[truncatedArray objectAtIndex:0] postDate], @"MMM/dd/yyyy")];
    beginDate=[NSString stringWithString:PBTStringFromTwitterDateWithFormat([[truncatedArray objectAtIndex:[truncatedArray count]-1] postDate],  @"MMM/dd/yyyy")];
    
    for (PBTweet *currentTweet in truncatedArray) {
        PBTScatterPointForDate([currentTweet postDate], &hourRepresentation, &dayOfWeek);
        [xDataArray addObject:[NSNumber numberWithInteger:hourRepresentation]];
        [yDataArray addObject:[NSNumber numberWithInteger:dayOfWeek]];
        
        #ifdef VERBOSE_DEBUG
        NSLog(@"Tweet at day: %d and hour representation %d for day %@", dayOfWeek, hourRepresentation, PBTStringFromTwitterDate([currentTweet postDate]));
        #endif
    }
    
    outDataset=[[PBDataSet alloc] initWithXData:xDataArray 
                                          yData:yDataArray 
                                       andTitle:[NSString stringWithFormat:@"Tweets From %@ To %@ For %@",beginDate, endDate, [self realName]]];
    
    [outDataset setLineColor:[CPTColor clearColor]];
    [outDataset setSymbol:[PBUtilities symbolWithType:CPTPlotSymbolTypePentagon size:8 andColor:[CPTColor whiteColor]]];
    
    [xDataArray release];
    [yDataArray release];
    
    [truncatedArray release];
    
    return [outDataset autorelease];
}

-(PBDataSet *)dataSetOfFrequencyOfTweetsPerHour:(NSUInteger)numberOfTweets{
    PBDataSet *outDataset=nil;
    
    NSUInteger hourOfTweet=0, *bufferArray=NULL, i=0;
    
    NSMutableArray *yData=[[NSMutableArray alloc] initWithCapacity:24];
    
    NSString *endDate=nil;
    NSString *beginDate=nil;
    
    NSArray *truncatedArray=nil;
    NSRange truncatedRange;
    
    //Truncate to the available tweets, this is mainly to patch an inconsistency
    //encountered with the Twitter API when requesting twitts
    if (numberOfTweets > [[self tweets] count]) {
        numberOfTweets=[[self tweets] count];
    }
    numberOfTweets=numberOfTweets-1;
    
    #ifdef DEBUG
    NSLog(@"Trimming to a size of %d", numberOfTweets+1);
    #endif
    
    //Chop down the array to what is required
    truncatedRange.location=0;
    truncatedRange.length=numberOfTweets;
    truncatedArray=[[NSArray alloc] initWithArray:[[tweets copy] subarrayWithRange:truncatedRange]];
    
    endDate=[NSString stringWithString:PBTStringFromTwitterDateWithFormat([[truncatedArray objectAtIndex:0] postDate], @"MMM/dd/yyyy")];
    beginDate=[NSString stringWithString:PBTStringFromTwitterDateWithFormat([[truncatedArray objectAtIndex:[truncatedArray count]-1] postDate],  @"MMM/dd/yyyy")];
    
    //The number of hours in one day, duh
    bufferArray=malloc(sizeof(NSUInteger)*24);
    
    //Initialize the counts at zero
    for (i=0; i<24; i++) {
        bufferArray[i]=0;
    }
    
    for (PBTweet *currentTweet in truncatedArray) {
        //Get the int representation from the 24 hour day 
        hourOfTweet=[PBTStringFromTwitterDateWithFormat([currentTweet postDate], @"HH") intValue];
        
        //Increment one for the current hour
        bufferArray[hourOfTweet]=bufferArray[hourOfTweet]+1;
    }
    
    //Add an NSNumber to the yData array, each element is the count of tweets at that hour
    for (i=0; i<24; i++) {
        [yData addObject:[NSNumber numberWithUnsignedInt:bufferArray[i]]];
    }
    
    outDataset=[[PBDataSet alloc] initWithXData:PBTLinspace(0, 24, 24) 
                                          yData:yData 
                                       andTitle:[NSString stringWithFormat:@"%@ From %@ To %@ For %@", 
                                                 NSLocalizedString(@"Distribution Of Tweets Per Hour", @"Distribution Of Tweets Per Hour String"), 
                                                 beginDate,
                                                 endDate,
                                                 [self realName]]];
    
    [outDataset setLineColor:[CPTColor whiteColor]];
    
    //Free the mallocs
    free(bufferArray);
    
    [yData release];
    [truncatedArray release];
    
    return [outDataset autorelease];
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
    PBTRequestHandler _handler=nil;
    
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
                    
                    _handler(nil);
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
    
    [userData release];
}

@end