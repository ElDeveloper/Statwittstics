//
//  PBDataSet.m
//  CoreGraph
//
//  Created by Yoshiki - Vázquez Baeza on 28/03/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBDataSet.h"

@implementation PBDataSet

@synthesize dataSetTitle;
@synthesize dataPointsX, dataPointsY, dataSetLength;
@synthesize lineColor, fillingColor;
@synthesize symbol;

-(id)initWithXData:(NSArray *)xData yData:(NSArray *)yData andTitle:(NSString *)title{
    if (self = [super init]) {
        
        //The title for the graph, name for the data set
        dataSetTitle=[title retain];
        
        //Retain the data yourself
        dataPointsX=[xData retain];
        dataPointsY=[yData retain];
        
        //Check for sizes and if necessary advise the user
        if ([dataPointsX count] != [dataPointsY count]) {
            [NSException raise:@"PBDatSet" format:@"The dataPointsX and the dataPointsY properties should be of equal size."];
        }
        
        //Once it has been initialized
        dataSetLength=[dataPointsX count];
        
        //Default colors will be assigned by the PBPlot
        lineColor=nil;
        symbol=nil;
        
        //PBPlot's default behaviour is to set a gradient from a color
        //to clear, so if the filling color is set to clear, there will
        //be no color under the line
        [self setFillingColor:[CPTColor clearColor]];
    }
    return self;
}

-(void)dealloc{
    [dataSetTitle release];
    [dataPointsX release];
    [dataPointsY release];
    [fillingColor release];
    
    //The following two are optional, so
    //check if these were indeed assigned
    if (lineColor != nil) {
        [lineColor release];
    }
    
    if (symbol != nil){
        [symbol release];
    }
    
    [super dealloc];
}

@end