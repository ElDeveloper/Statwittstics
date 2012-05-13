//
//  PBVisualization.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 12/05/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBDefines.h"

@interface PBVisualization : UIView{
    NSMutableString *graphTitle;
    NSMutableArray *dataSets;
    BOOL viewIsRestricted;
    
    NSMutableArray *identifiers;
    NSMutableArray *plotSprites;
}

//Basic descriptors of the graph
@property (nonatomic, retain) NSMutableString *graphTitle;
@property (nonatomic, retain) NSMutableArray *dataSets;

//Private properties helpers of the Data Source
@property (nonatomic, retain) NSMutableArray *plotSprites;
@property (nonatomic, retain) NSMutableArray *identifiers;
@property (nonatomic, assign) BOOL viewIsRestricted;

//General initializer
-(id)initWithFrame:(CGRect)frame;

@end
