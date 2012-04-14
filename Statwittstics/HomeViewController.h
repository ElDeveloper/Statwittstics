//
//  HomeViewController.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 05/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatwittsticsDefines.h"
#import "PBKit.h"

@interface HomeViewController : UIViewController{
    IBOutlet PBPlot *mainPlot;

}

@property (nonatomic, retain) IBOutlet PBPlot *mainPlot;

@end
