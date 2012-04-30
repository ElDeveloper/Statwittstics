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
    PBTUser *subjectOfAnalysis;
    PBTUserView *subjectOfAnalysisView;
    
    @private PBTUser *researchFellow;
    @private UIActionSheet *optionsActionSheet;
}

//Main plot of the user to analyze
@property (nonatomic, retain) PBPlot *mainPlot;

//The user to analyze (model and view)
@property (nonatomic, retain) PBTUser *subjectOfAnalysis;
@property (nonatomic, retain) PBTUserView *subjectOfAnalysisView;

//This user is required and will be the default for application launch
@property (nonatomic, retain) PBTUser *researchFellow;

//General private attributes of the ViewController
@property (nonatomic, weak) UIActionSheet *optionsActionSheet;

//Buttons that provide the actions for the whole application
-(void)optionsButtonPressed:(id)sender;
-(void)aboutButtonPressed:(id)sender;

-(void)loadUser:(PBTUser *)someUser;
-(void)drawPlotOfTweetsPerDay;
-(void)drawPlotOfTweetsPerWeek;
-(void)drawPlotOfTweetsPerMonth;

@end
