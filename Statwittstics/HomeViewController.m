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
        
        //1024 x 768
        mainPlot=nil;
    
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
        NSArray *array=[NSArray arrayWithObjects:@"yosmark", nil];
        
        for (NSString *plel in array) {
            mainUser=[[PBTUser alloc] initWithUsername:plel andAuthorizedAccount:theAccount];
            [mainUser requestUserData:^{
                
                #ifdef DEBUG
                NSLog(@"The real name is %@, annoyingly tweeted %d", [mainUser realName], [mainUser tweetCount]);
                NSLog(@"Has %d followers and %d friends", [mainUser followers], [mainUser following]);
                NSLog(@"The URL is: %@", [mainUser bioURL]);
                NSLog(@"The location is: %@", [mainUser location]);
                NSLog(@"The bio is: %@", [mainUser description]);
                #endif
                
                //Load the view
                [mainUserView performSelectorOnMainThread:@selector(loadUser:) withObject:mainUser waitUntilDone:YES];
                
                [mainUser requestMostRecentTweets:300 withHandler:^{
                    NSLog(@"This has been called what up.");
                    
                    //Go to the main thread and perform the GUI changes
                    [self performSelectorOnMainThread:@selector(drawTweetsPerDayPlot) withObject:nil waitUntilDone:YES];
                    
                }];
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

#pragma mark - UIActionSheetDelegate Methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //Load a view controller ... if needed
    id viewController=nil;
    
    switch (buttonIndex) {
        case HVCActionSheetButtonNew:
            viewController=[[FindUserViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [[self navigationController] presentModalViewController:viewController animated:YES];
            [viewController release];
            
            [PBTUtilities user:mainUser requestUsersWithKeyword:@"yoshiki" andResponseHandler:^(NSArray *arrayOfSubjects) {
                NSLog(@"AWESOME_SAUCE");
            }];
            
            break;
        
        case HVCActionSheetButtonShare:
            
            break;
            
        default:
            break;
    }
    
    return;
}

#pragma mark - Plot Loading
-(void)drawTweetsPerDayPlot{
    PBDataSet *someDataSet=[mainUser tweetsPerDayDataSet];
    
    NSLog(@"The data set has %d", [someDataSet dataSetLength]);
    [someDataSet setSymbol:[PBUtilities symbolWithType:CPTPlotSymbolTypeHexagon size:12 andColor:[CPTColor blackColor]]];
    
    mainPlot=[[PBPlot alloc] initWithFrame:CGRectMake(9, 145, 1005, 550) andDataSets:[NSArray arrayWithObjects:someDataSet, nil]];
    
    //Plot attributes
    [mainPlot setAxisWithRangeFactor:1.3];
    [mainPlot showGrids];
    
    // Do any additional setup after loading the view.
    [[self view] addSubview:mainPlot];
}

@end
