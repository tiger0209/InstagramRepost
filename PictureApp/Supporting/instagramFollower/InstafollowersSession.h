//
//  InstafollowersSession.h
//  Instafollowers
//
//  Created by administrator on 8/22/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "Model.h"
#import "InstagramUser.h"
#import "InstafollowersMessage.h"

@interface InstafollowersSession : Model

@property (readonly) NSNumber *user_id;
@property (readonly) NSNumber *ig_user_id;
@property (readonly) NSNumber *unreadCount;
@property (readonly) InstafollowersMessage *lastMessage;

@property (retain, nonatomic) InstagramUser *user;

@end
