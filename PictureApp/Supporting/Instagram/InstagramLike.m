//
//  InstagramLike.m
//  InstagramFollowers
//
//  Created by Michael Orcutt on 11/8/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "InstagramLike.h"

@implementation InstagramLike

- (InstagramUser *)likedUser
{
    InstagramUser *user = [[InstagramUser alloc] init];
    user.dictionary     = [self.dictionary valueForKeyPath:@"user"];
    
    return user;
}
 
@end
