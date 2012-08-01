//
//  PBVisualization.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 12/05/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBDefines.h"

#define kPBVisualizationAnimationDuration 0.70

typedef void __block (^PBVoidHandler)(void);

typedef enum {
    PBAnimationStyleFadeIn =  0,
    PBAnimationStyleExapand = 1 >> 1,
}PBAnimationStyle;

@interface PBVisualization : UIView{
    NSMutableString *graphTitle;
    NSMutableArray *dataSets;
    
    NSMutableArray *identifiers;
    NSMutableArray *plotSprites;
    
    float animationDuration;

    @protected NSTimer *dataSetsAnimationTimer;
    @protected NSUInteger dataSetsAnimationFrame;
    @protected BOOL dataSetsAnimationIsRunning;
}

//Basic descriptors of the graph
@property (nonatomic, retain) NSMutableString *graphTitle;
@property (nonatomic, retain) NSMutableArray *dataSets;

//Private properties helpers of the Data Source
@property (nonatomic, retain) NSMutableArray *plotSprites;
@property (nonatomic, retain) NSMutableArray *identifiers;

//Duration in seconds of the animation performAnimationWithStyle:andHandler:
@property (nonatomic, assign) float animationDuration;

@property (nonatomic, retain) NSTimer *dataSetsAnimationTimer;
@property (nonatomic, assign) NSUInteger dataSetsAnimationFrame;
@property (nonatomic, assign) BOOL dataSetsAnimationIsRunning;

//General initializer
-(id)initWithFrame:(CGRect)frame;

-(UIImage *)imageRepresentation;
-(void)performAnimationWithStyle:(PBAnimationStyle)style andHandler:(PBVoidHandler)handler;

@end
