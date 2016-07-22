//
//  InstafollowersPromotion.h
//  Instafollowers
//
//  Created by Michael Orcutt on 3/4/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "Model.h"

#import "InstagramUser.h"

@interface InstafollowersPromotion : Model

@property (readonly) InstagramUser *user;
@property (readonly) NSString *promotionIdentifier;
@property (readonly) NSString *categoryIdentifier;

@end
