//
//  PBTKit.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 14/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#ifndef Statwittstics_PBTKit_h
#define Statwittstics_PBTKit_h

//Pre-processor flags, etc ...
#include "PBTDefines.h"

//Abstract representation of a Twitter user (Model)
#import "PBTUser.h"

//Abstract representation of a tweet (Model)
#import "PBTweet.h"

//Abstract representation of a Twitter user (View), depends on the
//PBTUser and the PBTweet class to work properly
#import "PBTUserView.h"

//Wrapper class for some of the requests that currently don't fit a classification
#import "PBTUtilities.h"

#endif