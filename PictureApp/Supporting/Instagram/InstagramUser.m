//
//  InstagramUser.m
//  InstagramFollowers
//
//  Created by Michael Orcutt on 10/20/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "InstagramUser.h"

@implementation InstagramUser

- (NSString *)description
{
    return [NSString stringWithFormat:@"User : %@ (%@) - %@", self.fullName, self.username, self.identifier];
}

- (NSString *)identifier
{
    return [self.dictionary objectForKey:@"id"];
}

- (NSNumber *)identifierNumber
{
    return [NSNumber numberWithInteger:[[self.dictionary objectForKey:@"id"] integerValue]];
}

- (NSString *)fullName
{
    NSString *fullName = [self.dictionary objectForKey:@"full_name"];
    
    if(fullName.length == 0) {
        fullName = [self username];
    }
    
    return fullName;
}

- (NSString *)username
{
    return [self.dictionary objectForKey:@"username"];
}

- (NSString *)bio
{
    NSString *bio = [self.dictionary objectForKey:@"bio"];
    
    if(bio.length == 0) {
        bio = [self username];
    }
    
    return bio;
}

- (NSString *)website
{
    return [self.dictionary objectForKey:@"website"];
}

- (NSString *)profilePictureURLString
{
    return [self.dictionary objectForKey:@"profile_picture"];
}

- (NSURL *)profilePictureURL
{
    return [NSURL URLWithString:[self profilePictureURLString]];
}

- (NSString *)followersCount
{
    if([[self.dictionary valueForKeyPath:@"counts.followed_by"] stringValue].length > 0) {
        return [[self.dictionary valueForKeyPath:@"counts.followed_by"] stringValue];
    } else {
        return @"";
    }
}

- (NSString *)followsCount
{
    if([[self.dictionary valueForKeyPath:@"counts.follows"] stringValue].length > 0) {
        return [[self.dictionary valueForKeyPath:@"counts.follows"] stringValue];
    } else {
        return @"";
    }
}

- (NSString *)mediaCount
{
    return [[self.dictionary valueForKeyPath:@"counts.media"] stringValue];
}

@end
