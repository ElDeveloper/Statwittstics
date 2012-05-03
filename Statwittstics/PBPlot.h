//
//  PBPlot.h
//  CoreGraph
//
//  Created by Yoshiki - Vázquez Baeza on 26/03/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"
#import "PBDataSet.h"
#import "PBUtilities.h"

/*
    TO DO:
    + Implement legends for the touch protocol.
    + Add functionality to the customizations protocol.
 */

//Constants used to adjust to the size of the title of each axis
extern CGFloat const kPBBottomPadding;
extern CGFloat const kPBLeftPadding;

extern CGFloat const PBPlotPaddingNone;
extern NSString * const PBPlotAxisOrthogonal;

typedef enum _PBPlotAxis{
    PBPlotXAxis=0,
    PBPlotYAxis
}PBPlotAxis;

@protocol PBPlotDelegate;

@interface PBPlot : UIView<CPTPlotDataSource, CPTScatterPlotDelegate>{
    id <PBPlotDelegate> delegate;
    CPTXYGraph *graph;
    NSArray *dataSets;
    NSString *graphTitle;
    NSString *xAxisTitle;
    NSString *yAxisTitle;
    
    @private NSMutableArray *identifiers;
    @private NSMutableArray *linePlots;
}

@property (assign) id<PBPlotDelegate> delegate;
@property (nonatomic, retain) CPTXYGraph *graph;
@property (nonatomic, retain) NSArray *dataSets;

//Basic descriptors of the graph
@property (nonatomic, retain) NSString *graphTitle;
@property (nonatomic, retain) NSString *xAxisTitle;
@property (nonatomic, retain) NSString *yAxisTitle;

//Private properties helpers of the Data Source
@property (nonatomic, retain) NSMutableArray *linePlots;
@property (nonatomic, retain) NSMutableArray *identifiers;

-(id)initWithFrame:(CGRect)frame andDataSets:(NSArray *)theDataSets;

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
-(void)setMajorTicksWithXInterval:(float)xInterval andYInterval:(float)yInterval;

-(void)setXTicksLabels:(NSArray *)labels; //Not working
-(void)setYTicksLabels:(NSArray *)labels; //Not working
-(void)setXTicksLabels:(NSArray *)xLabels andYTicksLabels:(NSArray *)yLabels; //Not working

//Bounds for both axes, automatic or by as specified by the user
-(void)setAxisTight;
-(void)setAxisWithRangeFactor:(double)ratio;

-(void)setXAxisUpperBound:(float)upper andLowerBound:(float)lower;
-(void)setYAxisUpperBound:(float)upper andLowerBound:(float)lower;

//Legends of the graph
-(void)showLegends;

//Determine the space between intervals to show in the plot, this should work more
//accurately than the default annotations, as it takes accound of the mantiza of 
//the ticks and the general appearance of the resulting plot
+(float)ticksIntervalIn:(PBPlotAxis)axisType dataSets:(NSArray *)dataSets;

@end

/*
 This optional delegate should be used if:
 + You would like to add any extra customizations to the plot.
 + You would like to respond to the interaction callbacks.
 */
@protocol PBPlotDelegate <NSObject>

@optional
-(void)additionalCustomizationsForPBPlot;
-(void)didSelectIndex:(NSUInteger)index ofDataSet:(PBDataSet *)dataSet;

@end