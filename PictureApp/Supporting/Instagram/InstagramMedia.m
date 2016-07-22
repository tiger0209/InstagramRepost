//
//  InstagramMedia.m
//  InstagramFollowers
//
//  Created by Michael Orcutt on 10/30/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "InstagramMedia.h"
#import "InstagramComment.h"

@implementation InstagramMedia

- (InstagramUser *)user
{
    InstagramUser *user = [[InstagramUser alloc] init];
    user.dictionary     = [self.dictionary objectForKey:@"user"];
    
    return user;
}

- (NSString *)identifier
{
    return [self.dictionary objectForKey:@"id"];
}

- (NSString *)caption
{
    return [self.dictionary valueForKeyPath:@"caption.text"];
}

- (NSURL *)thumbnailURL
{
    NSString *urlString = [self.dictionary valueForKeyPath:@"images.thumbnail.url"];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    return url;
}

- (NSURL *)standardURL
{
    NSString *urlString = [self.dictionary valueForKeyPath:@"images.standard_resolution.url"];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    return url;
}

- (CLLocation *)location
{
    CLLocation *location;
    
    if([[self.dictionary valueForKeyPath:@"location.latitude"] class] != [NSNull class]
    && [[self.dictionary valueForKeyPath:@"location.longitude"] class] != [NSNull class]) {
        
        CLLocationDegrees latitude  = [[self.dictionary valueForKeyPath:@"location.latitude"] doubleValue];
        CLLocationDegrees longitude = [[self.dictionary valueForKeyPath:@"location.longitude"] doubleValue];
        
        location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];

    }
    
    return location;
}

- (NSInteger)likeCount
{
    return [[self.dictionary valueForKeyPath:@"likes.count"] integerValue];
}

- (NSInteger)commentCount
{
    return [[self.dictionary valueForKeyPath:@"comments.count"] integerValue];
}

- (NSArray *)likeData
{
    return [InstagramUser modelsFromDictionaries:[self.dictionary valueForKeyPath:@"likes.data"]];
}

- (NSArray *)commentData
{
    return [InstagramComment modelsFromDictionaries:[self.dictionary valueForKeyPath:@"comments.data"]];
}

@end
