//
//  PBTUtilities.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 22/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBTUtilities.h"

@implementation PBTUtilities

+(void)user:(PBTUser *)user requestUsersWithKeyword:(NSString *)keyword andResponseHandler:(PBTSearchResult)handler{
    //URL, parameters and request object initialized to retrieve the data, see PBTConstants for the definitions
    NSURL *userSearchURL=[NSURL URLWithString:TAUUsersSearch];
    NSDictionary *parameters=[NSDictionary dictionaryWithObjectsAndKeys:keyword, TAKeyQuery, nil];
    TWRequest *userSearchRequest=[[TWRequest alloc] initWithURL:userSearchURL parameters:parameters requestMethod:TWRequestMethodGET];
    
    //Authorize if a user has been provided
    if (user != nil) {
        if ( [user account] != nil ) {
            [userSearchRequest setAccount:[user account]];
        }
    }
    
    //Request the data
    [userSearchRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError *jsonError=nil;
        id jsonString=nil;
        NSMutableArray *bufferArray=[NSMutableArray array];
        PBTUser *temp=nil;
        
        #ifdef DEBUG
        NSLog(@"%@", [urlResponse URL]);
        #endif
        
        //Check for errors in the request
        if (!error) {
            
            //The JSON object is a Dictionary
            jsonString=[NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            
            //Twitter wouldn't return badly serilized JSON objects but if anything
            if (!jsonError) {
                #ifdef JSON_DEBUG
                NSLog(@"USER_SEARCH: %@", jsonString);
                #endif
                
                //Iterate over each of the objects in the JSON string
                for ( NSDictionary *someDictionary in (NSArray *)jsonString ) {
                    //Add each object to the array, the array becomes the retainer of the object
                    temp=[[PBTUser alloc] initWithJSONString:someDictionary];
                    [bufferArray addObject:temp];
                    [temp release];
                    temp=nil;
                }
                
                //Return the contents of the data in a non-mutable autoreleased array
                handler([NSArray arrayWithArray:bufferArray]);
            }
            else {
                //JSON serialization error management
                NSLog(@"PBTUtilities(J)**:%@",[jsonError localizedDescription]);
            }
        }
        else {
            //Request connection error
            NSLog(@"PBTUtilities(R)**:%@",[error localizedDescription]);
        }
    }];
}

#pragma mark - PBTweets General Use Function
void PBTScatterPointForDate(NSDate *date, NSInteger *hourRepresentation, NSInteger *dayOfWeek){
    NSInteger outBuffer=0;
    NSString *bufferString=nil;
    NSArray *bufferArray=nil;
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat: @"HH:mm:ss"];
    
    bufferString=[dateFormatter stringFromDate:date];
    bufferArray=[NSArray arrayWithArray:[bufferString componentsSeparatedByString:@":"]];
    
    //First hours
    outBuffer=outBuffer + ( 3600 * [[bufferArray objectAtIndex:0] intValue] );
    
    //Then minutes
    outBuffer=outBuffer + ( 60 * [[bufferArray objectAtIndex:1] intValue] );
    
    //Now seconds
    outBuffer=outBuffer + [[bufferArray objectAtIndex:2] intValue];
    
    *hourRepresentation=outBuffer;
    
    //Format the number of the day of the week
    [dateFormatter setDateFormat:@"e"];
    
    //Cast it and send it back
    *dayOfWeek=(NSInteger)[[dateFormatter stringFromDate:date] intValue];
}

#pragma mark - NSDate General Use Functions
NSString* PBTStringFromTwitterDate(NSDate *date){
    return PBTStringFromTwitterDateWithFormat(date, @"EEE MMM dd HH:mm:ss Z yyyy");
}

NSString* PBTStringFromTwitterDateWithFormat(NSDate *date, NSString *format){
    NSDateFormatter *dateFormatter=nil;
    NSLocale *usLocale=nil;
    
    //The date come from twitter in the following format Mon Apr 16 00:57:16 +0000 2012
    //therefore, our formatter has to know it is a US formatted date
    dateFormatter=[[NSDateFormatter alloc] init];
    usLocale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale]; 
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    
    //For further information look here: http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns
    [dateFormatter setDateFormat:format];
    [usLocale release];
    
    return [NSString stringWithString:[dateFormatter stringFromDate:date]];
}

NSInteger PBTCalendarUnitsBetweenDates(NSDate *fromDate, NSDate *toDate, NSCalendarUnit calendarUnit){
    NSCalendar *calendar=[NSCalendar autoupdatingCurrentCalendar];
    NSInteger outBuffer=0;
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate interval:NULL forDate:fromDate];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate interval:NULL forDate:toDate];
    
    NSDateComponents *difference = [calendar components:calendarUnit fromDate:fromDate toDate:toDate options:0];
    
    switch (calendarUnit) {
        case NSDayCalendarUnit:
            outBuffer=[difference day];
            break;
        case NSWeekCalendarUnit:
            outBuffer=[difference week];
            break;
        case NSMonthCalendarUnit:
            outBuffer=[difference month];
            break;
        default:
            outBuffer=0;
            break;
    }
    
    return outBuffer;    
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

@end
