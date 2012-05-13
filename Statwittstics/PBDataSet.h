//
//  PBDataSet.h
//  CoreGraph
//
//  Created by Yoshiki - Vázquez Baeza on 28/03/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBDefines.h"

@interface PBDataSet : NSObject{
    NSString *dataSetTitle;

    NSArray *dataPointsX;
    NSArray *dataPointsY;
    NSUInteger dataSetLength;
    
    CPTColor *lineColor;
    CPTColor *fillingColor;
    
    CPTPlotSymbol *symbol;
}

-(id)initWithXData:(NSArray *)xData yData:(NSArray *)yData andTitle:(NSString *)title;

//Similar to the PlotIdentifier
@property (nonatomic, retain) NSString *dataSetTitle;

//Data sources
@property (nonatomic, retain) NSArray *dataPointsX;
@property (nonatomic, retain) NSArray *dataPointsY;
@property (nonatomic, assign) NSUInteger dataSetLength;

//Different attributes to set for each plot
@property (nonatomic, retain) CPTColor *lineColor;
@property (nonatomic, retain) CPTColor *fillingColor;
@property (nonatomic, retain) CPTPlotSymbol *symbol;

@end
