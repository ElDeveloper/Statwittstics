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

void PBTScatterPointForDate(NSDate *date, NSInteger *hourRepresentation, NSInteger *dayOfWeek);

NSString* PBTStringFromTwitterDate(NSDate *date);

//Helper function, returns the number of days/weeks/months (currently only these are supported) between two NSDates
NSInteger PBTCalendarUnitsBetweenDates(NSDate *fromDate, NSDate *toDate, NSCalendarUnit calendarUnit);

//MATLAB-ish like general use functions
NSMutableArray* PBTZeros(NSUInteger length);
NSMutableArray* PBTLinspace(float from, float to, NSUInteger elements);

@end
