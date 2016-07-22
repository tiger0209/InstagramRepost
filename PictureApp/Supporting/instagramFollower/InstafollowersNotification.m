//
//  InstafollowersNotification.m
//  Instafollowers
//
//  Created by Michael Orcutt on 2/14/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "InstafollowersNotification.h"

@implementation InstafollowersNotification


- (InstafollowersNotificationActivityType)activityType
{
    InstafollowersNotificationActivityType instafollowersNotificationActivityType = [[self.dictionary objectForKey:@"activity_type"] intValue];
    
    return instafollowersNotificationActivityType;
}

- (NSString *)text
{
    InstafollowersNotificationActivityType instafollowersNotificationActivityType = self.activityType;
    
    NSString *text;
    switch (instafollowersNotificationActivityType) {
        case InstafollowersNotificationActivityTypePromotionEnded:
            text = @"Your promotion has successfully completed.";
            break;
        case InstafollowersNotificationActivityTypeTookTooLong:
            text = @"Your promotion has taken longer than expected. Please try promoting again.";
            break;
        case InstafollowersNotificationActivityTypePromotionFailed:
            text = @"Your promotion has failed. Please try promoting again.";
            break;
        case InstafollowersNotificationActivityTypeAppPromotion:
            text = [NSString stringWithFormat:@"Download %@ by %@!",
                    [self.dictionary valueForKeyPath:@"data.app_name"], [self.dictionary valueForKeyPath:@"data.publisher"]];
            break;
        case InstafollowersNotificationActivityGiftedCoins:
            text = [NSString stringWithFormat:@"%@ coins have been given to you for %@!", [self.dictionary valueForKeyPath:@"data.coins"], [self.dictionary valueForKeyPath:@"data.memo"]];
            break;
        case InstafollowersNotificationActivityCoinsReturned:
            text = [NSString stringWithFormat:@"%@ coins have been returned!", [self.dictionary valueForKeyPath:@"data.coins"]];
            break;
        case InstafollowersNotificationActivityCoinsTakenAway:
            text = [NSString stringWithFormat:@"%@ coins have been taken away for %@!", [self.dictionary valueForKeyPath:@"data.coins"], [self.dictionary valueForKeyPath:@"data.memo"]];
            break;
        case InstafollowersNotificationActivityTypePromotionBegan:
            text = @"Your promotion has begun.";
            break;
        case InstafollowersNotificationActivityCoinsReturnedWithReason:
            text = [NSString stringWithFormat:@"%@ coins have been returned for %@!", [self.dictionary valueForKeyPath:@"data.coins"], [self.dictionary valueForKeyPath:@"data.memo"]];
            break;
        default:
            text = @"";
            break;
    }
    
    return text;
}

- (NSDate *)date
{
    return [NSDate dateWithTimeIntervalSince1970:[[self.dictionary objectForKey:@"created_at"] doubleValue]];
}

- (NSURLRequest *)imageURLRequest
{
    if([self.dictionary objectForKey:@"thumbnail"]) {
        return [NSURLRequest requestWithURL:[NSURL URLWithString:[self.dictionary objectForKey:@"thumbnail"]]];
    } else {
        return nil;
    }
}

- (NSString *)identifier
{
    return [[self.dictionary objectForKey:@"id"] stringValue];
}

- (NSString *)appIdentifier
{
    return [self.dictionary valueForKeyPath:@"data.app_id"];
}


- (UIImage *)icon
{
    UIImage *icon;
    
    if(self.activityType == InstafollowersNotificationActivityTypePromotionEnded
    || self.activityType == InstafollowersNotificationActivityTypeTookTooLong
    || self.activityType == InstafollowersNotificationActivityTypePromotionFailed) {
        icon = [UIImage imageNamed:@"Invite"];
    } else if(self.activityType == InstafollowersNotificationActivityGiftedCoins
              || self.activityType == InstafollowersNotificationActivityCoinsTakenAway
              || self.activityType == InstafollowersNotificationActivityCoinsReturned)
    {
        icon = [UIImage imageNamed:@"CoinsGray"];
    } else if(self.activityType == InstafollowersNotificationActivityTypeAppPromotion) {
        icon = [UIImage imageNamed:@"AppStore"];
    }
    
    return icon;
}

@end
