//
//  InstagramMedia.h
//  InstagramFollowers
//
//  Created by Michael Orcutt on 10/30/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "Model.h"
#import "InstagramUser.h"

#import <CoreLocation/CoreLocation.h>

@interface InstagramMedia : Model

@property (readonly) InstagramUser *user;

@property (readonly) NSString *identifier;
@property (readonly) NSURL *thumbnailURL;
@property (readonly) NSURL *standardURL;
@property (readonly) NSArray *likeData;
@property (readonly) NSArray *commentData;
@property (readonly) NSInteger likeCount;
@property (readonly) NSInteger commentCount;
@property (readonly) CLLocation *location;
////lgilgilgi
@property (readonly) NSString *caption;

@end
