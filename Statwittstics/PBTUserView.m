//
//  PBTUserView.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 14/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBTUserView.h"
#import "UIImage+PBUtilities.h"

#ifdef EXPANDED_LAYOUT
CGSize const KPBTCGSize={.width=510.0f, .height=125.0f};
#endif
#ifdef COMPACTED_LAYOUT
CGSize const KPBTCGSize={.width=510.0f, .height=125.0f};
#endif

CGSize const kPBTProfilePictureSize={.width=95.0f, .height=100.0f};

@implementation PBTUserView

@synthesize theUser;
@synthesize profilePicture, realName, screenName;
@synthesize description, location, bioURL; 
@synthesize following, followers, tweetCount, verifiedImageView;

-(id)initWithUser:(PBTUser *)userOrNil andPositon:(CGPoint)thePosition{
    self = [super initWithFrame:CGRectMake(thePosition.x, thePosition.y, KPBTCGSize.width, KPBTCGSize.height)];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor darkGrayColor]];
        [[self layer] setCornerRadius:6.0f];
        [[self layer] setMasksToBounds:YES];
        
        UILabel *temp1=nil;
        theUser=nil;
        
        //Will always first load the default picture
        profilePicture=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DefaultUser.png"]];
        [[profilePicture layer] setCornerRadius:12.0f];
        [[profilePicture layer] setMasksToBounds:YES];
        
        #ifdef EXPANDED_LAYOUT
        [profilePicture setFrame:CGRectMake(5, 7.5, 95, 100)];
        #endif
        #ifdef COMPACTED_LAYOUT
        [profilePicture setFrame:CGRectMake(110, 2, 44, 44)];
        #endif
        
        [profilePicture setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:profilePicture];
        
        #ifdef EXPANDED_LAYOUT
        realName=[[UILabel alloc] initWithFrame:CGRectMake(110, 5, 390, 24)];
        #endif
        #ifdef COMPACTED_LAYOUT
        realName=[[UILabel alloc] initWithFrame:CGRectMake(160, 5, 342, 24)];
        #endif
        
        [realName setTextColor:[UIColor whiteColor]];
        [realName setFont:[UIFont fontWithName:@"Helvetica-Bold" size:23]];
        [realName setBackgroundColor:[UIColor clearColor]];
        [self addSubview:realName];
        
        #ifdef EXPANDED_LAYOUT
        screenName=[[UILabel alloc] initWithFrame:CGRectMake(110, 30, 390, 17)];
        #endif
        #ifdef COMPACTED_LAYOUT
        screenName=[[UILabel alloc] initWithFrame:CGRectMake(160, 30, 342, 17)];
        #endif
        
        [screenName setTextColor:[UIColor grayColor]];
        [screenName setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [screenName setBackgroundColor:[UIColor clearColor]];
        [self addSubview:screenName];
        
        //Tweets, Following & Followers labels
        temp1=[[UILabel alloc] initWithFrame:CGRectMake(110, 48, 50, 16)];
        [temp1 setText:@"Tweets"];
        [temp1 setTextColor:[UIColor whiteColor]];
        [temp1 setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
        [temp1 setBackgroundColor:[UIColor clearColor]];
        [self addSubview:temp1];
        [temp1 release];
        
        tweetCount=[[UILabel alloc] initWithFrame:CGRectMake(160, 44, 75, 25)];
        [tweetCount setAdjustsFontSizeToFitWidth:YES];
        [tweetCount setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        [tweetCount setBackgroundColor:[UIColor clearColor]];
        [self addSubview:tweetCount];
        
        temp1=[[UILabel alloc] initWithFrame:CGRectMake(243, 48, 70, 16)];
        [temp1 setText:NSLocalizedString(@"Following", @"Following String")];
        [temp1 setTextColor:[UIColor whiteColor]];
        [temp1 setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
        [temp1 setBackgroundColor:[UIColor clearColor]];
        [self addSubview:temp1];
        [temp1 release];
        
        following=[[UILabel alloc] initWithFrame:CGRectMake(313, 44, 55, 25)];
        [following setAdjustsFontSizeToFitWidth:YES];
        [following setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        [following setBackgroundColor:[UIColor clearColor]];
        [self addSubview:following];
        
        temp1=[[UILabel alloc] initWithFrame:CGRectMake(373, 48, 70, 16)];
        [temp1 setText:NSLocalizedString(@"Followers", @"Followers String")];
        [temp1 setTextColor:[UIColor whiteColor]];
        [temp1 setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
        [temp1 setBackgroundColor:[UIColor clearColor]];
        [self addSubview:temp1];
        [temp1 release];
        
        followers=[[UILabel alloc] initWithFrame:CGRectMake(443, 44, 55, 25)];
        [followers setAdjustsFontSizeToFitWidth:YES];
        [followers setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        [followers setBackgroundColor:[UIColor clearColor]];
        [self addSubview:followers];
        
        //Initialize the buffer view to fit everything in the container view
        bufferView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 390, 1000)];
        [bufferView setBackgroundColor:[UIColor clearColor]];

        description=[[UILabel alloc] initWithFrame:CGRectMake(2, 5, 390, 15)];
        [description setNumberOfLines:0];
        [description setLineBreakMode:UILineBreakModeWordWrap];
        [description setTextColor:[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0]];
        [description setFont:[UIFont fontWithName:@"Helvetica" size:13]];
        [description setBackgroundColor:[UIColor clearColor]];
        [bufferView addSubview:description];
        
        bioURL=[[UITextView alloc] initWithFrame:CGRectMake(0, 0, 390, 25)];
        [bioURL setScrollEnabled:NO];
        [bioURL setContentMode:UIViewContentModeTop];
        [bioURL setEditable:NO];
        [bioURL setBounces:NO];
        [bioURL setBouncesZoom:NO];
        [bioURL setDataDetectorTypes:UIDataDetectorTypeAll];
        [bioURL setFont:[UIFont fontWithName:@"Helvetica" size:13]];
        [bioURL setBackgroundColor:[UIColor clearColor]];
        [bufferView addSubview:bioURL];
        
        location=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 390, 14)];
        [location setTextColor:[UIColor grayColor]];
        [location setFont:[UIFont fontWithName:@"Helvetica" size:13]];
        [location setBackgroundColor:[UIColor clearColor]];
        [bufferView addSubview:location];
        
        containerView=[[UIScrollView alloc] initWithFrame:CGRectMake(110, 70, 390, 44)];
        [containerView setBackgroundColor:[UIColor clearColor]];
        [containerView setContentSize:[bufferView frame].size];
        [containerView setAlwaysBounceHorizontal:NO];
        [containerView addSubview:bufferView];
        [self addSubview:containerView];
        
        verifiedImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        [verifiedImageView setFrame:CGRectMake(468, 2, 40, 40)];
        [verifiedImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:verifiedImageView];
        
        [self loadUser:userOrNil];
    }
    return self;
}

-(void)loadUser:(PBTUser *)someUser{
    //All these are place-holders to choose wheter you will need to load dummmy data or real data
    NSString *realNameString=nil, *screenNameString=nil; 
    NSString *followingString=nil, *followersString=nil, *tweetCountString=nil;
    NSString *descriptionString=nil, *bioURLString=nil, *locationString=nil;
    NSNumberFormatter *regularFormatter=nil;
    BOOL isVerified=NO;
    
    CGSize descriptionSize;
    float totalHeight=0.0;
    
    //Default behavior for the formatter used in all the numbers
    regularFormatter=[[NSNumberFormatter alloc] init];
    [regularFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    //See whether or not you should retain the user
    if (theUser == nil && someUser != nil) {
        theUser=[someUser retain];
    }
    if (theUser != nil && someUser != nil) {
        [theUser release];
        theUser=[someUser retain];
    }
    
    //Check if there is a user, if there is not one, just add default holders
    if (someUser == nil) {
        realNameString=@"John Appleseed";
        screenNameString=@"@japleseed";
        followingString=@"200";
        followersString=@"180";
        tweetCountString=@"10,200";
        descriptionString=@"Location ...";
        bioURLString=@"http://www.twitter.com";
        locationString=@"Palo Alto, Ca.";
        isVerified=YES;
    }
    //We have a user, fill properly
    else {
        realNameString=[theUser realName];
        screenNameString=[NSString stringWithFormat:@"@%@", [theUser username]];
        followingString=[regularFormatter stringForObjectValue:[NSNumber numberWithInteger:[theUser following]]];
        followersString=[regularFormatter stringForObjectValue:[NSNumber numberWithInteger:[theUser followers]]];
        tweetCountString=[regularFormatter stringForObjectValue:[NSNumber numberWithInteger:[theUser tweetCount]]];
        descriptionString=[theUser description];
        bioURLString=[NSString stringWithFormat:@"%@", [theUser bioURL]];
        locationString=[theUser location];
        isVerified=[theUser isVerified];
        
        //Only change the image if the new image has already been 
        //retrieved, else leave the placeholder in the view 
        if ([theUser imageData] != nil) {
            [profilePicture setImage:[UIImage resizeImage:[UIImage imageWithData:[theUser imageData]] newSize:kPBTProfilePictureSize]];
        }
    }
    
    //Set the data of the model, these attributes are always present
    [realName setText:realNameString];
    [screenName setText:screenNameString];
    [following setText:followingString];
    [followers setText:followersString];
    [tweetCount setText:tweetCountString];
    
    //Only sum the heights for the strings that are not empty (location, bio and URL)
    [description setText:descriptionString];
    if ( ![descriptionString isEqualToString:@""] ) {
        //Calculate the height of the bio of the current twitter user
        descriptionSize=[descriptionString sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13] 
                                      constrainedToSize:CGSizeMake(390, 10000) 
                                          lineBreakMode:UILineBreakModeWordWrap];
        
        [description setFrame:CGRectMake(2, 5, descriptionSize.width, descriptionSize.height)];
        
        //Update the total height
        totalHeight=descriptionSize.height+5;
    }
    else {
        totalHeight=totalHeight+5;
    }
    
    [bioURL setText:bioURLString];
    if ( ![bioURLString isEqualToString:@""] ) {
        [bioURL setFrame:CGRectMake(-5, totalHeight-10, 390, 25)];
        
        //Update the total height
        totalHeight=totalHeight+25;
    }
    else {
        totalHeight=totalHeight+10;
    }
    
    [location setText:locationString];
    if  ( ![locationString isEqualToString:@""] ){
        [location setFrame:CGRectMake(0, totalHeight-10, 390, 14)];
        
        //Update the total height
        totalHeight=totalHeight+14;
    }
    else {
        totalHeight=totalHeight+10;
    }
    
    [bufferView setFrame:CGRectMake(0, 0, 390, totalHeight-5)];
    [containerView setContentSize:[bufferView frame].size];
    
    //If the account is verified add a check-mark else, just add a non-existent image
    if (isVerified) {
        [verifiedImageView setImage:[UIImage imageNamed:@"VerifiedTwitter.png"]];
    }
    else {
        [verifiedImageView setImage:[UIImage imageNamed:@""]];
    }
    
    //Release the allocated formatter
    [regularFormatter release];
}

-(void)dealloc{
    
    if (theUser != nil) {
        [theUser release];   
    }
    
    [profilePicture release];
    [realName release];
    [screenName release];
    [description release];
    [bioURL release];
    
    [tweetCount release];
    [followers release];
    [following release];
    
    [containerView release];
    [bufferView release];
    
    [super dealloc];
}
@end