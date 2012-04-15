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

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setTitle:@"Statwittstics"];        

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

    
}

-(void)dealloc{
    [mainPlot release];
    [mainUserView release];
    
    [super dealloc];
}

-(void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return YES;
}

@end
