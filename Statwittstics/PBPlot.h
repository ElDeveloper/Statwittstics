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
    + Create a method that returns a default annotation.
    + Implement legends for the touch protocol.
    + Add functionality to the customizations protocol.
 */

//Constants used to adjust to the size of the title of each axis
extern CGFloat      const   kPBBottomPadding;
extern CGFloat      const   kPBLeftPadding;

extern CGFloat      const   PBPlotPaddingNone;
extern NSString *   const   PBPlotAxisOrthogonal;

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
    
    @private
    NSMutableArray *identifiers;
    NSMutableArray *linePlots;
}

@property (assign) id<PBPlotDelegate> delegate;

@property (nonatomic, retain) CPTXYGraph *graph;
@property (nonatomic, retain) NSArray *dataSets;

@property (nonatomic, retain) NSString *graphTitle;
@property (nonatomic, retain) NSString *xAxisTitle;
@property (nonatomic, retain) NSString *yAxisTitle;

@property (nonatomic, retain) NSMutableArray *linePlots;
@property (nonatomic, retain) NSMutableArray *identifiers;

-(id)initWithFrame:(CGRect)frame andDataSets:(NSArray *)theDataSets;

/*
 MATLAB-like methods to set certain properties with just one line of code
 */
-(void)setAxisTight;
-(void)setAxisWithRangeFactor:(double)ratio;

-(void)showLegends;
-(void)showGrids;

-(void)setGraphTitle:(NSString *)title withStyle:(CPTTextStyle *)textStyle;
-(void)setGraphTitle:(NSString *)title;

-(void)setXAxisTitle:(NSString *)title withStyle:(CPTTextStyle *)textStyle;
-(void)setXAxisTitle:(NSString *)title;

-(void)setYAxisTitle:(NSString *)title withStyle:(CPTTextStyle *)textStyle;
-(void)setYAxisTitle:(NSString *)title;

//Determine the space between intervals to show in the plot, this should work more
//accurately than the default annotations, as it takes accound of the mantiza of 
//the ticks and the general appearance of the resulting plot
+(NSDecimal)ticksIntervalIn:(PBPlotAxis)axisType dataSets:(NSArray *)dataSets;
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