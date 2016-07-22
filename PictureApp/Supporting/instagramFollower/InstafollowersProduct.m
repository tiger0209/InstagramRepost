//
//  InstafollowersProduct.m
//  Instafollowers
//
//  Created by Michael Orcutt on 2/18/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "InstafollowersProduct.h"

@implementation InstafollowersProduct

- (NSString *)title
{
    return [NSString stringWithFormat:@"%@ Followers", [self.dictionary objectForKey:@"followers"]];
}

- (NSInteger)coins
{
    return [[self.dictionary objectForKey:@"coins"] integerValue];
}

- (NSInteger)followers
{
    return [[self.dictionary objectForKey:@"followers"] integerValue];
}

@end
