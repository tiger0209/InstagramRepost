//
//  InstagramComment.m
//  InstagramFollowers
//
//  Created by Michael Orcutt on 11/26/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "InstagramComment.h"

@implementation InstagramComment

- (NSString *)userIdentifier
{
    return [self.dictionary valueForKeyPath:@"from.id"];
}

- (NSDictionary *)from
{
    return [self.dictionary valueForKey:@"from"];
}

/////lgilgilgi
- (NSString *)text
{
    return [self.dictionary valueForKey:@"text"];
}

@end
