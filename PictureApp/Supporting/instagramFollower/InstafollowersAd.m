//
//  InstafollowersAd.m
//  Instafollowers
//
//  Created by Michael Orcutt on 3/11/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "InstafollowersAd.h"

@implementation InstafollowersAd

- (NSURL *)imageURL
{
    return [NSURL URLWithString:[self.dictionary objectForKey:@"image_url"]];
}

- (NSString *)identifier
{
    return [self.dictionary objectForKey:@"identifier"];
}

@end
