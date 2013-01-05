//
//  AboutViewController.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 17/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatwittsticsDefines.h"

@interface AboutViewController : UIViewController <UIWebViewDelegate>{
    IBOutlet UIWebView *twitterUsernamesView;
	IBOutlet UILabel *repositoryInformation;
}

@property (nonatomic, retain) IBOutlet UIWebView *twitterUsernamesView;
@property (nonatomic, retain) IBOutlet UILabel *repositoryInformation;

-(IBAction)dismissCredits:(id)sender;

@end
