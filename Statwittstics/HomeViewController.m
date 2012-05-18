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
        [timeFrameSegmentedControl setTag:HVCSegmentedControlTimeFrame];
        [timeFrameSegmentedControl setSelectedSegmentIndex:HVCTimeFrameDaily];        
        [[self view] addSubview:timeFrameSegmentedControl];
        
        visualizationTypeSegmentedControl=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Line Plot", @"Line Plot String"),
                                                                                     NSLocalizedString(@"Scatter Plot", @"Scatter Plot String"),
                                                                                     NSLocalizedString(@"Bar Plot", @"Bar Plot String"), nil]];
        [visualizationTypeSegmentedControl setFrame:CGRectMake(530, 48, 480, 28)];
        [visualizationTypeSegmentedControl setMomentary:NO];
        [visualizationTypeSegmentedControl setTintColor:[UIColor darkGrayColor]];
        [visualizationTypeSegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [visualizationTypeSegmentedControl setTag:HVCSegmentedControlVisualizationType];
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
                [subjectOfAnalysisView performSelectorOnMainThread:@selector(loadUser:) withObject:subjectOfAnalysis waitUntilDone:YES];
                
                [self downloadTweets];
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

-(void)segmentedControllSelected:(UISegmentedControl *)segmentedControl{
    PBDataSet *someDataSet=nil;
    NSUInteger calendarUnit=0;
    
    //Depending on the index
    switch ([timeFrameSegmentedControl selectedSegmentIndex]) {
        case HVCTimeFrameDaily:
            calendarUnit=NSDayCalendarUnit;
            break;
        case HVCTimeFrameWeekley:
            calendarUnit=NSWeekCalendarUnit;
            break;
        case HVCTimeFrameMonthly:
            calendarUnit=NSMonthCalendarUnit;
            break;
        default:
            break;
    }

    
    someDataSet=[[subjectOfAnalysis dataSetOfTweetsPerCalendarUnit:calendarUnit] retain];
    [someDataSet setSymbol:[PBUtilities symbolWithType:CPTPlotSymbolTypeHexagon size:5 andColor:[CPTColor blackColor]]];
    
    if ([[visualizationSpace subviews] count] != 0) {
        [[[visualizationSpace subviews] objectAtIndex:[[visualizationSpace subviews] count] - 1] removeFromSuperview];
    }

    if ( [visualizationTypeSegmentedControl selectedSegmentIndex] == HVCVisualizationTypeLinePlot ) {
        PBPlot *tweetsPerDayPlot=[[PBPlot alloc] initWithFrame:CGRectMake(0, 0, 1005, 550) andDataSets:[NSArray arrayWithObjects:someDataSet, nil]];
        
        //Titles
        [tweetsPerDayPlot setXAxisTitle:@"Día"];
        [tweetsPerDayPlot setYAxisTitle:@"Número de Tweets"];
        [tweetsPerDayPlot setGraphTitle:[someDataSet dataSetTitle]];
        
        //Plot attributes
        [tweetsPerDayPlot setAxisTight];
        [tweetsPerDayPlot showGrids];
        
        // Do any additional setup after loading the view.
        [[self visualizationSpace] addSubview:tweetsPerDayPlot];
        [tweetsPerDayPlot release];
        [someDataSet release];
    }
    else if ([visualizationTypeSegmentedControl selectedSegmentIndex] == HVCVisualizationTypeScatterPlot) {
        PBPlot *tweetsPerHourPerDayScatterPlot=[[PBPlot alloc] initWithFrame:CGRectMake(0, 0, 1005, 550) andDataSets:[NSArray arrayWithObjects:someDataSet, nil]];
        
        //Set the limits and ticks intervals
        [tweetsPerHourPerDayScatterPlot setXAxisUpperBound:90060 andLowerBound:0];
        [tweetsPerHourPerDayScatterPlot setYAxisUpperBound:8 andLowerBound:0];
        [tweetsPerHourPerDayScatterPlot setMajorTicksWithXInterval:3752.5 andYInterval:1];
        
        //Set the titles
        [tweetsPerHourPerDayScatterPlot setXAxisTitle:@"Hora"];
        [tweetsPerHourPerDayScatterPlot setYAxisTitle:@"Día de la Semana"];
        [tweetsPerHourPerDayScatterPlot setGraphTitle:[someDataSet dataSetTitle]];
        
        //Show the grids and custom ticks
        [tweetsPerHourPerDayScatterPlot showGrids];
        [tweetsPerHourPerDayScatterPlot setXTicksLabels:[NSArray arrayWithObjects:HOURS_ARRAY, nil]];
        [tweetsPerHourPerDayScatterPlot setYTicksLabels:[NSArray arrayWithObjects:DAYS, nil] withRotation:M_PI_2];
        [tweetsPerHourPerDayScatterPlot setViewIsRestricted:YES];
        
        //Allow user interactions
        [[[tweetsPerHourPerDayScatterPlot graph] defaultPlotSpace] setAllowsUserInteraction:YES];
        
        // Do any additional setup after loading the view.
        [[self visualizationSpace] addSubview:tweetsPerHourPerDayScatterPlot];
        [tweetsPerHourPerDayScatterPlot release];
        [someDataSet release];
    }
    else if ([visualizationTypeSegmentedControl selectedSegmentIndex] == HVCVisualizationTypeBarPlot){
        PBBar *tweetsPerMonth=[[PBBar alloc] initWithFrame:CGRectMake(0, 0, 1005, 550) andDataSets:[NSArray arrayWithObjects:someDataSet, nil]];
        
        //Titles
        [tweetsPerMonth setXAxisTitle:@"Mes"];
        [tweetsPerMonth setYAxisTitle:@"Número de Tweets"];
        [tweetsPerMonth setGraphTitle:[someDataSet dataSetTitle]];
        
        //Plot attributes
        [tweetsPerMonth setAxisTight];
        [tweetsPerMonth showGrids];
        
        // Do any additional setup after loading the view.
        [[self visualizationSpace] addSubview:tweetsPerMonth];
        [tweetsPerMonth release];
        [someDataSet release];
    }
    
}

-(void)numberOfTweetsSliderValueChanged:(UISlider *)slider{
    NSInteger newValue=0;
    [numberOfTweetsSlider setValue:fixedSliderValue([slider value])];
    newValue=(NSInteger)fixedSliderValue([slider value]);
    
    [numberOfTweetsLabel setText:[NSString stringWithFormat:@"%d", newValue]];
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

-(void)downloadTweets{
    [subjectOfAnalysis requestMostRecentTweets:[[numberOfTweetsLabel text] intValue] withHandler:^{
        
        //Go to the main thread and perform the GUI changes, here comes the magic ... 
        [self performSelectorOnMainThread:@selector(segmentedControllSelected:) withObject:nil waitUntilDone:YES];
    }];
}

#pragma mark - General Actions
-(void)loadUser:(PBTUser *)someUser{
    
    if (subjectOfAnalysis != nil) {
        [subjectOfAnalysis release];
    }
    subjectOfAnalysis=[someUser retain];
    
    if ([subjectOfAnalysis realName] != nil) {
        
        //Although we already have an image, retrieve a bigger size, original has the best chance of being the biggest
        [subjectOfAnalysis requestProfilePictureWithSize:TAImageSizeOriginal andHandler:^{
            //Load the view
            [subjectOfAnalysisView performSelectorOnMainThread:@selector(loadUser:) withObject:subjectOfAnalysis waitUntilDone:YES];
            
            [subjectOfAnalysis requestMostRecentTweets:[[numberOfTweetsLabel text] intValue] withHandler:^{
                
                //Go to the main thread and perform the GUI changes
                [self performSelectorOnMainThread:@selector(drawScatterPlotOfTweetsPerHourPerDay) withObject:nil waitUntilDone:YES];
            }];
        }];
    }
    else {
        [subjectOfAnalysis requestUserData:^{
            
            #ifdef DEBUG
            NSLog(@"The real name is %@, annoyingly tweeted %d", [subjectOfAnalysis realName], [subjectOfAnalysis tweetCount]);
            NSLog(@"Has %d followers and %d friends", [subjectOfAnalysis followers], [subjectOfAnalysis following]);
            NSLog(@"The URL is: %@", [subjectOfAnalysis bioURL]);
            NSLog(@"The location is: %@", [subjectOfAnalysis location]);
            NSLog(@"The bio is: %@", [subjectOfAnalysis description]);
            #endif
            
            //Load the view
            [subjectOfAnalysisView performSelectorOnMainThread:@selector(loadUser:) withObject:subjectOfAnalysis waitUntilDone:YES];
            
            [subjectOfAnalysis requestMostRecentTweets:[[numberOfTweetsLabel text] intValue] withHandler:^{
                
                //Go to the main thread and perform the GUI changes
                [self performSelectorOnMainThread:@selector(drawPlotOfTweetsPerDay) withObject:nil waitUntilDone:YES];
            }];
        }];
    }
}

-(void)drawPlotOfTweetsPerDay{
    PBDataSet *someDataSet=[[subjectOfAnalysis dataSetOfTweetsPerCalendarUnit:NSDayCalendarUnit] retain];
    [someDataSet setSymbol:[PBUtilities symbolWithType:CPTPlotSymbolTypeHexagon size:5 andColor:[CPTColor blackColor]]];
    
    if ([[visualizationSpace subviews] count] != 0) {
        [[[visualizationSpace subviews] objectAtIndex:[[visualizationSpace subviews] count] - 1] removeFromSuperview];
    }
    
    PBPlot *tweetsPerDayPlot=[[PBPlot alloc] initWithFrame:CGRectMake(0, 0, 1005, 550) andDataSets:[NSArray arrayWithObjects:someDataSet, nil]];
    
    //Titles
    [tweetsPerDayPlot setXAxisTitle:@"Día"];
    [tweetsPerDayPlot setYAxisTitle:@"Número de Tweets"];
    [tweetsPerDayPlot setGraphTitle:[someDataSet dataSetTitle]];
    
    //Plot attributes
    [tweetsPerDayPlot setAxisTight];
    [tweetsPerDayPlot showGrids];
    
    // Do any additional setup after loading the view.
    [[self visualizationSpace] addSubview:tweetsPerDayPlot];
    [someDataSet release];
}

-(void)drawPlotOfTweetsPerWeek{
    PBDataSet *someDataSet=[[subjectOfAnalysis dataSetOfTweetsPerCalendarUnit:NSWeekCalendarUnit] retain];
    [someDataSet setSymbol:[PBUtilities symbolWithType:CPTPlotSymbolTypeHexagon size:5 andColor:[CPTColor blackColor]]];
    [someDataSet setFillingColor:[CPTColor darkGrayColor]];
    
    if ([[visualizationSpace subviews] count] != 0) {
        [[[visualizationSpace subviews] objectAtIndex:[[visualizationSpace subviews] count] - 1] removeFromSuperview];
    }
    
    PBBar *tweetsPerWeek=[[PBBar alloc] initWithFrame:CGRectMake(0, 0, 1005, 550) andDataSets:[NSArray arrayWithObjects:someDataSet, nil]];
    
    //Titles
    [tweetsPerWeek setXAxisTitle:@"Semana"];
    [tweetsPerWeek setYAxisTitle:@"Número de Tweets"];
    [tweetsPerWeek setGraphTitle:[someDataSet dataSetTitle]];
    
    //Plot attributes
    [tweetsPerWeek setAxisTight];
    [tweetsPerWeek showGrids];
    
    // Do any additional setup after loading the view.
    [[self visualizationSpace] addSubview:tweetsPerWeek];
    [someDataSet release];
}

-(void)drawPlotOfTweetsPerMonth{
    PBDataSet *someDataSet=[[subjectOfAnalysis dataSetOfTweetsPerCalendarUnit:NSMonthCalendarUnit] retain];
    [someDataSet setSymbol:[PBUtilities symbolWithType:CPTPlotSymbolTypeStar size:5 andColor:[CPTColor blackColor]]];
    
    if ([[visualizationSpace subviews] count] != 0) {
        [[[visualizationSpace subviews] objectAtIndex:[[visualizationSpace subviews] count] - 1] removeFromSuperview];
    }
    
    PBBar *tweetsPerMonth=[[PBBar alloc] initWithFrame:CGRectMake(0, 0, 1005, 550) andDataSets:[NSArray arrayWithObjects:someDataSet, nil]];
    
    //Titles
    [tweetsPerMonth setXAxisTitle:@"Mes"];
    [tweetsPerMonth setYAxisTitle:@"Número de Tweets"];
    [tweetsPerMonth setGraphTitle:[someDataSet dataSetTitle]];
    
    //Plot attributes
    [tweetsPerMonth setAxisTight];
    [tweetsPerMonth showGrids];
    
    // Do any additional setup after loading the view.
    [[self visualizationSpace] addSubview:tweetsPerMonth];
    [someDataSet release];
}

-(void)drawScatterPlotOfTweetsPerHourPerDay{
    PBDataSet *someDataSet=[[subjectOfAnalysis dataSetOfTweetsForHourPerDay] retain];
    
    if ([[visualizationSpace subviews] count] != 0) {
        [[[visualizationSpace subviews] objectAtIndex:[[visualizationSpace subviews] count] - 1] removeFromSuperview];
    }
    
    PBPlot *tweetsPerHourPerDayScatterPlot=[[PBPlot alloc] initWithFrame:CGRectMake(0, 0, 1005, 550) andDataSets:[NSArray arrayWithObjects:someDataSet, nil]];
    
    //Set the limits and ticks intervals
    [tweetsPerHourPerDayScatterPlot setXAxisUpperBound:90060 andLowerBound:0];
    [tweetsPerHourPerDayScatterPlot setYAxisUpperBound:8 andLowerBound:0];
    [tweetsPerHourPerDayScatterPlot setMajorTicksWithXInterval:3752.5 andYInterval:1];
    
    //Set the titles
    [tweetsPerHourPerDayScatterPlot setXAxisTitle:@"Hora"];
    [tweetsPerHourPerDayScatterPlot setYAxisTitle:@"Día de la Semana"];
    [tweetsPerHourPerDayScatterPlot setGraphTitle:[someDataSet dataSetTitle]];

    //Show the grids and custom ticks
    [tweetsPerHourPerDayScatterPlot showGrids];
    [tweetsPerHourPerDayScatterPlot setXTicksLabels:[NSArray arrayWithObjects:HOURS_ARRAY, nil]];
    [tweetsPerHourPerDayScatterPlot setYTicksLabels:[NSArray arrayWithObjects:DAYS, nil] withRotation:M_PI_2];
    [tweetsPerHourPerDayScatterPlot setViewIsRestricted:YES];
    
    //Allow user interactions
    [[[tweetsPerHourPerDayScatterPlot graph] defaultPlotSpace] setAllowsUserInteraction:YES];
    
    // Do any additional setup after loading the view.
    [[self visualizationSpace] addSubview:tweetsPerHourPerDayScatterPlot];

    [someDataSet release];
}

float fixedSliderValue(float sliderValue){
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

@end
