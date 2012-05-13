//
//  PBBar.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 12/05/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBBar.h"

@implementation PBBar
@synthesize delegate, graph, xAxisTitle, yAxisTitle;

-(id)initWithFrame:(CGRect)frame andDataSets:(NSArray *)theDataSets{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        int i=0, sizeHelper=[[theDataSets objectAtIndex:0] dataSetLength];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [[self layer] setCornerRadius:12.0f];
        [[self layer] setMasksToBounds:YES];
        
        PBDataSet *currentDataSet=nil;
        delegate = nil;
        
        //Data Set intitialization needed remember to retain your data
        [dataSets addObjectsFromArray:theDataSets];
        //dataSets=[theDataSets copy];
        
        //Set the hosting view, in this case it won't be resizable
        CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [hostingView setBackgroundColor:[UIColor clearColor]];
        
        //Create and allocate the graph, it will be re-sized as needed
        graph=[[CPTXYGraph alloc] initWithFrame:CGRectZero];
        
        //The hosting view is the main holder for all the plot
        [hostingView setHostedGraph:graph];
        [hostingView setAutoresizingMask:UIViewAutoresizingNone];
        
        //Now that everything is set, begin the customization
        [self addSubview:hostingView];
        [hostingView release];
        
        //The theme will be default black
        [graph applyTheme:[CPTTheme themeNamed:kCPTStocksTheme]];
        
        //The plot uses all the hosting view space
        [graph setPaddingLeft:PBPlotPaddingNone];
        [graph setPaddingTop:PBPlotPaddingNone];
        [graph setPaddingBottom:PBPlotPaddingNone];
        [graph setPaddingRight:PBPlotPaddingNone];
        
        //Add a little padding to the right to make the last tick visible
        [[graph plotAreaFrame] setPaddingRight:2];
        [graph setLegendAnchor:CPTRectAnchorLeft];
        
        //Set default spaced ticks
        [self setMajorTicksWithXInterval:[PBUtilities ticksIntervalIn:PBXAxis dataSets:dataSets] 
                            andYInterval:[PBUtilities ticksIntervalIn:PBYAxis dataSets:dataSets]];
        
        //One score plot per Data Set, must solve this shit
        for (i=0; i<[dataSets count]; i++) {
            currentDataSet=[dataSets objectAtIndex:i];
            
            //Check for possible problems with the run-time, ALL THE PBDataSets should have the sime dataSetLength
            if ([currentDataSet dataSetLength] != sizeHelper) {
                [NSException raise:@"PBBar Exception" format:@"The size of the PBDataSets should be the same."];
            }
            else {
                sizeHelper=[currentDataSet dataSetLength];
            }
            
            CPTBarPlot *plotSprite=[[CPTBarPlot alloc] init];
            [plotSprite setDelegate:self];
            [plotSprite setDataSource:self];
            [plotSprite setBarBasesVary:NO];
            [plotSprite setBarsAreHorizontal:NO];
            [plotSprite setCornerRadius:0.9f];
            [plotSprite setBarWidth:CPTDecimalFromFloat(1.0f)];
            
            //The identifier of each of the scatter plots is the same as the data set
            //title, and is added to an array so it can be retrieved on the data-source
            //delegate method
            [plotSprite setIdentifier:[currentDataSet dataSetTitle]];
            [identifiers addObject:[currentDataSet dataSetTitle]];
            
            //The properties for the line, the color should be either the one that's been set or a default color
            [plotSprite setLineStyle:[PBUtilities lineStyleWithWidth:3.0 andColor:[PBUtilities defaultLineColorForDataSet:currentDataSet atIndex:i]]];
            [plotSprite setFill:[PBUtilities fillWithGradient:[currentDataSet fillingColor]]];
            
            [graph addPlot:plotSprite];
            [plotSprites addObject:plotSprite];
            [plotSprite release];
        }
        
        //Customizations protocol
        if ([[self delegate] respondsToSelector:@selector(additionalCustomizationsForPBPlot)]) {
            [delegate additionalCustomizationsForPBBar];
        }
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
        [NSException raise:@"PBPLot" format:@"You provided %d X ticks labels, the method needs %d", [labels count], visibleTicks];
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
        [NSException raise:@"PBPLot" format:@"You provided %d X ticks labels, the method needs %d", [labels count], visibleTicks];
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
    [xRange release];
}

-(void)setYAxisUpperBound:(float)upper andLowerBound:(float)lower{
    //Retrieve the plotspace and cast it 
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)[graph defaultPlotSpace];
    
    //Create a new one    
    CPTPlotRange *yRange=[[CPTPlotRange alloc] initWithLocation:CPTDecimalFromFloat(lower) length:CPTDecimalFromFloat(upper-lower)];
    
    //Set the new range to the plot space
    [plotSpace setYRange:yRange];
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

#pragma mark - CPTPlotDataSource
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot*)plot {
	return [[dataSets objectAtIndex:0] dataSetLength];
}

-(NSNumber*)numberForPlot:(CPTPlot*)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index{
    //The initializer added an identifier for each plot, get it and that's the index of the plot in the array
    NSString *plotIdentifier=[NSString stringWithString:(NSString *)[plot identifier]];
    int currentPlot=[identifiers indexOfObject:plotIdentifier];
    
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            return [[[dataSets objectAtIndex:currentPlot] dataPointsX] objectAtIndex:index];
            break;
            
        case CPTScatterPlotFieldY:
            return [[[dataSets objectAtIndex:currentPlot] dataPointsY] objectAtIndex:index];
            break;
            
        default:
            break;
    }
    
    //Should never be nil if so should crash
    return nil;
}

#pragma mark - CPTScatterPlotDelegate
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index{

}


@end
