//
//  NSArray+Reorder.h
//  Instafollowers
//
//  Created by Michael Orcutt on 3/5/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Reorder)

+ (NSArray *)reorderArray:(NSArray *)array firstObject:(id)firstObject sortByKey:(NSString *)key;

@end
