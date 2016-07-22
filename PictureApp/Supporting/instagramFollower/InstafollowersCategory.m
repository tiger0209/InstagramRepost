//
//  InstafollowersCategory.m
//  Instafollowers
//
//  Created by Michael Orcutt on 2/17/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "InstafollowersCategory.h"

@implementation InstafollowersCategory

- (NSString *)identifier
{
    return [self.dictionary objectForKey:@"identifier"];
}

- (NSString *)title
{
    return [self.dictionary objectForKey:@"title"];
}

@end
