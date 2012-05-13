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

#define HOURS_ARRAY @"00:00", @"01:00", @"02:00", @"03:00", @"04:00", @"05:00", @"06:00", @"07:00", @"08:00", @"09:00", @"10:00", @"11:00", @"12:00", @"13:00", @"14:00", @"15:00", @"16:00", @"17:00", @"18:00", @"19:00", @"20:00", @"21:00", @"22:00", @"23:00", @""
#define DAYS @"", @"Domingo", @"Lunes", @"Martes", @"Miércoles", @"Jueves", @"Viernes", @"Sábado", @""

typedef enum {
    HVCActionSheetButtonNew=1,
    HVCActionSheetButtonShare=2
}HVCActionSheetButton;

@interface HomeViewController : UIViewController <UIActionSheetDelegate>{
    
    PBVisualization *visualizationSpace;
    PBTUser *subjectOfAnalysis;
    PBTUserView *subjectOfAnalysisView;
    
    @private PBTUser *researchFellow;
    @private UIActionSheet *optionsActionSheet;
}

//Main plot of the user to analyze
@property (nonatomic, retain) PBVisualization *visualizationSpace;

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

//Update the credential presented at the top of the screen
-(void)loadUser:(PBTUser *)someUser;

//Visualization related methods, these should be used by the controller
-(void)drawPlotOfTweetsPerDay;
-(void)drawPlotOfTweetsPerWeek;
-(void)drawPlotOfTweetsPerMonth;
-(void)drawScatterPlotOfTweetsPerHourPerDay;

@end
