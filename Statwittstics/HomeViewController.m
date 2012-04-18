//
//  HomeViewController.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 05/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "HomeViewController.h"

@implementation HomeViewController

@synthesize mainPlot;
@synthesize mainUser, mainUserView;
@synthesize optionsActionSheet;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setTitle:@"Statwittstics"];  
        
        optionsActionSheet=nil;
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

        /*
         Test data sets creation and inclusion to the main plot
         */
        NSMutableArray *xArray=[NSMutableArray arrayWithCapacity:32];
        NSMutableArray *yArray=[NSMutableArray arrayWithCapacity:32];
        NSMutableArray *x2=[NSMutableArray array];
        NSMutableArray *y2=[NSMutableArray array];
        
        //Simple data adding
        double myArray[6]={0, 1, 12, 4.3, 7.8, 30};//, 1, .5, 0, -.5, -1, -1.4, -2, -1.4, -1, -0.5, 0, 0.5, 1};
        double myOtherArray[6]={5, 21, 32, 18, 25, 36};//, 7, 6, 5, 4, 12, 4, 12, 4, 12, 4, 6, 5, 6};
        for (NSInteger i = 0; i < 6; i++) {        
            [xArray addObject:[NSNumber numberWithDouble:i]];
            [yArray addObject:[NSNumber numberWithDouble:myArray[i]]];
            
            [x2 addObject:[NSNumber numberWithDouble:i]];
            [y2 addObject:[NSNumber numberWithDouble:myOtherArray[i]]];
        }
        PBDataSet *sinDataSet=[[PBDataSet alloc] initWithXData:xArray yData:yArray andTitle:@"Sinusoidal 1"];
        [sinDataSet setLineColor:[CPTColor whiteColor]];
        [sinDataSet setSymbol:[PBUtilities symbolWithType:CPTPlotSymbolTypeEllipse andColor:[CPTColor yellowColor]]];
        
        PBDataSet *otherDataSet=[[PBDataSet alloc] initWithXData:x2 yData:y2 andTitle:@"Newsoidal 2"];
        [otherDataSet setSymbol:[PBUtilities symbolWithType:CPTPlotSymbolTypeHexagon andColor:[CPTColor greenColor]]]; 
        
        //1024 x 768
        mainPlot=[[PBPlot alloc] initWithFrame:CGRectMake(5, 70, 1005, 550) andDataSets:[NSArray arrayWithObjects:sinDataSet, otherDataSet, nil]];
        
        //Titles
        [mainPlot setGraphTitle:@"Señales"];
        [mainPlot setXAxisTitle:@"Tiempo"];
        [mainPlot setYAxisTitle:@"Amplitud"];
        
        //Plot attributes
        [mainPlot setAxisTight];
        [mainPlot showGrids];
        
        [sinDataSet release];
        [otherDataSet release];
        
        // Do any additional setup after loading the view.
        [[self view] addSubview:mainPlot];
    
        mainUserView=[[PBTUserView alloc] initWithUser:nil andPositon:CGPointMake(10, 10)];
        [[self view] addSubview:mainUserView];
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
        
        //Request the first twitter account available 
        NSArray *twitterAccounts=[astore accountsWithAccountType:twitterAccountType];
        ACAccount *theAccount=[twitterAccounts objectAtIndex:0];
        
        //Twitter test
        PBTUser *testUser=nil;
        NSArray *array=[NSArray arrayWithObjects:@"yosmark", nil];
        
        for (NSString *plel in array) {
            testUser=[[PBTUser alloc] initWithUsername:plel andAuthorizedAccount:theAccount];
            [testUser requestUserData:^{
                
                #ifdef DEBUG
                NSLog(@"The real name is %@, annoyingly tweeted %d", [testUser realName], [testUser tweetCount]);
                NSLog(@"Has %d followers and %d friends", [testUser followers], [testUser following]);
                NSLog(@"The URL is: %@", [testUser bioURL]);
                NSLog(@"The location is: %@", [testUser location]);
                NSLog(@"The bio is: %@", [testUser description]);
                #endif
                
                [mainUserView performSelectorOnMainThread:@selector(loadUser:) withObject:testUser waitUntilDone:YES];
                
                [testUser requestMostRecentTweets:10 withHandler:^{}];
            }];
            //[testUser release];
        }
    }];
    
}

-(void)dealloc{
    [mainPlot release];
    [mainUserView release];

    if (optionsActionSheet != nil) {
        [optionsActionSheet release];
    }
    
    [super dealloc];
}

-(void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{

    //Do not allow portrait, only landscape
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return NO;
    }
    
	return YES;
}

-(void)optionsButtonPressed:(id)sender{
    
    //Do not cause overhead, the user could probably not use the options therefore you would be creating an action sheet when not needed
    if ( optionsActionSheet == nil) {
        optionsActionSheet=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Options", @"Options String") 
                                                 delegate:self 
                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel String") 
                                   destructiveButtonTitle:NSLocalizedString(@"Hide", @"Hide String") 
                                        otherButtonTitles:NSLocalizedString(@"New Subject", @"New Subject String"), NSLocalizedString(@"Share on Twitter", @"Share on Twitter String"), nil];
    }
      
    if ( ![optionsActionSheet isVisible]) {
        [optionsActionSheet showFromBarButtonItem:[[self navigationItem] rightBarButtonItem] animated:YES];
    }
    else {
        //Hide it using the "Hide button"
        [optionsActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    }
}

-(void)aboutButtonPressed:(id)sender{
    NSLog(@"About button pressed");
    
    AboutViewController *viewController=[[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    [[self navigationController] presentModalViewController:viewController animated:YES];
    [viewController release];
    
}


@end
