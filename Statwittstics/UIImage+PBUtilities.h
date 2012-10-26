//
//  UIImage+PBUtilities.h
//  Statwittstics
//
//  Created by Yoshiki Vázquez Baeza on 25/10/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CustomPBUtilities)

// Utilities to resize an image without alias
+ (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize;
+ (UIImage *)resizeImageNamed:(NSString *)image newSize:(CGSize)newSize;

@end
