//
//  PBXYVisualization.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 13/05/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBXYVisualization.h"

@implementation PBXYVisualization

@synthesize graph;
@synthesize xAxisTitle, yAxisTitle;
@synthesize viewIsRestricted;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //Create and allocate the graph, it will be re-sized as needed
        graph=[[CPTXYGraph alloc] initWithFrame:CGRectZero];
        viewIsRestricted=NO;
    }
    return self;
}

-(void)dealloc{
    [graph release];
    
    //It's possible or not for this properties to be allocated
    if (xAxisTitle != nil) {
        [xAxisTitle release];
    }
    if (yAxisTitle != nil) {
        [yAxisTitle release];
    }
    
    
    [super dealloc];
}

#pragma mark - Titles For The Axes and Graph
-(void)setGraphTitle:(NSString *)title withStyle:(CPTTextStyle *)textStyle{
    //    //Because this is a custom setter, it has to be this way
    //    if (graphTitle != nil) {
    //        [graphTitle release];
    //    }
    //[self setGraphTitle:title];
    
    //If you don't add the offset it will look weird
    [graph setTitle:title];
    [graph setTitleTextStyle:textStyle];
    [graph setTitleDisplacement:CGPointMake(0, (-0.7)*[textStyle fontSize])];
    
    //Add a little of padding in the plotAreaFrame so that the title can fit
    [[graph plotAreaFrame] setPaddingTop:8+[textStyle fontSize]];
}

-(void)setGraphTitle:(NSString *)title{
    //Default style
    [self setGraphTitle:title withStyle:[PBUtilities textStyleWithFont:@"Helvetica" color:[CPTColor lightGrayColor] andSize:20.0]];
}

-(void)setXAxisTitle:(NSString *)title withStyle:(CPTMutableTextStyle *)textStyle{
    //Because this is a custom setter, it has to be this way
    if (xAxisTitle != nil) {
        [xAxisTitle release];
    }
    xAxisTitle=[title retain];
    
    //Begin the creation of the axes
    CPTXYAxisSet *axisSet=(CPTXYAxisSet *)[graph axisSet];
    CPTXYAxis *xAxis=[axisSet xAxis];
    
    //Y axis title
    [xAxis setTitle:xAxisTitle];
    [xAxis setTitleTextStyle:textStyle];
    
    //Add a little of padding in the plotAreaFrame so that the title can fit
    [[graph plotAreaFrame] setPaddingBottom:[textStyle fontSize]*kPBBottomPadding];
}

-(void)setXAxisTitle:(NSString *)title{
    [self setXAxisTitle:title withStyle:[PBUtilities textStyleWithFont:@"Helvetica" color:[CPTColor grayColor] andSize:20]];
}

-(void)setYAxisTitle:(NSString *)title withStyle:(CPTMutableTextStyle *)textStyle{
    //Because this is a custom setter, it has to be this way
    if (yAxisTitle != nil) {
        [yAxisTitle release];
    }
    yAxisTitle=[title retain];
    
    //Begin the creation of the axes
    CPTXYAxisSet *axisSet=(CPTXYAxisSet *)[graph axisSet];
    CPTXYAxis *yAxis=[axisSet yAxis];
    
    //Y axis title
    [yAxis setTitle:yAxisTitle];
    [yAxis setTitleTextStyle:textStyle];
    
    //Add a little of padding in the plotAreaFrame so that the title can fit
    [[graph plotAreaFrame] setPaddingLeft:[textStyle fontSize]*kPBLeftPadding];
}

-(void)setYAxisTitle:(NSString *)title{
    [self setYAxisTitle:title withStyle:[PBUtilities textStyleWithFont:@"Helvetica" color:[CPTColor grayColor] andSize:20.0]];
}

#pragma mark - Grids
-(void)showGrids{
    //Get the axes' axisSet property
    CPTXYAxisSet *axisSet=(CPTXYAxisSet *)[graph axisSet];
    CPTXYAxis *yAxis=[axisSet yAxis];
    CPTXYAxis *xAxis=[axisSet xAxis];
    
    //Avoid overhead, create this objects once
    CPTColor *grayColor=[[CPTColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];
    CPTLineStyle *gridLineStyle=[PBUtilities lineStyleWithWidth:0.75 andColor:grayColor];
    
    //Y axis gird lines
    [yAxis setMajorGridLineStyle:gridLineStyle];
    [yAxis setMinorGridLineStyle:gridLineStyle];
    [yAxis setTickDirection:CPTSignNone];
    
    //X axis gird lines
    [xAxis setMajorGridLineStyle:gridLineStyle];
    [xAxis setMinorGridLineStyle:gridLineStyle];
    [xAxis setTickDirection:CPTSignNone];
}

#pragma mark - Ticks
-(void)setMajorTicksWithXInterval:(float)xInterval andYInterval:(float)yInterval{
    //Begin the creation of the axes
    CPTXYAxisSet *axisSet=(CPTXYAxisSet *)[graph axisSet];
    
    //Y axis
    CPTXYAxis *yAxis=[axisSet yAxis];
    [yAxis setMajorIntervalLength:CPTDecimalFromFloat(yInterval)];
    [yAxis setMinorTicksPerInterval:0];
    [yAxis setOrthogonalCoordinateDecimal:CPTDecimalFromString(PBPlotAxisOrthogonal)];
    
    //Y ticks label style
    [yAxis setLabelTextStyle:[PBUtilities textStyleWithFont:@"Helvetica" andColor:[CPTColor grayColor]]];
    [yAxis setLabelFormatter:[PBUtilities formatterWithMaximumFractionDigits:1]];
    
    //X axis
    CPTXYAxis *xAxis=[axisSet xAxis];
    [xAxis setMajorIntervalLength:CPTDecimalFromFloat(xInterval)];
    [xAxis setOrthogonalCoordinateDecimal:CPTDecimalFromString(PBPlotAxisOrthogonal)];
    [xAxis setMinorTicksPerInterval:0];
    
    //X ticks label style
    [xAxis setLabelTextStyle:[PBUtilities textStyleWithFont:@"Helvetica" andColor:[CPTColor grayColor]]];        
    [xAxis setLabelFormatter:[PBUtilities formatterWithMaximumFractionDigits:1]];
    
}

-(void)setXTicksLabels:(NSArray *)labels withRotation:(float)rotation{
    int i=0;
    NSMutableArray *newAxisLabels=[[NSMutableArray alloc] init];
    NSMutableSet *tickLocations=[[NSMutableSet alloc] init];
    CPTAxisLabel *newLabel=nil;
    
    //Keep the current appearance by retrieving these properties
    CPTXYPlotSpace *plotSpace=(CPTXYPlotSpace *)[graph defaultPlotSpace];
    CPTXYAxisSet *axisSet=(CPTXYAxisSet *)[graph axisSet];
    CPTXYAxis *xAxis=[axisSet xAxis];
    CPTTextStyle *currentStyle=[xAxis labelTextStyle];
    
    //Avoid the over-head of repeating this calculations for each iteration
    float majorTickInterval=CPTDecimalFloatValue([xAxis majorIntervalLength]);
    CGFloat tickLabelOffset=[xAxis labelOffset]+[xAxis majorTickLength]/2.0;
    
    //The use of the ranges help us calculate how many ticks are visible in the scrreen
    float rangeLocation=CPTDecimalFloatValue([[plotSpace xRange] location]);
    float rangeLength=CPTDecimalFloatValue([[plotSpace xRange] length]);
    int visibleTicks=(int)floor((rangeLength / majorTickInterval));
    
    #ifdef DEBUG
    NSLog(@"There are %d visible ticks for the X axis", visibleTicks);
    #endif
    
    //Just be careful and let the programmer know if he screwed something
    if ([labels count] < visibleTicks) {
        [NSException raise:@"PBXYVisualization" format:@"You provided %d X ticks labels, the method needs %d", [labels count], visibleTicks];
    }
    
    //Go through every of the visible ticks and add the custom label provided
    for(i=0; i< visibleTicks; i++){
        //Add the locations of the ticks, otherwise you will loose all the lines and grids
        [tickLocations addObject:[NSDecimalNumber numberWithFloat:rangeLocation + (i * majorTickInterval)]];
        
        newLabel=[[CPTAxisLabel alloc] initWithText:[labels objectAtIndex:i] textStyle:currentStyle];
        [newLabel setTickLocation:CPTDecimalFromFloat(rangeLocation + (i * majorTickInterval))];
        [newLabel setOffset:tickLabelOffset];
        [newLabel setRotation:rotation];
        [newAxisLabels addObject:newLabel];
        [newLabel release];
    }
    //If you don't set the policy to none, you won't be able to see your custom labels
    [xAxis setLabelingPolicy:CPTAxisLabelingPolicyNone];
    
    //Add the ticks locations, otherwise no girds will be shown
    [xAxis setMajorTickLocations:tickLocations];
    [tickLocations release];
    
    //Add the labels and manage your memory
    [xAxis setAxisLabels:[NSSet setWithArray:newAxisLabels]];
    [newAxisLabels release];
}

-(void)setYTicksLabels:(NSArray *)labels withRotation:(float)rotation{
    int i=0;
    NSMutableArray *newAxisLabels=[[NSMutableArray alloc] init];
    NSMutableSet *tickLocations=[[NSMutableSet alloc] init];
    CPTAxisLabel *newLabel=nil;
    
    //Keep the current appearance by retrieving these properties
    CPTXYPlotSpace *plotSpace=(CPTXYPlotSpace *)[graph defaultPlotSpace];
    CPTXYAxisSet *axisSet=(CPTXYAxisSet *)[graph axisSet];
    CPTXYAxis *yAxis=[axisSet yAxis];
    CPTTextStyle *currentStyle=[yAxis labelTextStyle];
    
    //Avoid the over-head of repeating this calculations for each iteration
    float majorTickInterval=CPTDecimalFloatValue([yAxis majorIntervalLength]);
    CGFloat tickLabelOffset=[yAxis labelOffset]+[yAxis majorTickLength]/2.0;
    
    //This numbers will help us calculate how many ticks are visible currently in the screen
    float rangeLocation=CPTDecimalFloatValue([[plotSpace yRange] location]);
    float rangeLength=CPTDecimalFloatValue([[plotSpace yRange] length]);
    int visibleTicks=(int)floor((rangeLength / majorTickInterval));
    
    #ifdef DEBUG
    NSLog(@"There are %d visible ticks for the Y axis", visibleTicks);
    #endif
    
    //Just be careful and let the programmer know if he screwed something
    if ([labels count] < visibleTicks) {
        [NSException raise:@"PBXYVisualization" format:@"You provided %d X ticks labels, the method needs %d", [labels count], visibleTicks];
    }
    
    //Go through every of the visible ticks and add the custom label provided
    for(i=0; i<=visibleTicks; i++){
        //Add the locations of the ticks, otherwise you will loose all the lines and grids
        [tickLocations addObject:[NSDecimalNumber numberWithFloat:rangeLocation + (i * majorTickInterval)]];
        
        newLabel=[[CPTAxisLabel alloc] initWithText:[labels objectAtIndex:i] textStyle:currentStyle];
        [newLabel setTickLocation:CPTDecimalFromFloat(rangeLocation + (i * majorTickInterval))];
        [newLabel setOffset:tickLabelOffset];
        [newLabel setRotation:rotation];
        [newAxisLabels addObject:newLabel];
        [newLabel release];
    }
    
    //If you don't set the policy to none, you won't be able to see your custom labels
    [yAxis setLabelingPolicy:CPTAxisLabelingPolicyNone];
    
    //Add the ticks locations, otherwise no girds will be shown
    [yAxis setMajorTickLocations:tickLocations];
    [tickLocations release];
    
    //Add the labels and manage your memory
    [yAxis setAxisLabels:[NSSet setWithArray:newAxisLabels]];
    [newAxisLabels release];
}

-(void)setXTicksLabels:(NSArray *)xLabels withXRotation:(float)xRotation yTicksLabels:(NSArray *)yLabels withYRotation:(float)yRotation{
    [self setXTicksLabels:xLabels withRotation:xRotation];
    [self setYTicksLabels:yLabels withRotation:yRotation];
}

-(void)setXTicksLabels:(NSArray *)labels{
    [self setXTicksLabels:labels withRotation:0];
}

-(void)setYTicksLabels:(NSArray *)labels{
    [self setYTicksLabels:labels withRotation:0];
}   

-(void)setXTicksLabels:(NSArray *)xLabels andYTicksLabels:(NSArray *)yLabels{
    [self setXTicksLabels:xLabels withXRotation:0 yTicksLabels:yLabels withYRotation:0];
}

#pragma mark - Axes Range
-(void)setAxisTight{
    [self setAxisWithRangeFactor:1.0];
}

-(void)setAxisWithRangeFactor:(double)ratio{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)[graph defaultPlotSpace];
    [plotSpace scaleToFitPlots:plotSprites];
    
    //You need to make a mutable copy, otherwise, you won't be able to scale the plot    
    CPTMutablePlotRange *xRange=[[[plotSpace xRange] mutableCopy] autorelease];
    CPTMutablePlotRange *yRange=[[[plotSpace yRange] mutableCopy] autorelease];
    
    //Expand the plot with the ratio
    [xRange expandRangeByFactor:CPTDecimalFromDouble(ratio)];
    [yRange expandRangeByFactor:CPTDecimalFromDouble(ratio)];
    
    //Set it 
    [plotSpace setXRange:xRange];
    [plotSpace setYRange:yRange];
}

-(void)setXAxisUpperBound:(float)upper andLowerBound:(float)lower{
    //Retrieve the plotspace and cast it 
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)[graph defaultPlotSpace];
    
    //Create a new one    
    CPTPlotRange *xRange=[[CPTPlotRange alloc] initWithLocation:CPTDecimalFromFloat(lower) length:CPTDecimalFromFloat(upper-lower)];
    
    //Set the new range to the plot space
    [plotSpace setXRange:xRange];
    
    //Restrict the range of the graph to the one provided
    if (viewIsRestricted) {
        [plotSpace setGlobalXRange:xRange];
    }
    
    [xRange release];
}

-(void)setYAxisUpperBound:(float)upper andLowerBound:(float)lower{
    //Retrieve the plotspace and cast it 
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)[graph defaultPlotSpace];
    
    //Create a new one    
    CPTPlotRange *yRange=[[CPTPlotRange alloc] initWithLocation:CPTDecimalFromFloat(lower) length:CPTDecimalFromFloat(upper-lower)];
    
    //Set the new range to the plot space
    [plotSpace setYRange:yRange];
    
    //Restrict the range of the graph to the one provided
    if (viewIsRestricted) {
        [plotSpace setGlobalYRange:yRange];
    }
    
    [yRange release];
}

#pragma mark - Legends 
-(void)showLegends{
    //Add the legend and position it the right way
    [graph setLegend:[CPTLegend legendWithGraph:graph]];
    
    //Styling for the legends
    [[graph legend] setTextStyle:[PBUtilities textStyleWithFont:@"Helvetica" andColor:[CPTColor whiteColor]]];
    [[graph legend] setFill:[CPTFill fillWithColor:[CPTColor darkGrayColor]]];
    [[graph legend] setBorderLineStyle:[PBUtilities lineStyleWithWidth:1 andColor:[CPTColor whiteColor]]];
    [[graph legend] setNumberOfColumns:1];
    
    [graph setLegendAnchor:CPTRectAnchorTopRight];
    [graph setLegendDisplacement:CGPointMake(-15, -10)];
}

@end
