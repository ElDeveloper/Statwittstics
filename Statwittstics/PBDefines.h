//
//  PBDefines.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 12/05/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#ifndef Statwittstics_PBDefines_h
#define Statwittstics_PBDefines_h

//The kit rely on the CorePlot framework
#import "CorePlot-CocoaTouch.h"

#import "PBConstants.h"

//Types of axis in a regular plot
typedef enum _PBAxis{
    PBXAxis=0,
    PBYAxis
}PBAxis;

#define PBError(string) NSLog(@"PBError:**%@",string)

#define defaultCPTColors \
[CPTColor whiteColor], [CPTColor redColor], [CPTColor greenColor],\
[CPTColor cyanColor], [CPTColor purpleColor], [CPTColor orangeColor],\
[CPTColor yellowColor], [CPTColor blackColor]

#endif
