//
//  NSString+Path.m
//  InstagramFollowers
//
//  Created by Michael Orcutt on 12/3/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "NSString+Path.h"

@implementation NSString (Path)

+ (NSString *)pathWithPathComponent:(NSString *)pathComponent
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSString *pListPath = [documentsPath stringByAppendingPathComponent:pathComponent];
    
    return pListPath;
}

@end
