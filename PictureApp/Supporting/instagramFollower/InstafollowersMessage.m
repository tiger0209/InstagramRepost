//
//  InstafollowersMessage.m
//  Instafollowers
//
//  Created by administrator on 8/22/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "InstafollowersMessage.h"

@implementation InstafollowersMessage

- (NSNumber *)msg_id
{
    return [self.dictionary objectForKey:@"msg_id"];
}

- (NSNumber *)creator_id
{
    return [self.dictionary objectForKey:@"creator"];
}

- (NSNumber *)receiptor_id
{
    return [self.dictionary objectForKey:@"receiptor"];
}

- (NSDate *)created_at
{
    return [NSDate dateWithTimeIntervalSince1970:[[self.dictionary objectForKey:@"created_at"] doubleValue]];
}

- (NSNumber *)type
{
    return [self.dictionary objectForKey:@"type"];
}

- (NSString *)content
{
    //NSString *content = [self.dictionary objectForKey:@"content"];
    //return [content stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [self.dictionary objectForKey:@"content"];
}

- (NSString *)messageString
{
    if (self.type) {
        switch (self.type.intValue) {
            case MessageTypeText:
                return self.content;
            case MessageTypePhoto:
                return @"[Photo]";
            case MessageTypeVideo:
                return @"[Video]";
            default:
                break;
        }
    }
    
    return nil;
}

@end
