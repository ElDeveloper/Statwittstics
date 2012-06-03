//
//  PBBar.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 12/05/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBBar.h"

@implementation PBBar
@synthesize delegate;

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
        
        //Set where the title should be found
        [graph setLegendAnchor:CPTRectAnchorLeft];
        
        //Set default spaced ticks
        [self setMajorTicksWithXInterval:floorf([PBUtilities ticksIntervalIn:PBXAxis dataSets:dataSets]) 
                            andYInterval:floorf([PBUtilities ticksIntervalIn:PBYAxis dataSets:dataSets])];
        
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
            
            [plotSprite setBarWidth:CPTDecimalFromFloat(1.0)];
            [plotSprite setBarOffset:CPTDecimalFromFloat(0.5)];
            
            //The identifier of each of the scatter plots is the same as the data set title, and
            //is added to an array so it can be retrieved on the data-source delegate method
            [plotSprite setIdentifier:[currentDataSet dataSetTitle]];
            [identifiers addObject:[currentDataSet dataSetTitle]];
            
            //The properties for the line, the color should be either the one that's been set or a default color
            [plotSprite setLineStyle:[PBUtilities lineStyleWithWidth:1.5 andColor:[PBUtilities defaultLineColorForDataSet:currentDataSet atIndex:i]]];
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
    NSLog(@"%s @ %s", __PRETTY_FUNCTION__, __FILE__);
}

@end
