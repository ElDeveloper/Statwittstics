//
//  HomeViewController.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 05/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatwittsticsDefines.h"
#import "PBTKit.h"
#import "PBKit.h"

@interface HomeViewController : UIViewController{
    PBPlot *mainPlot;
    PBTUser *mainUser;
    PBTUserView *mainUserView;
}

//Main plot of the user to analyze
@property (nonatomic, retain) PBPlot *mainPlot;

//The user to analyze (model and view)
@property (nonatomic, retain) PBTUser *mainUser;
@property (nonatomic, retain) PBTUserView *mainUserView;

@end
