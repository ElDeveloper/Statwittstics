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
        float totalHeight=0.0;

        
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
        
        //Initialize the buffer view to fit everything in the container view
        bufferView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 1000)];
        [bufferView setBackgroundColor:[UIColor clearColor]];
        
        //Calculate the height of the bio of the current twitter user
        descriptionSize=[testDescription sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13] 
                                    constrainedToSize:CGSizeMake(400, 10000) 
                                        lineBreakMode:UILineBreakModeWordWrap];
        
        description=[[UILabel alloc] initWithFrame:CGRectMake(2, 5, descriptionSize.width, descriptionSize.height)];
        [description setText:testDescription];
        [description setNumberOfLines:0];
        [description setLineBreakMode:UILineBreakModeWordWrap];
        [description setTextColor:[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0]];
        [description setFont:[UIFont fontWithName:@"Helvetica" size:13]];
        [description setBackgroundColor:[UIColor clearColor]];
        [bufferView addSubview:description];
        
        //Update the total height
        totalHeight=descriptionSize.height+5;
        
        bioURL=[[UITextView alloc] initWithFrame:CGRectMake(-5, totalHeight-10, 400, 25)];
        [bioURL setText:@"http://www.johnappleseed.com"];
        [bioURL setContentMode:UIViewContentModeTop];
        [bioURL setEditable:NO];
        [bioURL setBounces:NO];
        [bioURL setBouncesZoom:NO];
        [bioURL setDataDetectorTypes:UIDataDetectorTypeAll];
        [bioURL setFont:[UIFont fontWithName:@"Helvetica" size:13]];
        [bioURL setBackgroundColor:[UIColor clearColor]];
        [bufferView addSubview:bioURL];
        
        //Update the total height
        totalHeight=totalHeight+25;
        
        location=[[UILabel alloc] initWithFrame:CGRectMake(0, totalHeight-10, 400, 14)];
        [location setText:@"El Dorado, California."];
        [location setTextColor:[UIColor grayColor]];
        [location setFont:[UIFont fontWithName:@"Helvetica" size:13]];
        [location setBackgroundColor:[UIColor clearColor]];
        [bufferView addSubview:location];
        
        //Update the total height
        totalHeight=totalHeight+14;
        [bufferView setFrame:CGRectMake(0, 0, 400, totalHeight-5)];
        
        containerView=[[UIScrollView alloc] initWithFrame:CGRectMake(110, 50, 390, 55)];
        [containerView setBackgroundColor:[UIColor clearColor]];
        [containerView setContentSize:[bufferView frame].size];
        [containerView addSubview:bufferView];
        [self addSubview:containerView];
        
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
