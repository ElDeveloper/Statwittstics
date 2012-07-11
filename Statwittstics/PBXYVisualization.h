//
//  PBXYVisualization.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 13/05/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBVisualization.h"

#import "PBDefines.h"
#import "PBDataSet.h"
#import "PBUtilities.h"

@interface PBXYVisualization : PBVisualization <CPTPlotSpaceDelegate>{
    CPTXYGraph *graph;
    
    NSString *xAxisTitle;
    NSString *yAxisTitle;
    
    BOOL viewIsRestricted;

    @private CPTPlotRange *defaultXRange;
    @private CPTPlotRange *defaultYRange;
}

@property(nonatomic, retain)CPTXYGraph *graph;

//Basic descriptors of the graph
@property (nonatomic, retain) NSString *xAxisTitle;
@property (nonatomic, retain) NSString *yAxisTitle;

//Allows to set the global-range to the provided by the bounds, this property
//must be set prior to setting the X an Y ranges, to ensure consistency
@property (nonatomic, assign) BOOL viewIsRestricted;

//Allows to keep track of the ranges, when restricted 
@property (nonatomic, retain) CPTPlotRange *defaultXRange;
@property (nonatomic, retain) CPTPlotRange *defaultYRange;

/*
 MATLAB-like methods to set certain properties with just one line of code
 this is not as dynamic an capable as the original implementation of Core-Plot
 but if you really want that much freedom, then just use Core-Plot.
 */

//Titles for the graph with a personlized style or just the default Helvetica
-(void)setGraphTitle:(NSString *)title withStyle:(CPTTextStyle *)textStyle;
-(void)setGraphTitle:(NSString *)title;

//Titles for the graph with a personlized style or just the default Helvetica
-(void)setXAxisTitle:(NSString *)title withStyle:(CPTTextStyle *)textStyle;
-(void)setXAxisTitle:(NSString *)title;
-(void)setYAxisTitle:(NSString *)title withStyle:(CPTTextStyle *)textStyle;
-(void)setYAxisTitle:(NSString *)title;

//Grids of the graph
-(void)showGrids;

//By default this hides the minor ticks, only showing the major ticks, this will affect the grids
-(void)setMajorTicksWithXInterval:(float)xInterval;
-(void)setMajorTicksWithYInterval:(float)yInterval;
-(void)setMajorTicksWithXInterval:(float)xInterval andYInterval:(float)yInterval;

//Set the labels of the visible ticks in the current plot space, the call to these methods is 
//usually after the bounds for the axes have been set, so as the intervals for the axes
//by default the labels are parallel to the axis for X and perpendicular to the axis for Y.
-(void)setXTicksLabels:(NSArray *)labels; 
-(void)setYTicksLabels:(NSArray *)labels; 
-(void)setXTicksLabels:(NSArray *)xLabels andYTicksLabels:(NSArray *)yLabels;

//Set the labels for the visible ticks in the screen, and set the rotation that you want for each
//of the labels, the call to these methods is usually after the bounds for the axes have been set.
-(void)setXTicksLabels:(NSArray *)labels withRotation:(float)rotation; 
-(void)setYTicksLabels:(NSArray *)labels withRotation:(float)rotation;
-(void)setXTicksLabels:(NSArray *)xLabels withXRotation:(float)xRotation yTicksLabels:(NSArray *)yLabels withYRotation:(float)yRotation;

//Bounds for both axes, automatic or by as specified by the user
-(void)setAxisTight;
-(void)setAxisWithRangeFactor:(double)ratio;

//Specify the visible region of your current plot
-(void)setXAxisUpperBound:(float)upper andLowerBound:(float)lower;
-(void)setYAxisUpperBound:(float)upper andLowerBound:(float)lower;

//Legends of the graph
-(void)showLegends;

@end
