//
//  UIImage+Color.m
//  Twitter Followers
//
//  Created by Michael Orcutt on 7/8/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color
{
    UIImage *image = [UIImage imageNamed:name];
    
    CGRect rect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:newImage.CGImage scale:image.scale orientation:UIImageOrientationDownMirrored];
    
    return flippedImage;
}

@end
