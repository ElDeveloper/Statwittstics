//
//  PBPlot.h
//  CoreGraph
//
//  Created by Yoshiki - Vázquez Baeza on 26/03/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBDefines.h"

#import "PBXYVisualization.h"
#import "PBDataSet.h"
#import "PBUtilities.h"

/*
    TO DO:
    + Implement legends for the touch protocol.
 */

@protocol PBPlotDelegate;

@interface PBPlot : PBXYVisualization<CPTPlotDataSource, CPTScatterPlotDelegate>{
    id <PBPlotDelegate> delegate;
    @private PBVoidHandler _completionHandler;
}

@property (assign) id<PBPlotDelegate> delegate;

-(id)initWithFrame:(CGRect)frame andDataSets:(NSArray *)theDataSets;

-(void)loadPlotsFromArrayOfDataSets:(NSArray *)someDataSets;


-(void)beginDatPointsAnimationWithDuration:(float)seconds andCompletitionHandler:(PBVoidHandler)handler;

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