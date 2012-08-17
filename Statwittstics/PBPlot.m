//
//  PBPlot.m
//  CoreGraph
//
//  Created by Yoshiki - Vázquez Baeza on 26/03/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBPlot.h"

@interface PBPlot (DataPointAnimation)

@property (nonatomic, retain) PBVoidHandler _completionHandler;

-(void)dataSetsAnimationTimerCallback:(NSTimer *)someTimer;

@end

@implementation PBPlot (DataPointAnimation)

@dynamic _completionHandler;

-(void)dataSetsAnimationTimerCallback:(NSTimer *)someTimer{
    //http://code.google.com/p/core-plot/source/browse/examples/CorePlotGallery/src/plots/RealTimePlot.m

    #ifdef DEBUG
    NSLog(@"PBPlot:**On timer callback, dataset size is %d", [[[someTimer userInfo] objectAtIndex:0] dataSetLength]);
    #endif
    
    //When the timer reaches it's last call, reset everything, the last call is
    //as defined by the length plus one given the way the array cropping is made
    if (dataSetsAnimationFrame == ([[[someTimer userInfo] objectAtIndex:0] dataSetLength] + 1)) {
        [dataSetsAnimationTimer invalidate];
        [dataSetsAnimationTimer release];
        dataSetsAnimationTimer=nil;
        
        dataSetsAnimationIsRunning=NO;
        dataSetsAnimationFrame=0;
        
        //Run the handler and release the memory
        _completionHandler();
        [_completionHandler release];
    }
    else {
        //Crop all the arrays to the new length
        NSMutableArray *resizedDataSets=[NSMutableArray arrayWithArray:[PBDataSet cropArrayOfDataSets:[[self dataSetsAnimationTimer] userInfo] 
                                                                                            withRange:NSMakeRange(0, dataSetsAnimationFrame)]];
        [self loadPlotsFromArrayOfDataSets:resizedDataSets];
        
        dataSetsAnimationFrame=dataSetsAnimationFrame+1;
    }
}

@end

@implementation PBPlot

@synthesize delegate;

#pragma mark - ViewLifecycle

-(id)initWithFrame:(CGRect)frame andDataSets:(NSArray *)theDataSets{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //int i=0, sizeHelper=[[theDataSets objectAtIndex:0] dataSetLength];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [[self layer] setCornerRadius:12.0f];
        [[self layer] setMasksToBounds:YES];
        
        //PBDataSet *currentDataSet=nil;
        delegate=nil;
        
        //Set the hosting view, in this case it won't be resizable
        CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [hostingView setBackgroundColor:[UIColor clearColor]];
        
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
        
        //Set the place where the titel should be
        [graph setLegendAnchor:CPTRectAnchorLeft];
        
        //Load the pltos
        [self loadPlotsFromArrayOfDataSets:theDataSets];
        
        //Set default spaced ticks
        [self setMajorTicksWithXInterval:floorf([PBUtilities ticksIntervalIn:PBXAxis dataSets:dataSets]) 
                            andYInterval:floorf([PBUtilities ticksIntervalIn:PBYAxis dataSets:dataSets])];
        
        //Customizations protocol
        if ([[self delegate] respondsToSelector:@selector(additionalCustomizationsForPBPlot)]) {
            [delegate additionalCustomizationsForPBPlot];
        }
    }
    return self;
}

-(void)dealloc{

    [super dealloc];
}

-(void)loadPlotsFromArrayOfDataSets:(NSArray *)someDataSets{
    int i=0, sizeHelper=-1;
    PBDataSet *currentDataSet=nil;
    CPTScatterPlot *scatterPlot=nil;
    
    if ([dataSets count] != 0) {
        [dataSets removeAllObjects];
    }
        
    [dataSets addObjectsFromArray:someDataSets];

    //Check if you have to remove some of the plots that are already there this
    //should usually only be executed posterior to the initialization 
    if ([identifiers count] != 0 || [plotSprites count] != 0) {
        for (id identifier in identifiers) {
            [graph removePlotWithIdentifier:identifier];
        }
        
        [identifiers removeAllObjects];
        [plotSprites removeAllObjects];
    }
    
    //One score plot per Data Set, must solve this shit
    for (i=0; i<[dataSets count]; i++) {
        currentDataSet=[dataSets objectAtIndex:i];
        
        //All the PBDataSets should have the sime dataSetLength
        if ([currentDataSet dataSetLength] != sizeHelper && i != 0) {
            [NSException raise:@"PBPlot Exception" format:@"The size of the PBDataSets should be the same."];
        }
        sizeHelper=[currentDataSet dataSetLength];
        
        scatterPlot=[[CPTScatterPlot alloc] init];
        [scatterPlot setDelegate:self];
        [scatterPlot setDataSource:self];
        
        //The identifier of each of the scatter plots is the same as the dataset
        //title, and is added to an array so it can be retrieved on the 
        //data-source delegate method
        [scatterPlot setIdentifier:[currentDataSet dataSetTitle]];
        [identifiers addObject:[currentDataSet dataSetTitle]];
        
        //The properties for the line, the color should be either the one that's been set or a default color
        [scatterPlot setDataLineStyle:[PBUtilities lineStyleWithWidth:3.0 andColor:[PBUtilities defaultLineColorForDataSet:currentDataSet atIndex:i]]];
        [scatterPlot setAreaFill:[PBUtilities fillWithGradient:[currentDataSet fillingColor]]];
        
        //If there is a symbol for the plot add it, else ignore the property
        if ([currentDataSet symbol] != nil) {
            [scatterPlot setPlotSymbol:[currentDataSet symbol]];
        }
        
        [scatterPlot setAreaBaseValue:[[NSDecimalNumber zero] decimalValue]];
        
        [graph addPlot:scatterPlot];
        [plotSprites addObject:scatterPlot];
        [scatterPlot release];
    }
}

-(void)beginDatPointsAnimationWithDuration:(float)seconds andCompletitionHandler:(PBVoidHandler)handler{
    float intervalDuration=seconds/[[[self dataSets] objectAtIndex:0] dataSetLength];
    
    //Only start one timer at the time, don't allow simultaneous timers
    if (dataSetsAnimationIsRunning == NO) {
        if (dataSetsAnimationTimer == nil) {
            dataSetsAnimationFrame=0;
            
            //We have to own a copy of this block to call it later
            _completionHandler = [handler copy];
            
            // This timer will iterate through the callback that reloads data
            dataSetsAnimationTimer = [[NSTimer timerWithTimeInterval:intervalDuration 
                                                                target:self
                                                              selector:@selector(dataSetsAnimationTimerCallback:)
                                                              userInfo:[[[self dataSets] copy] autorelease]
                                                               repeats:YES] retain];
            dataSetsAnimationIsRunning=YES;
            [[NSRunLoop mainRunLoop] addTimer:dataSetsAnimationTimer forMode:NSDefaultRunLoopMode];
        }
    }
    else {
        NSLog(@"PBPlot:WARNING:**dataSetsAnimation is already running can't re-run.");
    }
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
