//
//  PBDataSet.m
//  CoreGraph
//
//  Created by Yoshiki - Vázquez Baeza on 28/03/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBDataSet.h"

// NSCoder suppor keys
NSString * const kPBDataSetDataPointsX=@"PBDataSetDataPointsX";
NSString * const kPBDataSetDataPointsY=@"PBDataSetDataPointsY";
NSString * const kPBDataSetTitle=@"PBDataSetTitle";
NSString * const kPBDataSetLength=@"PBDataSetLength";
NSString * const kPBDataSetLineColor=@"PBDataSetLineColor";
NSString * const kPBDataSetFillingColor=@"PBDataSetFillingColor";
NSString * const kPBDataSetSymbol=@"PBDataSetSymbol";

@implementation PBDataSet

@synthesize dataSetTitle;
@synthesize dataPointsX, dataPointsY, dataSetLength;
@synthesize lineColor, fillingColor;
@synthesize symbol;

-(id)initWithXData:(NSArray *)xData yData:(NSArray *)yData andTitle:(NSString *)title{
    if (self = [super init]) {
        
        //The title for the graph, name for the data set
        dataSetTitle=[title retain];
        
        //Retain the data yourself
        dataPointsX=[xData retain];
        dataPointsY=[yData retain];
        
        //Check for sizes and if necessary advise the user
        if ([dataPointsX count] != [dataPointsY count]) {
            [NSException raise:@"PBDatSet" format:@"The dataPointsX and the dataPointsY properties should be of equal size."];
        }
        
        //Once it has been initialized
        dataSetLength=[dataPointsX count];
        
        //Default colors will be assigned by the PBPlot
        lineColor=nil;
        symbol=nil;
        
        //PBPlot's default behaviour is to set a gradient from a color
        //to clear, so if the filling color is set to clear, there will
        //be no color under the line
        [self setFillingColor:[CPTColor clearColor]];
    }
    return self;
}

-(void)dealloc{
    [dataSetTitle release];
    [dataPointsX release];
    [dataPointsY release];
    [fillingColor release];
    
    //The following two are optional, so
    //check if these were indeed assigned
    if (lineColor != nil) {
        [lineColor release];
    }
    
    if (symbol != nil){
        [symbol release];
    }
    
    [super dealloc];
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:dataPointsX forKey:kPBDataSetDataPointsX];
    [aCoder encodeObject:dataPointsY forKey:kPBDataSetDataPointsY];
    [aCoder encodeObject:dataSetTitle forKey:kPBDataSetTitle];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:dataSetLength] forKey:kPBDataSetLength];
    [aCoder encodeObject:lineColor forKey:kPBDataSetLineColor];
    [aCoder encodeObject:fillingColor forKey:kPBDataSetFillingColor];
    [aCoder encodeObject:symbol forKey:kPBDataSetSymbol];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        [self setDataSetTitle:[aDecoder decodeObjectForKey:kPBDataSetTitle]];
        [self setDataPointsX:[aDecoder decodeObjectForKey:kPBDataSetDataPointsX]];
        [self setDataPointsY:[aDecoder decodeObjectForKey:kPBDataSetDataPointsY]];
        [self setDataSetLength:[[aDecoder decodeObjectForKey:kPBDataSetLength] unsignedIntegerValue]];
        [self setLineColor:[aDecoder decodeObjectForKey:kPBDataSetLineColor]];
        [self setFillingColor:[aDecoder decodeObjectForKey:kPBDataSetFillingColor]];
        [self setSymbol:[aDecoder decodeObjectForKey:kPBDataSetSymbol]];
    }
    return self;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone{
    PBDataSet *copy=nil;
    
    copy = [[[self class] allocWithZone:zone] initWithXData:[[[self dataPointsX] copy] autorelease]
                                                      yData:[[[self dataPointsY] copy] autorelease]
                                                   andTitle:[[[self dataSetTitle] copy] autorelease]];
    
    if ([self lineColor]) {
        [copy setLineColor:[[[self lineColor] copy] autorelease]];
    }
    
    if ([self symbol]) {
        [copy setSymbol:[[[self symbol] copy] autorelease]];
    }
    
    return copy;
}


-(NSNumber *)maximumXValue{
    return [dataPointsX valueForKeyPath:@"@max.floatValue"];
}
-(NSNumber *)minimumXValue{
    return [dataPointsX valueForKeyPath:@"@min.floatValue"];
}

-(NSNumber *)maximumYValue{
    return [dataPointsY valueForKeyPath:@"@max.floatValue"];
}
-(NSNumber *)minimumYValue{
    return [dataPointsY valueForKeyPath:@"@max.floatValue"];
}

-(PBDataSet *)cropDataSetWithRange:(NSRange)cropRange{
    
    //Check the range and location are valid, else raise and exception, just to 
    //make debugging easier, instead of a generic out of range exception
    if (cropRange.length > [self dataSetLength] || 
        cropRange.location > [self dataSetLength] ||
        (cropRange.length + cropRange.location) > [self dataSetLength]) {
        [NSException raise:@"PBDatSet" format:@"Length or Location out of range (%d - %d) current size %d", cropRange.location, cropRange.location + cropRange.length, [self dataSetLength]];
    }
    
    NSArray *newXData=[[NSArray alloc] initWithArray:[[self dataPointsX] subarrayWithRange:cropRange]];
    NSArray *newYData=[[NSArray alloc] initWithArray:[[self dataPointsY] subarrayWithRange:cropRange]];
    
    PBDataSet *outputDataSet=[[PBDataSet alloc] initWithXData:newXData yData:newYData andTitle:[self dataSetTitle]];
    
    //These two are optional, so just in case
    if ([self lineColor] != nil) {
        [outputDataSet setLineColor:[self lineColor]];
    }
    if ([self symbol] != nil){
        [outputDataSet setSymbol:[self symbol]];
    }
    
    [newXData release];
    [newYData release];
    
    return [outputDataSet autorelease];
}

+(NSArray *)cropArrayOfDataSets:(NSArray *)theDataSets withRange:(NSRange)cropRange{
    NSMutableArray *bufferArray=[[NSMutableArray alloc] init];
    
    for (PBDataSet *someDataSet in theDataSets) {
        [bufferArray addObject:[someDataSet cropDataSetWithRange:cropRange]];
    }
    
    return [NSArray arrayWithArray:bufferArray];
}

@end
