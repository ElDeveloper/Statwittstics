//
//  HomeViewController.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 05/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatwittsticsDefines.h"

#import "AboutViewController.h"
#import "FindUserViewController.h"

#import "PBTKit.h"
#import "PBKit.h"

typedef enum {
    HVCActionSheetButtonNew=1,
    HVCActionSheetButtonShare=2
}HVCActionSheetButton;

@interface HomeViewController : UIViewController <UIActionSheetDelegate>{
    PBPlot *mainPlot;
    PBTUser *mainUser;
    PBTUserView *mainUserView;
    
    @private UIActionSheet *optionsActionSheet;
}

//Main plot of the user to analyze
@property (nonatomic, retain) PBPlot *mainPlot;

//The user to analyze (model and view)
@property (nonatomic, retain) PBTUser *mainUser;
@property (nonatomic, retain) PBTUserView *mainUserView;

//General private attributes of the ViewController
@property (nonatomic, weak) UIActionSheet *optionsActionSheet;

-(void)optionsButtonPressed:(id)sender;
-(void)aboutButtonPressed:(id)sender;
-(void)drawTweetsPerDayPlot;

@end
