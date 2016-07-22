//
//  NSString+Color.m
//  Top of the Morning
//
//  Created by Michael Orcutt on 2/16/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "NSString+Color.h"

#import <CoreImage/CoreImage.h>

@implementation NSString (Color)

+ (NSString *)stringFromColor:(UIColor *)color
{
    CGColorRef colorRef = color.CGColor;
    
    return [CIColor colorWithCGColor:colorRef].stringRepresentation;
}

@end
