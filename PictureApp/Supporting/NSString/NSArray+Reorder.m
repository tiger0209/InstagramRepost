//
//  NSArray+Reorder.m
//  Instafollowers
//
//  Created by Michael Orcutt on 3/5/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "NSArray+Reorder.h"

@implementation NSArray (Reorder)

+ (NSArray *)reorderArray:(NSArray *)array firstObject:(id)firstObject sortByKey:(NSString *)key
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key
                                                                   ascending:YES
                                                                    selector:@selector(localizedStandardCompare:)];
    
    NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[array sortedArrayUsingDescriptors:@[ sortDescriptor ]]];
    
    // Remove object and add back as the first object
    [sortedArray removeObject:firstObject];
    [sortedArray insertObject:firstObject atIndex:0];
    
    return sortedArray;
}

@end
