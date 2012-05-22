//
//  PBTUserView.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 14/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PBTDefines.h"
#import "PBTUser.h"

#define EXPANDED_LAYOUT
//#define COMPACTED_LAYOUT

extern CGSize const KPBTCGSize;

@interface PBTUserView : UIView{
    PBTUser *theUser;
    
    UIImageView *profilePicture;
    UILabel *realName;
    UILabel *screenName;
    UILabel *description;
    UILabel *location;
    UITextView *bioURL;
    UILabel *following;
    UILabel *followers;
    UILabel *tweetCount;
    UIImageView *verifiedImageView;
    
    @private UIScrollView *containerView;
    @private UIView *bufferView;
}

//Model of the view
@property (nonatomic, retain) PBTUser *theUser;

//Views of the Twitter user to analyze
@property (nonatomic, retain) UIImageView *profilePicture;
@property (nonatomic, retain) UILabel *realName;
@property (nonatomic, retain) UILabel *screenName;
@property (nonatomic, retain) UILabel *description;
@property (nonatomic, retain) UILabel *location;
@property (nonatomic, retain) UITextView *bioURL;
@property (nonatomic, retain) UILabel *following;
@property (nonatomic, retain) UILabel *followers;
@property (nonatomic, retain) UILabel *tweetCount;
@property (nonatomic, retain) UIImageView *verifiedImageView;

//The size of the view is fixed, and non-modifiable
-(id)initWithUser:(PBTUser *)someUser andPositon:(CGPoint)thePosition;
-(void)loadUser:(PBTUser *)someUser;

@end
