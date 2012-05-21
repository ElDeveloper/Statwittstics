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

//The main action sheet of the class displays three buttons only.
typedef enum {
    HVCActionSheetButtonCancel=0,
    HVCActionSheetButtonNew=1,
    HVCActionSheetButtonShare=2
}HVCActionSheetButton;

//There are three type of possible time-frames that can be used in the class
//the value will be also the index of the button for a UISegmentedController.
typedef enum {
    HVCTimeFrameDaily=0,
    HVCTimeFrameWeekley,
    HVCTimeFrameMonthly
}HVCTimeFrame;

//There are three type of possible visualization types that can be used in the class
//the value will be also the index of the button for a UISegmentedController.
typedef enum {
    HVCVisualizationTypeLinePlot=0,
    HVCVisualizationTypeScatterPlot,
    HVCVisualizationTypeBarPlot
}HVCVisualizationType;

@interface HomeViewController : UIViewController <UIActionSheetDelegate>{
    
    PBVisualization *visualizationSpace;
    PBTUser *subjectOfAnalysis;
    PBTUserView *subjectOfAnalysisView;
    
    UISegmentedControl *timeFrameSegmentedControl;
    UISegmentedControl *visualizationTypeSegmentedControl;
    
    UISlider *numberOfTweetsSlider;
    
    @private UILabel *numberOfTweetsLabel;
    @private PBTUser *researchFellow;
    @private UIActionSheet *optionsActionSheet;
}

//Main plot of the user to analyze
@property (nonatomic, retain) PBVisualization *visualizationSpace;

//The user to analyze (model and view)
@property (nonatomic, retain) PBTUser *subjectOfAnalysis;
@property (nonatomic, retain) PBTUserView *subjectOfAnalysisView;

//Segmented controllers in charge of the visualization type and the time-frame
@property (nonatomic, retain) UISegmentedControl *timeFrameSegmentedControl;
@property (nonatomic, retain) UISegmentedControl *visualizationTypeSegmentedControl;

//Display and controller for the number of tweets
@property (nonatomic, retain) UISlider *numberOfTweetsSlider;
@property (nonatomic, retain) UILabel *numberOfTweetsLabel;

//This user is required and will be the default for application launch
@property (nonatomic, retain) PBTUser *researchFellow;

//General private attributes of the ViewController
@property (nonatomic, weak) UIActionSheet *optionsActionSheet;

//Buttons that provide the actions for the whole application
-(void)optionsButtonPressed:(id)sender;
-(void)aboutButtonPressed:(id)sender;

//Top-level updater for the GUI, will create and change the visualizations, depending
//on the current state of the controllers and on the data from the subject of analysis.
-(void)segmentedControllSelected:(id)sender;

//Request the data for the subject of analysis
-(void)downloadTweets;

//Low-level helpers for the GUI updaters
-(void)fixControllersInteraction;
-(void)numberOfTweetsSliderValueChanged:(UISlider *)slider;
float HVCFixSliderValue(float sliderValue);

@end
