//
//  InstafollowersNotification.h
//  Instafollowers
//
//  Created by Michael Orcutt on 2/14/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "Model.h"

typedef enum {
    InstafollowersNotificationActivityTypePromotionEnded      = 0,
    InstafollowersNotificationActivityTypeTookTooLong         = 1,
    InstafollowersNotificationActivityTypePromotionFailed     = 2,
    InstafollowersNotificationActivityTypeAppPromotion        = 3,
    InstafollowersNotificationActivityGiftedCoins             = 4,
    InstafollowersNotificationActivityCoinsReturned           = 5,
    InstafollowersNotificationActivityCoinsTakenAway          = 6,
    InstafollowersNotificationActivityTypePromotionBegan      = 7,
    InstafollowersNotificationActivityCoinsReturnedWithReason = 8
} InstafollowersNotificationActivityType;

@interface InstafollowersNotification : Model

@property (readonly) InstafollowersNotificationActivityType activityType;

@property (readonly) NSString     *text;
@property (readonly) NSURLRequest *imageURLRequest;
@property (readonly) NSDate       *date;
@property (readonly) NSString     *identifier;
@property (readonly) NSString     *appIdentifier;
@property (readonly) UIImage      *icon;

@end
