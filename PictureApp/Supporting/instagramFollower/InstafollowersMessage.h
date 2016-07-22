//
//  InstafollowersMessage.h
//  Instafollowers
//
//  Created by administrator on 8/22/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "Model.h"

typedef enum {
    MessageTypeText  = 0,
    MessageTypePhoto,
    MessageTypeVideo,
    MessageTypeOther,
} MessageType;

@interface InstafollowersMessage : Model

@property (readonly) NSNumber  *msg_id;
@property (readonly) NSNumber  *creator_id;
@property (readonly) NSNumber  *receiptor_id;
@property (readonly) NSDate    *created_at;
@property (readonly) NSNumber  *type;       // MessageType
@property (readonly) NSString  *content;
@property (readonly) NSString  *messageString;

@end
