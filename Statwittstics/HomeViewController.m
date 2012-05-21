//
//  HomeViewController.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 05/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "HomeViewController.h"

@implementation HomeViewController

@synthesize visualizationSpace;
@synthesize subjectOfAnalysis, subjectOfAnalysisView;
@synthesize timeFrameSegmentedControl, visualizationTypeSegmentedControl;
@synthesize numberOfTweetsSlider;
@synthesize numberOfTweetsLabel;
@synthesize researchFellow;
@synthesize optionsActionSheet;

#pragma mark - Object Life-cycle
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setTitle:@"Statwittstics"];
        
        //1024 x 768
        visualizationSpace=[[PBVisualization alloc] initWithFrame:CGRectMake(9, 145, 1005, 550)];
        [[self view] addSubview:visualizationSpace];
        
        researchFellow=nil;
        subjectOfAnalysis=nil;
        subjectOfAnalysisView=[[PBTUserView alloc] initWithUser:nil andPositon:CGPointMake(10, 10)];
        [[self view] addSubview:subjectOfAnalysisView];

        optionsActionSheet=nil;
        
        //Segmented controllers
        timeFrameSegmentedControl=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Daily", @"Daily String"),
                                                                             NSLocalizedString(@"Weekley", @"Weekley String"),
                                                                             NSLocalizedString(@"Monthly", @"Monthly String"), nil]];
        [timeFrameSegmentedControl setFrame:CGRectMake(530, 10, 480, 28)];
        [timeFrameSegmentedControl setMomentary:NO];
        [timeFrameSegmentedControl setTintColor:[UIColor darkGrayColor]];
        [timeFrameSegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [timeFrameSegmentedControl setSelectedSegmentIndex:HVCTimeFrameDaily];        
        [[self view] addSubview:timeFrameSegmentedControl];
        
        visualizationTypeSegmentedControl=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Line Plot", @"Line Plot String"),
                                                                                     NSLocalizedString(@"Scatter Plot", @"Scatter Plot String"),
                                                                                     NSLocalizedString(@"Bar Plot", @"Bar Plot String"), nil]];
        [visualizationTypeSegmentedControl setFrame:CGRectMake(530, 48, 480, 28)];
        [visualizationTypeSegmentedControl setMomentary:NO];
        [visualizationTypeSegmentedControl setTintColor:[UIColor darkGrayColor]];
        [visualizationTypeSegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [visualizationTypeSegmentedControl setSelectedSegmentIndex:HVCVisualizationTypeLinePlot];
        [[self view] addSubview:visualizationTypeSegmentedControl];
        
        //Register both segmented controls in the defaultNotificationCenter
        [timeFrameSegmentedControl addTarget:self action:@selector(segmentedControllSelected:) forControlEvents:UIControlEventValueChanged];
        [visualizationTypeSegmentedControl addTarget:self action:@selector(segmentedControllSelected:) forControlEvents:UIControlEventValueChanged];
        
        
        //Slider for the selection of tweets
        numberOfTweetsSlider=[[UISlider alloc] initWithFrame:CGRectMake(530, 115, 480, 20)];
        [numberOfTweetsSlider setMinimumValue:200];
        [numberOfTweetsSlider setMaximumValue:3200];
        [numberOfTweetsSlider addTarget:self action:@selector(numberOfTweetsSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [[self view] addSubview:numberOfTweetsSlider];
        
        //Label indicating the UISlider fixed value
        numberOfTweetsLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 125, 25)];
        [numberOfTweetsLabel setText:[NSString stringWithString:@""]];
        [numberOfTweetsLabel setCenter:CGPointMake(770, 95)];
        [numberOfTweetsLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:25]];
        [numberOfTweetsLabel setAdjustsFontSizeToFitWidth:NO];
        [numberOfTweetsLabel setTextAlignment:UITextAlignmentCenter];
        [numberOfTweetsLabel setTextColor:[UIColor whiteColor]];
        [numberOfTweetsLabel setShadowColor:[UIColor darkGrayColor]];
        [numberOfTweetsLabel setShadowOffset:CGSizeMake(0.5, 2.5)];
        [numberOfTweetsLabel setBackgroundColor:[UIColor clearColor]];
        [[self view] addSubview:numberOfTweetsLabel];
        
        //Create a smooth animation
        [numberOfTweetsSlider setValue:200 animated:YES];
        [self numberOfTweetsSliderValueChanged:numberOfTweetsSlider];
        
        //These buttons take charge of going somewhere else in the application
        UIBarButtonItem *optionsBarButton=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Options", @"Options String") 
                                                                           style:UIBarButtonItemStyleBordered 
                                                                          target:self 
                                                                          action:@selector(optionsButtonPressed:)];
        
        UIBarButtonItem *aboutBarButton=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"About", @"About String") 
                                                                         style:UIBarButtonItemStyleBordered 
                                                                        target:self 
                                                                        action:@selector(aboutButtonPressed:)];
        
        [[self navigationItem] setRightBarButtonItem:optionsBarButton];
        [optionsBarButton release];
        
        [[self navigationItem] setLeftBarButtonItem:aboutBarButton];
        [aboutBarButton release];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];

    //Ask the account store for the twitter account
    ACAccountStore *astore=[[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType=[astore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    //Ask for permission to use the twitter credentials of the user
    [astore requestAccessToAccountsWithType:twitterAccountType withCompletionHandler:^(BOOL granted, NSError *error){
        
        //Check for no errors and for granted access
        if (granted == YES || error == nil) {
            //Request the first twitter account available 
            NSArray *twitterAccounts=[astore accountsWithAccountType:twitterAccountType];
            ACAccount *theAccount=[twitterAccounts objectAtIndex:0];
            
            //Twitter test
            researchFellow=[[PBTUser alloc] initWithUsername:[theAccount username] andAuthorizedAccount:theAccount];
            subjectOfAnalysis=[researchFellow retain];
            
            [subjectOfAnalysis requestUserData:^{
                
                #ifdef DEBUG
                NSLog(@"The real name is %@, annoyingly tweeted %d", [subjectOfAnalysis realName], [subjectOfAnalysis tweetCount]);
                NSLog(@"Has %d followers and %d friends", [subjectOfAnalysis followers], [subjectOfAnalysis following]);
                NSLog(@"The URL is: %@", [subjectOfAnalysis bioURL]);
                NSLog(@"The location is: %@", [subjectOfAnalysis location]);
                NSLog(@"The bio is: %@", [subjectOfAnalysis description]);
                #endif
                
                //Load the view
                [self performSelectorOnMainThread:@selector(downloadTweets) withObject:nil waitUntilDone:YES];
            }];
        }
        else {
            //Must implement a GUI alert 
            NSLog(@"HomeViewController:Error** Statwittstics needs access to a twitter account.");
            NSLog(@"HomeViewController:Error** %@", [error localizedDescription]);
        }
        
    }];
    
}

-(void)dealloc{
    [visualizationSpace release];
    [timeFrameSegmentedControl release];
    [visualizationTypeSegmentedControl release];
    [numberOfTweetsSlider release];
    [numberOfTweetsLabel release];
    
    [subjectOfAnalysisView release];
    [subjectOfAnalysis release];
    [researchFellow release];

    if (optionsActionSheet != nil) {
        [optionsActionSheet release];
    }
    
    [super dealloc];
}

-(void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    //Do not allow portrait, only landscape
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return NO;
    }
    
	return YES;
}

#pragma mark - Button Callbacks
-(void)optionsButtonPressed:(id)sender{
    //Do not cause overhead, the user could probably not use the options therefore you would be creating an action sheet when not needed
    if ( optionsActionSheet == nil) {
        optionsActionSheet=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Options", @"Options String") 
                                                 delegate:self 
                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel String") 
                                   destructiveButtonTitle:NSLocalizedString(@"Hide", @"Hide String") 
                                        otherButtonTitles:NSLocalizedString(@"New Subject", @"New Subject String"), NSLocalizedString(@"Share on Twitter", @"Share on Twitter String"), nil];
        
        //The only implementation needed is the actionSheet:clickedButtonAtIndex: method
        [optionsActionSheet setDelegate:self];
    }
    
    //Implement an XOR behavior, to check whether or not the UIActionSheet is visible
    if ( ![optionsActionSheet isVisible]) {
        [optionsActionSheet showFromBarButtonItem:[[self navigationItem] rightBarButtonItem] animated:YES];
    }
    else {
        //Hide it using the "Hide button"
        [optionsActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    }
}

-(void)aboutButtonPressed:(id)sender{
    //Load the AboutViewController and release it
    AboutViewController *viewController=[[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    [[self navigationController] presentModalViewController:viewController animated:YES];
    [viewController release];
    
}

#pragma mark - HomeViewControllerStateManagers
-(void)segmentedControllSelected:(id)sender{
    PBDataSet *someDataSet=nil;
    NSUInteger calendarUnit=0;
    NSString *xAxisTitle=nil;
    
    //Update the controller interaction
    [self fixControllersInteraction];
    
    //Depending on the index
    switch ([timeFrameSegmentedControl selectedSegmentIndex]) {
        case HVCTimeFrameDaily:
            calendarUnit=NSDayCalendarUnit;
            xAxisTitle=[NSString stringWithString:NSLocalizedString(@"Days", @"Days String")];
            break;
        case HVCTimeFrameWeekley:
            calendarUnit=NSWeekCalendarUnit;
            xAxisTitle=[NSString stringWithString:NSLocalizedString(@"Weeks", @"Weeks String")];            
            break;
        case HVCTimeFrameMonthly:
            calendarUnit=NSMonthCalendarUnit;
            xAxisTitle=[NSString stringWithString:NSLocalizedString(@"Months", @"Months String")];
            break;
        default:
            break;
    }

    //Set the time metric needed for the data set, only if it is not for the scatter plot
    if ([visualizationTypeSegmentedControl selectedSegmentIndex] != HVCVisualizationTypeScatterPlot) {
        someDataSet=[[subjectOfAnalysis dataSetOfTweetsPerCalendarUnit:calendarUnit] retain];
    }
    //Otherwise, just create the other type of data-set
    else {
        someDataSet=[[subjectOfAnalysis dataSetOfTweetsForHourPerDay] retain];
    }
    
    //Remove the top or last view, which is in this case the plot
    if ([[visualizationSpace subviews] count] != 0) {
        [[[visualizationSpace subviews] objectAtIndex:[[visualizationSpace subviews] count] - 1] removeFromSuperview];
    }

    if ( [visualizationTypeSegmentedControl selectedSegmentIndex] == HVCVisualizationTypeLinePlot ) {
        
        //Style for the plot
        [someDataSet setSymbol:[PBUtilities symbolWithType:CPTPlotSymbolTypeHexagon size:5 andColor:[CPTColor blackColor]]];
        
        PBPlot *linePlot=[[PBPlot alloc] initWithFrame:CGRectMake(0, 0, 1005, 550) andDataSets:[NSArray arrayWithObjects:someDataSet, nil]];
        
        //Titles
        [linePlot setXAxisTitle:xAxisTitle];
        [linePlot setYAxisTitle:NSLocalizedString(@"Number Of Tweets", @"Number Of Tweets String")];
        [linePlot setGraphTitle:[someDataSet dataSetTitle]];
        
        //Plot attributes
        [linePlot setXAxisUpperBound:[[someDataSet maximumXValue] intValue] andLowerBound:0];
        [linePlot setYAxisUpperBound:[[someDataSet maximumYValue] intValue] andLowerBound:0];
        [linePlot showGrids];
        
        // Do any additional setup after loading the view.
        [[self visualizationSpace] addSubview:linePlot];
        [linePlot release];
        [someDataSet release];
    }
    else if ([visualizationTypeSegmentedControl selectedSegmentIndex] == HVCVisualizationTypeScatterPlot) {
        //Style for the plot
        [someDataSet setSymbol:[PBUtilities symbolWithType:CPTPlotSymbolTypeHexagon size:8 andColor:[CPTColor redColor]]];
        
        PBPlot *scatterPlot=[[PBPlot alloc] initWithFrame:CGRectMake(0, 0, 1005, 550) andDataSets:[NSArray arrayWithObjects:someDataSet, nil]];
        
        //Set the limits and ticks intervals
        [scatterPlot setXAxisUpperBound:90060 andLowerBound:0];
        [scatterPlot setYAxisUpperBound:8 andLowerBound:0];
        [scatterPlot setMajorTicksWithXInterval:3752.5 andYInterval:1];
        
        //Set the titles
        [scatterPlot setXAxisTitle:NSLocalizedString(@"Hour Of Day", @"Hour Of Day String")];
        [scatterPlot setYAxisTitle:NSLocalizedString(@"Day Of Week", @"Day Of Week String")];
        [scatterPlot setGraphTitle:[someDataSet dataSetTitle]];
        
        //Show the grids and custom ticks
        [scatterPlot showGrids];
        [scatterPlot setXTicksLabels:[NSArray arrayWithObjects:HOURS_ARRAY, nil]];
        [scatterPlot setYTicksLabels:[NSArray arrayWithObjects:DAYS, nil] withRotation:M_PI_2];
        [scatterPlot setViewIsRestricted:YES];
        
        //Allow user interactions
        [[[scatterPlot graph] defaultPlotSpace] setAllowsUserInteraction:YES];
        
        // Do any additional setup after loading the view.
        [[self visualizationSpace] addSubview:scatterPlot];
        [scatterPlot release];
        [someDataSet release];
    }
    else if ([visualizationTypeSegmentedControl selectedSegmentIndex] == HVCVisualizationTypeBarPlot){
        //Style for the bar plot
        [someDataSet setFillingColor:[CPTColor darkGrayColor]];
        
        PBBar *barPlot=[[PBBar alloc] initWithFrame:CGRectMake(0, 0, 1005, 550) andDataSets:[NSArray arrayWithObjects:someDataSet, nil]];
        
        //Titles
        [barPlot setXAxisTitle:xAxisTitle];
        [barPlot setYAxisTitle:NSLocalizedString(@"Number Of Tweets", @"Number Of Tweets String")];
        [barPlot setGraphTitle:[someDataSet dataSetTitle]];
        
        //Plot attributes
        [barPlot setXAxisUpperBound:[[someDataSet maximumXValue] intValue] andLowerBound:0];
        [barPlot setYAxisUpperBound:[[someDataSet maximumYValue] intValue] andLowerBound:0];
        [barPlot showGrids];
        
        // Do any additional setup after loading the view.
        [[self visualizationSpace] addSubview:barPlot];
        [barPlot release];
        [someDataSet release];
    }
}

-(void)downloadTweets{
    [subjectOfAnalysisView loadUser:subjectOfAnalysis];
    [subjectOfAnalysis requestMostRecentTweets:[[numberOfTweetsLabel text] intValue] withHandler:^{
        
        //Go to the main thread and perform the GUI changes, here comes the magic ... 
        [self performSelectorOnMainThread:@selector(segmentedControllSelected:) withObject:nil waitUntilDone:YES];
    }];
}

#pragma mark - HomeVieControllerInterfaceManagerMethods
-(void)fixControllersInteraction{
    //Initial state, this six lines will save us from having to reset this state on every call
    [timeFrameSegmentedControl setEnabled:YES forSegmentAtIndex:HVCTimeFrameDaily];
    [timeFrameSegmentedControl setEnabled:YES forSegmentAtIndex:HVCTimeFrameWeekley];
    [timeFrameSegmentedControl setEnabled:YES forSegmentAtIndex:HVCTimeFrameMonthly];
    [visualizationTypeSegmentedControl setEnabled:YES forSegmentAtIndex:HVCVisualizationTypeBarPlot];
    [visualizationTypeSegmentedControl setEnabled:YES forSegmentAtIndex:HVCVisualizationTypeLinePlot];
    [visualizationTypeSegmentedControl setEnabled:YES forSegmentAtIndex:HVCVisualizationTypeScatterPlot];
    
    //Select the current behavior, having a scatter plot option is only useful for the daily
    //time-frame selection, otherwise it pretty much makes no sense and the plot will be empty.
    switch ([visualizationTypeSegmentedControl selectedSegmentIndex]) {
        case HVCVisualizationTypeScatterPlot:
            [timeFrameSegmentedControl setEnabled:NO forSegmentAtIndex:HVCTimeFrameMonthly];
            [timeFrameSegmentedControl setEnabled:NO forSegmentAtIndex:HVCTimeFrameWeekley];
            break;
        default:
            break;
    }
    
    //The scatter plot is only available when the daily time-frame is selected
    switch ([timeFrameSegmentedControl selectedSegmentIndex]) {
        case HVCTimeFrameDaily:
            [visualizationTypeSegmentedControl setEnabled:YES forSegmentAtIndex:HVCVisualizationTypeScatterPlot];
            break;
        case HVCTimeFrameWeekley:
            [visualizationTypeSegmentedControl setEnabled:NO forSegmentAtIndex:HVCVisualizationTypeScatterPlot];
            break;
        case HVCTimeFrameMonthly:
            [visualizationTypeSegmentedControl setEnabled:NO forSegmentAtIndex:HVCVisualizationTypeScatterPlot];
            break;
            
        default:
            break;
    }
}

-(void)numberOfTweetsSliderValueChanged:(UISlider *)slider{
    NSInteger newValue=0;
    [numberOfTweetsSlider setValue:HVCFixSliderValue([slider value])];
    newValue=(NSInteger)HVCFixSliderValue([slider value]);
    
    [numberOfTweetsLabel setText:[NSString stringWithFormat:@"%d", newValue]];
}

float HVCFixSliderValue(float sliderValue){
    NSUInteger i=0;
    
    //There are only 16 different available positions
    for (i=1; i<17; i++) {
        //Times 200, because the slider has a min of 200 and a max of 3200
        if (i*200 >= sliderValue) {
            //Got it? Return it
            return i*200;
        }
    }
    
    //Should never happen, but return a zero value
    return 0;
}

#pragma mark - UIActionSheetDelegate Methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //Load a view controller ... if needed
    id viewController=nil;
    
    switch (buttonIndex) {
        case HVCActionSheetButtonNew:
            viewController=[[FindUserViewController alloc] initWithResearchFellow:researchFellow andViewController:self];
            [[self navigationController] presentModalViewController:viewController animated:YES];
            [viewController release];
            break;
        
        case HVCActionSheetButtonShare:
            
            break;
            
        default:
            break;
    }
    
    return;
}

@end
