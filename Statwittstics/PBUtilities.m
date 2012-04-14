//
//  PBUtilities.m
//  CoreGraph
//
//  Created by Yoshiki - Vázquez Baeza on 03/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBUtilities.h"

@implementation PBUtilities

#pragma mark - GeneralHelpers
+(NSNumberFormatter *)formatterWithMaximumFractionDigits:(NSUInteger)number{
    NSNumberFormatter* xFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [xFormatter setMaximumFractionDigits:number];
    return xFormatter;
}

#pragma mark - CPMutableTextStyleHelper
+(CPTTextStyle *)textStyleWithFont:(NSString*)fontName color:(CPTColor*)color andSize:(CGFloat)size {
	CPTMutableTextStyle *textStyle = (CPTMutableTextStyle *)[PBUtilities textStyleWithFont:fontName andColor:color];
	[textStyle setFontSize:size];
	return (CPTTextStyle *)textStyle;
}

+(CPTTextStyle *)textStyleWithFont:(NSString*)fontName andColor:(CPTColor *)color {
	CPTMutableTextStyle *textStyle = [[[CPTMutableTextStyle alloc] init] autorelease];
	[textStyle setFontName:fontName];
	[textStyle setColor:color];
	return (CPTTextStyle *)textStyle;
}

#pragma mark - CPTLineStyleHelpers
+(CPTColor *)defaultLineColorForDataSet:(PBDataSet *)dataSet atIndex:(NSUInteger)index{
    //The array should work for various calls
    static NSArray *colorsArray;
    static int colorsArraySize;
    
    //On the first call initialize it
    if (colorsArray == nil) {
        colorsArray=[NSArray arrayWithObjects:defaultCPTColors, nil];
        colorsArraySize=[colorsArray count];
    }
    
    //If the data set has no current color, set a default color
    if ([dataSet lineColor] == nil) {
        return [colorsArray objectAtIndex:index%colorsArraySize];
    }
    else {
        return [dataSet lineColor];
    }
    
    return nil;
}

+(CPTLineStyle *)lineStyleWithMiter:(double)limit width:(double)width andColor:(CPTColor*)color {
    CPTMutableLineStyle* lineStyle = [[[CPTMutableLineStyle alloc] init] autorelease];
    [lineStyle setMiterLimit:limit];
    [lineStyle setLineWidth:width];
    [lineStyle setLineColor:color];
    return lineStyle;
}

+(CPTLineStyle *)lineStyleWithWidth:(double)width andColor:(CPTColor*)color {
    //The default value will be 2.0
    return [PBUtilities lineStyleWithMiter:1.0 width:width andColor:color];
}

+(CPTPlotSymbol *)symbolWithType:(CPTPlotSymbolType)type{
    switch (type) {
        case CPTPlotSymbolTypeRectangle:
            return [CPTPlotSymbol rectanglePlotSymbol];
            break;
        case CPTPlotSymbolTypeEllipse:
            return [CPTPlotSymbol ellipsePlotSymbol];
            break;
        case CPTPlotSymbolTypeDiamond:
            return [CPTPlotSymbol diamondPlotSymbol];
            break;
        case CPTPlotSymbolTypeTriangle:
            return [CPTPlotSymbol trianglePlotSymbol];
            break;
        case CPTPlotSymbolTypeStar:
            return [CPTPlotSymbol starPlotSymbol];
            break;
        case CPTPlotSymbolTypePentagon:
            return [CPTPlotSymbol pentagonPlotSymbol];
            break;
        case CPTPlotSymbolTypeHexagon:
            return [CPTPlotSymbol hexagonPlotSymbol];
            break;
        case CPTPlotSymbolTypeCross:
            return [CPTPlotSymbol crossPlotSymbol];
            break;
        case CPTPlotSymbolTypePlus:
            return [CPTPlotSymbol plusPlotSymbol];
            break;
        case CPTPlotSymbolTypeDash:
            return [CPTPlotSymbol dashPlotSymbol];
            break;
        case CPTPlotSymbolTypeSnow:
            return [CPTPlotSymbol snowPlotSymbol];
            break;
        default:
            [NSException raise:@"PBUtilities Exception" format:@"Incorrect CPTPlotSymbolType provided."];
            break;
    }
    
  return nil;
}

+(CPTPlotSymbol *)symbolWithType:(CPTPlotSymbolType)type size:(CGFloat)symbolSize lineStyle:(CPTLineStyle *)contourLineStyle andColor:(CPTColor *)symbolColor{
    CPTPlotSymbol *plotSymbol=[PBUtilities symbolWithType:type];
    
    [plotSymbol setFill:[CPTFill fillWithColor:symbolColor]];
    [plotSymbol setLineStyle:contourLineStyle];
    [plotSymbol setSize:CGSizeMake(symbolSize, symbolSize)];
    
    return plotSymbol;
}

+(CPTPlotSymbol *)symbolWithType:(CPTPlotSymbolType)type size:(CGFloat)symbolSize andColor:(CPTColor *)symbolColor{
    CPTLineStyle *lineStyle=[PBUtilities lineStyleWithWidth:0.3 andColor:symbolColor];
    
    return [PBUtilities symbolWithType:type size:symbolSize lineStyle:lineStyle andColor:symbolColor];
}

+(CPTPlotSymbol *)symbolWithType:(CPTPlotSymbolType)type andColor:(CPTColor *)symbolColor{
    return [PBUtilities symbolWithType:type size:8 andColor:symbolColor];
}

+(CPTFill *)fillWithGradient:(CPTColor *)color {
	CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:color endingColor:[CPTColor clearColor]];
	return [CPTFill fillWithGradient:areaGradient];
}

@end
