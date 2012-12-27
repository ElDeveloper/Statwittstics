//
//  HomeViewController.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 05/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "HomeViewController.h"

#import "FindUserViewController.h"
#import "AccountSelectorViewController.h"

@interface HomeViewController (PrivateAPI)

-(void)showAccountSelector:(AccountSelectorViewController *)viewController;

@end

@implementation HomeViewController

@synthesize visualizationSpace;
@synthesize subjectOfAnalysis, subjectOfAnalysisView;
@synthesize timeFrameSegmentedControl, visualizationTypeSegmentedControl;
@synthesize numberOfTweetsSlider, numberOfTweetsLabel;
@synthesize researchFellow;
@synthesize optionsActionSheet;
@synthesize loadingAlertView;

#pragma mark - Object Life-cycle
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setTitle:@"Statwittstics"];
        
        isFirstLoad=YES;
        
        //1024 x 768
        visualizationSpace=[[PBVisualization alloc] initWithFrame:CGRectMake(9, 145, 1005, 550)];
        [[self view] addSubview:visualizationSpace];
        
        researchFellow=nil;
        subjectOfAnalysis=nil;
        subjectOfAnalysisView=[[PBTUserView alloc] initWithUser:nil andPositon:CGPointMake(10, 10)];
        [[self view] addSubview:subjectOfAnalysisView];

        optionsActionSheet=nil;
        
        //Segmented controllers
        timeFrameSegmentedControl=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                             NSLocalizedString(@"Hourly", @"Hourly String"),
                                                                             NSLocalizedString(@"Daily", @"Daily String"),
                                                                             NSLocalizedString(@"Weekly", @"Weekley String"),
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
        
        //TouchUpInside and Outside are needed to catch the events when the
        //UISlider is moving to the left (outside) and to the right (inside)
        [numberOfTweetsSlider addTarget:self action:@selector(downloadTweets) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
        [[self view] addSubview:numberOfTweetsSlider];
        
        //Label indicating the UISlider fixed value
        numberOfTweetsLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 125, 25)];
        [numberOfTweetsLabel setText:@""];
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
        
        //Instantiate the alert view as a waiting alert
        loadingAlertView=[[GIDAAlertView alloc] initAlertWithSpinnerAndMessage:NSLocalizedString(@"Accessing Account", @"Accessing Account String")];
        
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
    
    __block UIAlertView *errorAlertView=nil;
    
    //Ask for permission to use the twitter credentials of the user
    [astore requestAccessToAccountsWithType:twitterAccountType withCompletionHandler:^(BOOL granted, NSError *error){
        
        //Check for no errors and for granted access
        if (granted == YES && !error) {
            //Request the first twitter account available 
            NSArray *twitterAccounts=[astore accountsWithAccountType:twitterAccountType];
			AccountSelectorViewController *viewController=[[AccountSelectorViewController alloc] initWithAccounts:twitterAccounts andCompletionHandler:^(ACAccount *selectedAccount, NSError *error){

				//Make sure we have an account and no errors
				if (selectedAccount && !error) {
					//Work with the selected account from the available accounts
					researchFellow=[[PBTUser alloc] initWithUsername:[selectedAccount username] andAuthorizedAccount:selectedAccount];
					subjectOfAnalysis=[researchFellow retain];

					[subjectOfAnalysis requestUserData:^(NSError *error){
						if (!error) {
							#ifdef DEBUG
							NSLog(@"The real name is %@, annoyingly tweeted %d", [subjectOfAnalysis realName], [subjectOfAnalysis tweetCount]);
							NSLog(@"Has %d followers and %d friends", [subjectOfAnalysis followers], [subjectOfAnalysis following]);
							NSLog(@"The URL is: %@", [subjectOfAnalysis bioURL]);
							NSLog(@"The location is: %@", [subjectOfAnalysis location]);
							NSLog(@"The bio is: %@", [subjectOfAnalysis description]);
							#endif

							//Hide the alert for the account request
							[loadingAlertView performSelectorOnMainThread:@selector(hideAlertWithSpinner) withObject:nil waitUntilDone:YES];

							//Load the data into the view
							[self performSelectorOnMainThread:@selector(downloadTweets) withObject:nil waitUntilDone:YES];
						}
						else {
							NSLog(@"HomeView_Controller:%s**:%@", __PRETTY_FUNCTION__, [error localizedDescription]);
							errorAlertView=[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"Error", @"Error String"), [error code]]
																	  message:[error localizedDescription]
																	 delegate:self
															cancelButtonTitle:NSLocalizedString(@"Accept", @"Accept String")
															otherButtonTitles:NSLocalizedString(@"Try Again", @"Try Again String"), nil];
							[errorAlertView setTag:HVCAlertAccessAccount];
							[errorAlertView show];
							[errorAlertView release];	
						}
					}];// subject of analysis request of data
				}
				else{
					// This error handling should be improved
					errorAlertView=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error String")
															  message:NSLocalizedString(@"Cannot use Statwittstics, sorry", @"Apology String")
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Accept", @"Accept String")
													otherButtonTitles:nil];
					[errorAlertView show];
					[errorAlertView release];
				}
			}];// AccountSelectorViewController completion handler

			[viewController setModalPresentationStyle:UIModalPresentationFormSheet];
			[self performSelectorOnMainThread:@selector(showAccountSelector:) withObject:viewController waitUntilDone:NO];

        }
        else {
            //Must implement a GUI alert
            NSLog(@"HomeViewController:Error** Statwittstics needs access to a twitter account.");
            NSLog(@"HomeViewController:Error** %@", [error localizedDescription]);

            errorAlertView=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error String")
                                                      message:[error localizedDescription] 
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"Accept", @"Accept String")
                                            otherButtonTitles:NSLocalizedString(@"Try Again", @"Try Again String"), nil];
            [errorAlertView setTag:HVCAlertAccessAccount];
            [errorAlertView show];
            [errorAlertView release];
        }
        
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //Add the alert view; this considers the fact that the viewDidAppear method is called before the account
    //manager is resolved. Once the account manager resolved the request, a the alert will be gone.
    [loadingAlertView presentAlertWithSpinnerInView:[self view]];
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

#pragma mark - UIBarButton Callbacks
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

#pragma mark - Workflow Controllers
-(void)showAccountSelector:(AccountSelectorViewController *)viewController{
	[[self navigationController] presentModalViewController:viewController animated:YES];
	[viewController release];
}

-(void)downloadTweets{
    //Show the spinner with a different message
    [[loadingAlertView messageLabel] setText:NSLocalizedString(@"Downloading", @"Downloading String")];
    [loadingAlertView presentAlertWithSpinnerInView:[self view]];
    
    //Load the data of the user into the PBTUserView
    [subjectOfAnalysisView loadUser:subjectOfAnalysis];
    
    //Request for the data
    [subjectOfAnalysis requestMostRecentTweets:[[numberOfTweetsLabel text] intValue] withHandler:^(NSError *error){
        UIAlertView *errorAlertView=nil;
        
        //Check for errors in the request for twitts
        if (!error) {
            [loadingAlertView performSelectorOnMainThread:@selector(hideAlertWithSpinner) withObject:nil waitUntilDone:NO];
            
            //Go to the main thread and perform the GUI changes, here comes the magic ... 
            [self performSelectorOnMainThread:@selector(segmentedControllSelected:) withObject:nil waitUntilDone:NO];
        }
        else {
            NSLog(@"HomeViewController:%s**:%@", __PRETTY_FUNCTION__, [error localizedDescription]);
            errorAlertView=[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"Error", @"Error String"), [error code]]
                                                      message:[error localizedDescription] 
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"Accept", @"Accept String")
                                            otherButtonTitles:NSLocalizedString(@"Try Again", @"Try Again String"), nil];
            [errorAlertView setTag:HVCAlertDownloadTweets];
            [errorAlertView show];
            [errorAlertView release];
        }
    }];
}

-(void)segmentedControllSelected:(id)sender{
    PBDataSet *someDataSet=nil;
    NSUInteger calendarUnit=0;
    NSString *xAxisTitle=nil;
    
    //Update the controller interaction
    [self fixControllersInteraction];
    
    //Depending on the index
    switch ([timeFrameSegmentedControl selectedSegmentIndex]) {
        case HVCTimeFrameHourly:
            xAxisTitle=[NSString stringWithString:NSLocalizedString(@"Hours", @"Hours String")];
            break;
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
        
        //Unless it can be calculated with the calendar units
        if ([timeFrameSegmentedControl selectedSegmentIndex] == HVCTimeFrameHourly) {
            someDataSet=[[subjectOfAnalysis dataSetOfFrequencyOfTweetsPerHour:[[numberOfTweetsLabel text] integerValue]] retain];
        }
        else {
            someDataSet=[[subjectOfAnalysis dataSetOfTweets:[[numberOfTweetsLabel text] integerValue] byCalendarUnit:calendarUnit] retain];   
        }
    }
    //Otherwise, just create the other type of data-set
    else {
        someDataSet=[[subjectOfAnalysis dataSetOfTweetsAtHourAtDay:[[numberOfTweetsLabel text] integerValue]] retain];
    }
    
    if ([someDataSet dataSetLength] <= 1) {
        [GIDAAlertView presentAlertFor:1.8
                           withMessage:NSLocalizedString(@"Not Enough Tweets", @"Not Enough Tweets String") 
                              andImage:[UIImage imageNamed:@"noresource.png"] 
                                inView:[self view]];
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
        [linePlot setViewIsRestricted:YES];
        
        //Plot attributes
        [[[linePlot graph] defaultPlotSpace] setAllowsUserInteraction:YES];
        [linePlot setXAxisUpperBound:[[someDataSet maximumXValue] intValue] andLowerBound:0];
        [linePlot setYAxisUpperBound:[[someDataSet maximumYValue] intValue] andLowerBound:0];
        
        [linePlot showGrids];
        [self mendXTicksIntervalsFor:linePlot];
        [linePlot beginDataPointsAnimationWithDuration:2 andCompletionHandler:^{}];
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
        [[[scatterPlot graph] defaultPlotSpace] setAllowsUserInteraction:YES];
        [scatterPlot setViewIsRestricted:YES];
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
    else /*if ([visualizationTypeSegmentedControl selectedSegmentIndex] == HVCVisualizationTypeBarPlot)*/{
        //Style for the bar plot
        [someDataSet setFillingColor:[CPTColor darkGrayColor]];
        
        PBBar *barPlot=[[PBBar alloc] initWithFrame:CGRectMake(0, 0, 1005, 550) andDataSets:[NSArray arrayWithObjects:someDataSet, nil]];
        
        //Titles
        [[[barPlot graph] defaultPlotSpace] setAllowsUserInteraction:YES];
        [barPlot setXAxisTitle:xAxisTitle];
        [barPlot setYAxisTitle:NSLocalizedString(@"Number Of Tweets", @"Number Of Tweets String")];
        [barPlot setGraphTitle:[someDataSet dataSetTitle]];
        
        //Plot attributes
        [barPlot setViewIsRestricted:YES];
        
        //See which type of X ticks and limits are needed
        if ([timeFrameSegmentedControl selectedSegmentIndex] == HVCTimeFrameHourly) {
            
            //Set the qualities for the x axis, the y axis will remain the same
            [barPlot setXAxisUpperBound:24 andLowerBound:0];
            [barPlot setMajorTicksWithXInterval:1];
            [barPlot setXTicksLabels:[NSArray arrayWithObjects:HOURS_ARRAY, nil]];
        }
        else {
            [barPlot setXAxisUpperBound:[[someDataSet maximumXValue] intValue]+1 andLowerBound:0];
            [self mendXTicksIntervalsFor:barPlot];
        }
        
        //Y axis behaves the same for the bar plots
        [barPlot setYAxisUpperBound:[[someDataSet maximumYValue] intValue] andLowerBound:0];
        
        [barPlot showGrids];
        
        // Do any additional setup after loading the view.
        [[self visualizationSpace] addSubview:barPlot];
        [barPlot release];
        [someDataSet release];
    }
    
    //Once per application-launch
    if (isFirstLoad) {
        isFirstLoad=NO;
        [[self visualizationSpace] performAnimationWithStyle:PBAnimationStyleExapand|PBAnimationStyleFadeIn andHandler:^{}];
    }
}

-(void)numberOfTweetsSliderValueChanged:(UISlider *)slider{
    NSInteger newValue=0;
    [numberOfTweetsSlider setValue:HVCFixSliderValue([slider value])];
    newValue=(NSInteger)HVCFixSliderValue([slider value]);
    
    [numberOfTweetsLabel setText:[NSString stringWithFormat:@"%d", newValue]];
}

#pragma mark - Utilities
-(void)fixControllersInteraction{
    //Initial state, this six lines will save us from having to reset this state on every call
    [timeFrameSegmentedControl setEnabled:YES forSegmentAtIndex:HVCTimeFrameHourly];
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
            [timeFrameSegmentedControl setEnabled:NO forSegmentAtIndex:HVCTimeFrameHourly];
            [timeFrameSegmentedControl setEnabled:NO forSegmentAtIndex:HVCTimeFrameMonthly];
            [timeFrameSegmentedControl setEnabled:NO forSegmentAtIndex:HVCTimeFrameWeekley];
            break;
        case HVCVisualizationTypeLinePlot:
            [timeFrameSegmentedControl setEnabled:NO forSegmentAtIndex:HVCTimeFrameHourly];
            break;
        case HVCVisualizationTypeBarPlot:
        default:
            break;
    }
    
    //Here set, what visualizations are allowed for a given time-frame
    //The scatter plot is only available when the daily time-frame is selected
    switch ([timeFrameSegmentedControl selectedSegmentIndex]) {
        case HVCTimeFrameHourly:
            [visualizationTypeSegmentedControl setEnabled:NO forSegmentAtIndex:HVCVisualizationTypeScatterPlot];
            [visualizationTypeSegmentedControl setEnabled:NO forSegmentAtIndex:HVCVisualizationTypeLinePlot];
            [visualizationTypeSegmentedControl setEnabled:NO forSegmentAtIndex:HVCVisualizationTypeScatterPlot];
            break;
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

-(void)mendXTicksIntervalsFor:(PBXYVisualization *)visualization{
    NSMutableArray *arrayOfStringDates=[[NSMutableArray alloc] init];
    
    NSString *bufferString=nil;
    
    int i=0;
    NSDate *finalDate=[[[subjectOfAnalysis tweets] objectAtIndex:0] postDate];
    NSDate *bufferDate=nil;
    
    //Keep the current appearance by retrieving these properties
    CPTXYPlotSpace *plotSpace=(CPTXYPlotSpace *)[[visualization graph] defaultPlotSpace];
    CPTXYAxisSet *axisSet=(CPTXYAxisSet *)[[visualization graph] axisSet];
    CPTXYAxis *xAxis=[axisSet xAxis];
    
    //Avoid the over-head of repeating this calculations for each iteration
    float majorTickInterval=CPTDecimalFloatValue([xAxis majorIntervalLength]);
    
    //The use of the ranges help us calculate how many ticks are visible in the scrreen
    float rangeLocation=CPTDecimalFloatValue([[plotSpace xRange] location]);
    float rangeLength=CPTDecimalFloatValue([[plotSpace xRange] length]);
    int visibleTicks=(int)floor((rangeLength / majorTickInterval));
    
    NSCalendarUnit unitToUse=NSDayCalendarUnit;
    
    switch ([timeFrameSegmentedControl selectedSegmentIndex]) {
        case HVCTimeFrameDaily:
            unitToUse=NSDayCalendarUnit;
            break;
        case HVCTimeFrameWeekley:
            unitToUse=NSWeekCalendarUnit;
            break;
        case HVCTimeFrameMonthly:
            unitToUse=NSMonthCalendarUnit;
        default:
            break;
    }
    
    //Go through every of the visible ticks and add the custom label provided
    //Note: the look-up is being done reversely because the starting date is the
    //first object of the available array of tweets for the subject of analysis,
    //so we can avoid having to do other calculations to make this non-reversal
    for(i=visibleTicks; i >= 0; i--){
        bufferDate=PBTAddCalendarUnitToDate(finalDate, rangeLocation-(i*majorTickInterval), unitToUse);
        bufferString=[PBTStringFromTwitterDateWithFormat(bufferDate, @"dd/MMM/yyyy") copy];
        [arrayOfStringDates addObject:bufferString];
        [bufferString release];
    }
    [visualization setXTicksLabels:arrayOfStringDates];
    
    [arrayOfStringDates release];
}

#pragma mark - UIActionSheetDelegate Methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //Load a view controller ... if needed
    id viewController=nil;
    UIImage *plotImage=nil;
    
    switch (buttonIndex) {
        case HVCActionSheetButtonNew:
            viewController=[[FindUserViewController alloc] initWithResearchFellow:researchFellow];
			[viewController setDelegate:self];
            [[self navigationController] presentModalViewController:viewController animated:YES];
            [viewController release];
            break;
        
        case HVCActionSheetButtonShare:
            plotImage=[[[visualizationSpace subviews] objectAtIndex:[[visualizationSpace subviews] count] - 1] imageRepresentation];
            
            [self showTweetViewControllerWithImage:plotImage];
            break;
            
        default:
            break;
    }
    
    return;
}

-(void)showTweetViewControllerWithImage:(UIImage *)imageToTweet{
    NSString *firstText=[NSString stringWithString:NSLocalizedString(@"Analyizing", @"Body String First Part")];
    NSString *secondText=[NSString stringWithString:NSLocalizedString(@"with @Statwittstics, look at this cool plot: ", @"Body String Second Part")];
    NSString *fullMessage=[NSString stringWithFormat:@"%@ @%@ %@", firstText, [subjectOfAnalysis username], secondText];
    
    // Set up the built-in twitter composition view controller.
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    
    // Set the initial tweet text. See the framework for additional properties that can be set.
    [tweetViewController setInitialText:fullMessage];
    
    //Image
    [tweetViewController addImage:imageToTweet];
    
    // Create the completion handler block.
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        
        switch (result) {
            case TWTweetComposeViewControllerResultCancelled:
                //Tweet is cancelled

                break;
            case TWTweetComposeViewControllerResultDone:
                //Tweet is sent

                break;
            default:
                break;
        }
        [self dismissModalViewControllerAnimated:YES];
    }];
    
    // Present the tweet composition view controller modally.
    [self presentModalViewController:tweetViewController animated:YES];
    [tweetViewController release];
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        switch ([alertView tag]) {
            case HVCAlertAccessAccount:
                [self viewDidLoad];
                break;
            case HVCAlertDownloadTweets:
                [self downloadTweets];
                break;
            default:
                break;
        }
    }
    else {
        [loadingAlertView hideAlertWithSpinner];
    }
}


#pragma mark - FindUserViewControllerDelegate Methods
- (void)subjectWasSelected:(PBTUser *)newSubject{
	#ifdef DEBUG
	NSLog(@"The selected subject is %@", [newSubject username]);
	#endif

	//Grant access to this new subject
	[self setSubjectOfAnalysis:newSubject];
	[[self subjectOfAnalysis] setAccount:[researchFellow account]];

	// Start requesting the most recent N twitts for the new subject
	[self performSelectorOnMainThread:@selector(downloadTweets) withObject:nil waitUntilDone:NO];
}

@end
