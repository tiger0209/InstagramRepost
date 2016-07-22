//
//  InstafollowersSession.m
//  Instafollowers
//
//  Created by administrator on 8/22/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "InstafollowersSession.h"

@implementation InstafollowersSession

- (NSNumber *)user_id
{
    return [self.dictionary objectForKey:@"user_id"];
}

- (NSNumber *)ig_user_id
{
    return [self.dictionary objectForKey:@"ig_user_id"];
}

- (NSNumber *)unreadCount
{
    return [self.dictionary objectForKey:@"unread"];
}

- (InstafollowersMessage *)lastMessage
{
    return (InstafollowersMessage *)[InstafollowersMessage modelWithDictionary:[self.dictionary objectForKey:@"last_msg"]];
}

@end
