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

//Similar to the PlotIdentifier
@property (nonatomic, retain) NSString *dataSetTitle;

//Data sources
@property (nonatomic, retain) NSArray *dataPointsX;
@property (nonatomic, retain) NSArray *dataPointsY;
@property (nonatomic, assign) NSUInteger dataSetLength;

//Different style attributes to set for each plot
@property (nonatomic, retain) CPTColor *lineColor;
@property (nonatomic, retain) CPTColor *fillingColor;

//Will only use this property if used with a scatter or line plot
@property (nonatomic, retain) CPTPlotSymbol *symbol;

-(id)initWithXData:(NSArray *)xData yData:(NSArray *)yData andTitle:(NSString *)title;

//Quick getters of probably common used values
-(NSNumber *)maximumXValue;
-(NSNumber *)minimumXValue;
-(NSNumber *)maximumYValue;
-(NSNumber *)minimumYValue;

@end
