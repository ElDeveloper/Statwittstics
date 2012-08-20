//
//  PBVisualization.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 12/05/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBVisualization.h"

#import "PBDataSet.h"

@interface PBVisualization (DataPointAnimation)

-(void)dataSetsAnimationTimerCallback:(NSTimer *)someTimer;

@end

@implementation PBVisualization (DataPointAnimation)

-(void)dataSetsAnimationTimerCallback:(NSTimer *)someTimer{
    //http://code.google.com/p/core-plot/source/browse/examples/CorePlotGallery/src/plots/RealTimePlot.m
    
    #ifdef DEBUG
    NSLog(@"PBVisualization:**On NSTimer callback, dataset size is %d", [[[someTimer userInfo] objectAtIndex:0] dataSetLength]);
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

@implementation PBVisualization

@synthesize dataSets, graphTitle;
@synthesize identifiers, plotSprites;
@synthesize animationDuration;
@synthesize dataSetsAnimationTimer, dataSetsAnimationFrame, dataSetsAnimationIsRunning;

-(id)initWithFrame:(CGRect)frame{
    if ( self = [super initWithFrame:frame]) {
        graphTitle=[[NSMutableString alloc] init];
        dataSets=[[NSMutableArray alloc] init];

        identifiers=[[NSMutableArray alloc] init];
        plotSprites=[[NSMutableArray alloc] init];
        
        animationDuration=kPBVisualizationAnimationDuration;
        
        dataSetsAnimationTimer=nil;
        dataSetsAnimationFrame=0;
        dataSetsAnimationIsRunning=NO;
    }
    return self;
}

-(void)dealloc{
    [graphTitle release];
    [dataSets release];
    [identifiers release];
    [plotSprites release];
    
    if (dataSetsAnimationTimer != nil) {
        [dataSetsAnimationTimer  invalidate];
        [dataSetsAnimationTimer release];
    }   
    
    [super dealloc];
}

-(void)loadPlotsFromArrayOfDataSets:(NSArray *)someDataSets{
}

-(UIImage *)imageRepresentation{
    
    //Create a context with the qualities of the class
    UIGraphicsBeginImageContextWithOptions(self.frame.size, self.opaque, 0.0);
    
    //Render the view in the context
    [[self layer] renderInContext:UIGraphicsGetCurrentContext()];
    
    //Create an image from the context
    UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
    
    //Close the context as it is no longer needed
    UIGraphicsEndImageContext();
    
    return theImage;
}

-(void)performAnimationWithStyle:(PBAnimationStyle)style andHandler:(PBVoidHandler)handler{
    CGPoint preAnimationCenter=[self center];
    
    if ((style & PBAnimationStyleExapand) == PBAnimationStyleExapand) {
        [self setTransform:CGAffineTransformScale([self transform], 0.1, 0.1)];
    }
    if ((style & PBAnimationStyleFadeIn) == PBAnimationStyleFadeIn) {
        [self setAlpha:0.1];
    }
    
    [self setCenter:preAnimationCenter];
    
    [UIView animateWithDuration:[self animationDuration] animations:^{
                            if ((style & PBAnimationStyleExapand) == PBAnimationStyleExapand) {
                                [self setTransform:CGAffineTransformScale([self transform], 10, 10)];
                            }
                            if ((style & PBAnimationStyleFadeIn) == PBAnimationStyleFadeIn) {
                                [self setAlpha:1.0];
                            }
                        } 
                     completion:^(BOOL finished){
                            handler();
                        }];
}

-(void)beginDataPointsAnimationWithDuration:(float)seconds andCompletionHandler:(PBVoidHandler)handler{
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
        NSLog(@"PBVisualization:WARNING:**beginDatPointsAnimationWithDuration:andCompletionHandler: is already running can't re-run.");
    }
}

@end
