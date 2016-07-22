//
//  UIColor+String.m
//  Top of the Morning
//
//  Created by Michael Orcutt on 2/16/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "UIColor+String.h"

#import <CoreImage/CoreImage.h>

@implementation UIColor (String)

+ (UIColor *)colorFromColorString:(NSString *)colorString
{
    CIColor *coreColor = [CIColor colorWithString:colorString];
    
    UIColor *color = [UIColor colorWithRed:coreColor.red green:coreColor.green blue:coreColor.blue alpha:coreColor.alpha];
    
    return color;
}

- (BOOL)isEqualToColor:(UIColor *)otherColor
{
    if (self == otherColor)
        return YES;
    
    CGColorSpaceRef colorSpaceRGB = CGColorSpaceCreateDeviceRGB();
    
    UIColor *(^convertColorToRGBSpace)(UIColor*) = ^(UIColor *color)
    {
        if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelMonochrome)
        {
            const CGFloat *oldComponents = CGColorGetComponents(color.CGColor);
            CGFloat components[4] = {oldComponents[0], oldComponents[0], oldComponents[0], oldComponents[1]};
            CGColorRef colorRef = CGColorCreate(colorSpaceRGB, components);
            UIColor *color = [UIColor colorWithCGColor:colorRef];
            CGColorRelease(colorRef);
            return color;
        }
        else
            return color;
    };
    
    UIColor *selfColor = convertColorToRGBSpace(self);
    otherColor = convertColorToRGBSpace(otherColor);
    CGColorSpaceRelease(colorSpaceRGB);
    
    return [selfColor isEqual:otherColor];
}

@end
