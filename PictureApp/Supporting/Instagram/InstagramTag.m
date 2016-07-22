//
//  InstagramUser.m
//  InstagramFollowers
//
//  Created by Michael Orcutt on 10/20/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "InstagramTag.h"

@implementation InstagramTag

- (NSString *)description
{
    return [NSString stringWithFormat:@"Tag : %@ %@", self.tagName, self.mediaCount];
}

- (NSString *)tagName
{
    return [self.dictionary objectForKey:@"name"];
}

- (NSString *)mediaCount
{
    return [[self.dictionary valueForKeyPath:@"media_count"] stringValue];
}

@end
