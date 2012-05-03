//
//  PBPlot.m
//  CoreGraph
//
//  Created by Yoshiki - Vázquez Baeza on 26/03/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBPlot.h"

CGFloat const kPBBottomPadding=2.7;
CGFloat const kPBLeftPadding=2.7;

CGFloat const PBPlotPaddingNone=0.0;
NSString * const PBPlotAxisOrthogonal=@"0.0";

@implementation PBPlot

@synthesize delegate, graph, dataSets;
@synthesize graphTitle, xAxisTitle, yAxisTitle, linePlots;
@synthesize identifiers;

#pragma mark - ViewLifecycle

- (id)initWithFrame:(CGRect)frame andDataSets:(NSArray *)theDataSets{
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
        dataSets=[theDataSets copy];
        
        linePlots=[[NSMutableArray alloc] init];
        identifiers=[[NSMutableArray alloc] init];
        
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
        
        //By default do not allow the user interaction
        [[graph defaultPlotSpace] setAllowsUserInteraction:NO];
        
        //Set default spaced ticks
        [self setMajorTicksWithXInterval:[PBPlot ticksIntervalIn:PBPlotXAxis dataSets:dataSets] andYInterval:[PBPlot ticksIntervalIn:PBPlotYAxis dataSets:dataSets]];
        
        //One score plot per Data Set, must solve this shit
        for (i=0; i<[dataSets count]; i++) {
            currentDataSet=[dataSets objectAtIndex:i];
            
            //Check for possible problems with the run-time, ALL THE PBDataSets should have the sime dataSetLength
            if ([currentDataSet dataSetLength] != sizeHelper) {
                [NSException raise:@"PBPlot Exception" format:@"The size of the PBDataSets should be the same."];
            }
            else {
                sizeHelper=[currentDataSet dataSetLength];
            }
            
            CPTScatterPlot *scorePlot=[[CPTScatterPlot alloc] init];
            [scorePlot setDelegate:self];
            [scorePlot setDataSource:self];
            
            //The identifier of each of the scatter plots is the same as the data set
            //title, and is added to an array so it can be retrieved on the data-source
            //delegate method
            [scorePlot setIdentifier:[currentDataSet dataSetTitle]];
            [identifiers addObject:[currentDataSet dataSetTitle]];
            
            //The properties for the line, the color should be either the one that's been set or a default color
            [scorePlot setDataLineStyle:[PBUtilities lineStyleWithWidth:3.0 andColor:[PBUtilities defaultLineColorForDataSet:currentDataSet atIndex:i]]];
            [scorePlot setAreaFill:[PBUtilities fillWithGradient:[currentDataSet fillingColor]]];
            
            //If there is a symbol for the plot add it, else ignore the property
            if ([currentDataSet symbol] != nil) {
                [scorePlot setPlotSymbol:[currentDataSet symbol]];
            }
            
            [scorePlot setAreaBaseValue:[[NSDecimalNumber zero] decimalValue]];
            
            [graph addPlot:scorePlot];
            [linePlots addObject:scorePlot];
            [scorePlot release];
        }
        
        //Customizations protocol
        if ([[self delegate] respondsToSelector:@selector(additionalCustomizationsForPBPlot)]) {
            [delegate additionalCustomizationsForPBPlot];
        }
    }
    return self;
}

-(void)dealloc{
    [graph release];
    [dataSets release];
    [linePlots release];
    [identifiers release];
    
    //It's possible or not for this properties to be allocated
    if (xAxisTitle != nil) {
        [xAxisTitle release];
    }
    if (yAxisTitle != nil) {
        [yAxisTitle release];
    }
    if (graphTitle != nil){
        [graphTitle release];
    }
    
    [super dealloc];
}

#pragma mark - Titles For The Axes and Graph
-(void)setGraphTitle:(NSString *)title withStyle:(CPTTextStyle *)textStyle{
    //Because this is a custom setter, it has to be this way
    if (graphTitle != nil) {
        [graphTitle release];
    }
    graphTitle=[title retain];
    
    //If you don't add the offset it will look weird
    [graph setTitle:graphTitle];
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
    
    //Now store the axes in the graph
    [[graph axisSet] setAxes:[NSArray arrayWithObjects:xAxis, yAxis, nil]];
}

#pragma mark - Axes Range
-(void)setAxisTight{
    [self setAxisWithRangeFactor:1.0];
}

-(void)setAxisWithRangeFactor:(double)ratio{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)[graph defaultPlotSpace];
    [plotSpace scaleToFitPlots:linePlots];
    
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

#pragma mark - PBPlotHelpers
+(float)ticksIntervalIn:(PBPlotAxis)axisType dataSets:(NSArray *)dataSets{
    float minValue=0, maxValue=0, tmin=0, tmax=0, intervalSize=0;
    int values[4]={12, 10, 8, 6}, i=0, numberOfTicks=0, position=0;
    
    //Go through each of the data sets, determine the maximum and minimum values
    for (PBDataSet *currentDataSet in dataSets) {
        switch (axisType) {
            case PBPlotXAxis:
                tmin=[[[currentDataSet dataPointsX] valueForKeyPath:@"@min.floatValue"] floatValue];
                tmax=[[[currentDataSet dataPointsX] valueForKeyPath:@"@max.floatValue"] floatValue];
                break;
            case PBPlotYAxis:
                tmin=[[[currentDataSet dataPointsY] valueForKeyPath:@"@min.floatValue"] floatValue];
                tmax=[[[currentDataSet dataPointsY] valueForKeyPath:@"@max.floatValue"] floatValue];
                break;
            default:
                break;
        }
        
        //Then determine the maximum and minimum values among all the data-sets
        if (minValue > tmin) {
            minValue=tmin;
        }
        if (maxValue < tmax) {
            maxValue=tmax;
        }
    }
    
    //Both values of the same sign, modulus maxima difference
    if ( (minValue <= 0 && maxValue <= 0) || (maxValue >= 0 && minValue >= 0) ) {
        intervalSize=fabsf(maxValue) - fabsf(minValue);
    }
    //Regular difference
    else {
        intervalSize=maxValue-minValue;
    }
    
    numberOfTicks=((int)intervalSize)%values[0];
    position=0;
    for (i=0 ; i<4 ; i++) {
        if (  numberOfTicks > ((int)intervalSize)%values[i] ) {
            numberOfTicks=((int)intervalSize)%values[i];
            position=i;
        }
    }
    
    #ifdef DEBUG
    NSLog(@"PBPlot**: min:%f max:%f",minValue, maxValue);
    #endif
    return (intervalSize/values[position]);
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
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index{
    //If there is a custom behaviour, then do not present your behaviour, that is just rude :P
    if ([delegate respondsToSelector:@selector(didSelectIndex:ofDataSet:)]) {
        [[self delegate] didSelectIndex:index ofDataSet:nil];
        return;
    }
    
    static CPTPlotSpaceAnnotation *symbolTextAnnotation;
    
    CPTXYGraph *annotationGraph = graph;
    
	if ( symbolTextAnnotation ) {
		[annotationGraph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
		[symbolTextAnnotation release];
		symbolTextAnnotation=nil;
	}
    
	// Setup a style for the annotation
	CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
	hitAnnotationTextStyle.color=[CPTColor whiteColor];
	hitAnnotationTextStyle.fontSize=16.0f;
	hitAnnotationTextStyle.fontName=@"Helvetica-Bold";
    
	// Determine point of symbol in plot coordinates
	NSNumber *x=[[[dataSets objectAtIndex:0] dataPointsX] objectAtIndex:index];
	NSNumber *y=[[[dataSets objectAtIndex:0] dataPointsY] objectAtIndex:index];
	NSArray *anchorPoint=[NSArray arrayWithObjects:x, y, nil];
    
	// Add annotation
	// First make a string for the y value
	NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
	[formatter setMaximumFractionDigits:2];
	NSString *yString = [formatter stringFromNumber:y];
    
	// Now add the annotation to the plot area
	CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle];
	symbolTextAnnotation=[[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:annotationGraph.defaultPlotSpace anchorPlotPoint:anchorPoint];
	symbolTextAnnotation.contentLayer=textLayer;
    [textLayer release];
	symbolTextAnnotation.displacement=CGPointMake(0.0f, 20.0f);
    
    NSLog(@"Dude wtf x: %f and y: %f",symbolTextAnnotation.contentAnchorPoint.x, symbolTextAnnotation.contentAnchorPoint.y);
    
	[annotationGraph.plotAreaFrame.plotArea addAnnotation:symbolTextAnnotation];
}

@end
