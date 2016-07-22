//
//  InstafollowersPromotion.m
//  Instafollowers
//
//  Created by Michael Orcutt on 3/4/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "InstafollowersPromotion.h"

@implementation InstafollowersPromotion

- (NSString *)promotionIdentifier
{
    return [[self.dictionary objectForKey:@"promotion_id"] stringValue];
}

- (InstagramUser *)user
{
    InstagramUser *user = [[InstagramUser alloc] init];
    user.dictionary     = [self.dictionary objectForKey:@"user"];
    
    return user;
}

- (NSString *)categoryIdentifier
{
    return [NSString stringWithFormat:@"%@", [self.dictionary objectForKey:@"category_id"]];
}

@end
