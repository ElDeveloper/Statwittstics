//
//  PBVisualization.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 12/05/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBVisualization.h"

@implementation PBVisualization

@synthesize dataSets, graphTitle;
@synthesize identifiers, plotSprites;

-(id)initWithFrame:(CGRect)frame{
    if ( self = [super initWithFrame:frame]) {
        graphTitle=[[NSMutableString alloc] init];
        dataSets=[[NSMutableArray alloc] init];

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

@end
