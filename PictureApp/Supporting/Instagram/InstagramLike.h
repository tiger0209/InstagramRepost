//
//  InstagramLike.h
//  InstagramFollowers
//
//  Created by Michael Orcutt on 11/8/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "Model.h"
#import "InstagramUser.h"

@interface InstagramLike : Model

@property (readonly) InstagramUser *likedUser;
@property (readonly) NSDictionary *from;

@end
