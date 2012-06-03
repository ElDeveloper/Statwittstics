//
//  PBTUtilities.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 22/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBTDefines.h"
#import "PBTUser.h"

@class PBTUser;

@interface PBTUtilities : NSObject

//General handler for the blocks, if an error occurs in the in the method where
//the caller is called, the handler won't be called , to avoid conflicts.
typedef void __block (^PBTSearchResult)(NSArray *arrayOfSubjects);

//These utilities requiere of a vailid PBTUser, otherwise you won't be able to
//make the request; this method returns an auto-released array via the handler
+(void)user:(PBTUser *)user requestUsersWithKeyword:(NSString *)keyword andResponseHandler:(PBTSearchResult)handler;

//Return the position for a point/tweet in a scatter plot where the hour and day
//position a point per tweet that happened at a specific moment.
void PBTScatterPointForDate(NSDate *date, NSInteger *hourRepresentation, NSInteger *dayOfWeek);

//Get a specifical formatted string with the standard known formatting characters
NSString* PBTStringFromTwitterDateWithFormat(NSDate *date, NSString *format);

//Get the full default date from a Twitter Date 
NSString* PBTStringFromTwitterDate(NSDate *date);

//Returns the number of days/weeks/months (currently only these are supported) between two NSDates
NSInteger PBTCalendarUnitsBetweenDates(NSDate *fromDate, NSDate *toDate, NSCalendarUnit calendarUnit);

//Returns an autoreleased date plus the specified days/weeks/months
NSDate* PBTAddCalendarUnitToDate(NSDate *date, NSInteger addition, NSCalendarUnit calendarUnit);

//MATLAB-ish like general use functions
NSMutableArray* PBTZeros(NSUInteger length);
NSMutableArray* PBTLinspace(float from, float to, NSUInteger elements);

@end
