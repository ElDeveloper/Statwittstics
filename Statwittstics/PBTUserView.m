//
//  PBTUserView.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 14/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBTUserView.h"

CGSize const KPBTCGSize={.width=500.0f, .height=115.0f};

@implementation PBTUserView

@synthesize theUser;
@synthesize profilePicture, realName, screenName;
@synthesize description, location, bioURL; 
@synthesize following, followers, tweetCount;

- (id)initWithUser:(PBTUser *)userOrNil andPositon:(CGPoint)thePosition{
    self = [super initWithFrame:CGRectMake(thePosition.x, thePosition.y, KPBTCGSize.width, KPBTCGSize.height)];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor darkGrayColor]];
        
        NSString *testDescription=[NSString stringWithString:@"Random beta-tester for iOS apps. I also enjoy hiking and going out for a beer every now and then."];
        CGSize descriptionSize;
        //float totalHeight=0.0;
        
        //Will always first load the default picture
        profilePicture=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DefaultUser.png"]];
        [profilePicture setFrame:CGRectMake(5, 7.5, 95, 100)];
        [profilePicture setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:profilePicture];
        
        realName=[[UILabel alloc] initWithFrame:CGRectMake(110, 7.5, 400, 30)];
        [realName setText:@"John Appleseed"];
        [realName setTextColor:[UIColor whiteColor]];
        [realName setFont:[UIFont fontWithName:@"Helvetica-Bold" size:26]];
        [realName setBackgroundColor:[UIColor clearColor]];
        [self addSubview:realName];
        
        screenName=[[UILabel alloc] initWithFrame:CGRectMake(110, 37, 400, 19)];
        [screenName setText:@"@jappleseed"];
        [screenName setTextColor:[UIColor grayColor]];
        [screenName setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [screenName setBackgroundColor:[UIColor clearColor]];
        [self addSubview:screenName];
        
        //We have to calculate the height of the bio of the current twitter user
        descriptionSize=[testDescription sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13] 
                                    constrainedToSize:CGSizeMake(400, 10000) 
                                        lineBreakMode:UILineBreakModeWordWrap];
        
        description=[[UILabel alloc] initWithFrame:CGRectMake(110, 60, descriptionSize.width, descriptionSize.height)];
        [description setText:testDescription];
        [description setNumberOfLines:0];
        [description setLineBreakMode:UILineBreakModeWordWrap];
        [description setTextColor:[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0]];
        [description setFont:[UIFont fontWithName:@"Helvetica" size:13]];
        [description setBackgroundColor:[UIColor clearColor]];
        [self addSubview:description];
        
        bioURL=[[UITextView alloc] initWithFrame:CGRectMake(105, descriptionSize.height+50, 400, 25)];
        [bioURL setText:@"http://www.johnappleseed.com"];
        [bioURL setContentMode:UIViewContentModeTop];
        [bioURL setEditable:NO];
        [bioURL setDataDetectorTypes:UIDataDetectorTypeAll];
        [bioURL setFont:[UIFont fontWithName:@"Helvetica" size:13]];
        [bioURL setBackgroundColor:[UIColor clearColor]];
        [self addSubview:bioURL];
        
        location=[[UILabel alloc] initWithFrame:CGRectMake(110, descriptionSize.height+80, 400, 14)];
        [location setText:@"El Dorado, California."];
        [location setTextColor:[UIColor grayColor]];
        [location setFont:[UIFont fontWithName:@"Helvetica" size:13]];
        [location setBackgroundColor:[UIColor clearColor]];
        [self addSubview:location];
        
    }
    return self;
}

-(void)reloadWithUser:(PBTUser *)someUser{


}

-(void)dealloc{
    [profilePicture release];
    [realName release];
    [screenName release];
    [description release];
    [bioURL release];
    
    [super dealloc];
}

@end
