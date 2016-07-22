//
//  UIColor+String.h
//  Top of the Morning
//
//  Created by Michael Orcutt on 2/16/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (String)

+ (UIColor *)colorFromColorString:(NSString *)colorString;

- (BOOL)isEqualToColor:(UIColor *)otherColor;

@end
