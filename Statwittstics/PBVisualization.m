//
//  PBVisualization.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 12/05/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBVisualization.h"

@implementation PBVisualization

@synthesize dataSets, graphTitle, viewIsRestricted;
@synthesize identifiers, plotSprites;

-(id)initWithFrame:(CGRect)frame{
    if ( self = [super initWithFrame:frame]) {
        graphTitle=[[NSMutableString alloc] init];
        dataSets=[[NSMutableArray alloc] init];
        viewIsRestricted=NO;
        identifiers=[[NSMutableArray alloc] init];
        plotSprites=[[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc{
    [graphTitle release];
    [dataSets release];
    [identifiers release];
    [plotSprites release];
    
    [super dealloc];
}

@end
