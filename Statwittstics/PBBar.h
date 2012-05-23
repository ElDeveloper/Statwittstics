//
//  PBBar.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 12/05/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBXYVisualization.h"
#import "PBDataSet.h"
#import "PBUtilities.h"

@protocol PBBarDelegate;

@interface PBBar : PBXYVisualization<CPTPlotDataSource, CPTBarPlotDelegate>{
    id <PBBarDelegate> delegate;
}

@property(assign) id<PBBarDelegate> delegate;

-(id)initWithFrame:(CGRect)frame andDataSets:(NSArray *)theDataSets;

@end

/*
 This optional delegate should be used if:
 + You would like to add any extra customizations to the plot.
 + You would like to respond to the interaction callbacks.
 */
@protocol PBBarDelegate <NSObject>

@optional
-(void)additionalCustomizationsForPBBar;
-(void)didSelectIndex:(NSUInteger)index ofDataSet:(PBDataSet *)dataSet;

@end