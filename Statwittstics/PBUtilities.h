//
//  PBUtilities.h
//  CoreGraph
//
//  Created by Yoshiki - Vázquez Baeza on 03/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"
#import "PBDataSet.h"

#define PBPlotError(string) \
NSLog(@"PBPLotError:**%@",string)\

#define defaultCPTColors \
[CPTColor whiteColor], [CPTColor redColor], [CPTColor greenColor],\
[CPTColor cyanColor], [CPTColor purpleColor], [CPTColor orangeColor],\
[CPTColor yellowColor], [CPTColor blackColor]

typedef enum {
    PBSymbolEllipse=0,
    PBSymbolSnowFlake
}PBSymbolType;

@interface PBUtilities : NSObject

/*
 General helpers for the PBPlot class, mostly just to avoid repeating chunks of code
 */

//Get a formatter with the desired digits in the mantiza
+(NSNumberFormatter *)formatterWithMaximumFractionDigits:(NSUInteger)number;

//Get a font with the desired specifications
+(CPTTextStyle *)textStyleWithFont:(NSString*)fontName color:(CPTColor*)color andSize:(CGFloat)size;
+(CPTTextStyle *)textStyleWithFont:(NSString*)fontName andColor:(CPTColor *)color;

+(CPTColor *)defaultLineColorForDataSet:(PBDataSet *)dataSet atIndex:(NSUInteger)index;

//Get a line style with the desired specifications
+(CPTLineStyle *)lineStyleWithMiter:(double)limit width:(double)width andColor:(CPTColor*)color;
+(CPTLineStyle *)lineStyleWithWidth:(double)width andColor:(CPTColor*)color;

//Factory method using the CPTPlotSymbolType enumeration
+(CPTPlotSymbol *)symbolWithType:(CPTPlotSymbolType)type;

//Create default symbols
+(CPTPlotSymbol *)symbolWithType:(CPTPlotSymbolType)type size:(CGFloat)symbolSize lineStyle:(CPTLineStyle *)contourLineStyle andColor:(CPTColor *)symbolColor;
+(CPTPlotSymbol *)symbolWithType:(CPTPlotSymbolType)type size:(CGFloat)symbolSize andColor:(CPTColor *)symbolColor;
+(CPTPlotSymbol *)symbolWithType:(CPTPlotSymbolType)type andColor:(CPTColor *)symbolColor;

//By default fades away (ends in clear color)
+(CPTFill *)fillWithGradient:(CPTColor *)color;

@end
