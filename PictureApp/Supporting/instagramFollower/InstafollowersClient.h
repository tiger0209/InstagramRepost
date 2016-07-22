//
//  InstafollowersClient.h
//  InstagramFollowers
//
//  Created by Michael Orcutt on 2/13/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

#import "EnumConstants.h"

// Models
#import "InstagramUser.h"
#import "InstafollowersPromotion.h"
#import "InstafollowersAd.h"

@interface InstafollowersClient : AFHTTPRequestOperationManager

@property (retain, nonatomic) InstagramUser *igUser;

// Singleton client used throughout
// the entire application
+ (InstafollowersClient *)sharedClient;

// Login
- (void)loginUserWithAccessToken:(NSString *)accessToken
                      completion:(void(^)(BOOL success, InstagramUser *user, NSNumber *coins, NSString *failureMessage, BOOL promoting))completionBlock;

// Push notifications
- (void)postDeviceWithDeviceToken:(NSString *)deviceToken
               preferredLanguaged:(NSString *)preferredLanguage
                       completion:(void(^)(BOOL success))completionBlock;
- (void)putDeactivateDeviceWithDeviceToken:(NSString *)deviceToken
                                completion:(void(^)(BOOL success))completionBlock;

// Notifications
- (void)getNotificationsWithMaxIdentifier:(NSString *)maxIdentifier
                               completion:(void(^)(BOOL success, NSArray *notifications, NSString *nextMaxIdentifier, NSNumber *coins, BOOL promoting))completionBlock;
- (void)getUnreadNotificationsCountWithCompletion:(void(^)(BOOL success, NSNumber *count))completionBlock;
- (void)postNotificationsReadWithCompletion:(void(^)(BOOL success))completionBlock;

// Coins
- (void)getCoinsWithCompletion:(void(^)(BOOL success, NSNumber *coins))completionBlock;

- (void)postReceipt:(NSString *)receipt
         completion:(void(^)(BOOL success, NSNumber *coins))completionBlock;

// Promotion
- (void)postPromotionForCategoryIdentifier:(NSString *)categoryIdentifier
                        followersRequested:(NSNumber *)followersRequested
                                completion:(void(^)(BOOL success, BOOL promoting, NSNumber *coins, NSString *failureMessage))completionBlock;
- (void)getPromotionForCategoryIdentifier:(NSString *)categoryIdentifier
                               completion:(void(^)(BOOL success, BOOL results, InstafollowersPromotion *promotion))completionBlock;
- (void)getCurrentUserPromotingWithCompletion:(void(^)(BOOL success, BOOL promoting))completionBlock;
- (void)postFollowPromotionWithPromotionIdentifier:(NSString *)promotionIdentifier
                                        completion:(void(^)(BOOL success, NSNumber *coins, NSString *errorMessage))completionBlock;
- (void)postSkipPromotionWithPromotionIdentifier:(NSString *)promotionIdentifier
                                      completion:(void(^)(BOOL success, NSString *errorMessage))completionBlock;

// Ads
- (void)getAdsWithCompletion:(void(^)(BOOL success, NSArray *ads))completionBlock;
- (void)getUnsolicitedUsersWithCursor:(NSString *)cursor
                           completion:(void(^)(BOOL success, NSArray *users, NSString *nextCursor))completionBlock;
- (void)postAdSubmission:(InstafollowersAd *)ad
                 caption:(NSString *)caption
         userIdentifiers:(NSArray *)userIdentifiers
              completion:(void (^)(BOOL success))completionBlock;
- (void)deleteAdSubmissionWithCaption:(NSString *)caption
                           completion:(void (^)(BOOL success))completionBlock;

// Relationship
- (void)postRelationshipChangeForUserIdentifier:(NSString *)userIdentifier
                                         action:(NSString *)action
                                     completion:(void (^)(BOOL success, Relationship outgoingRelationship, NSString *errorMessage))completionBlock;

// Products
- (void)getProductsWithCompletion:(void(^)(BOOL success, NSArray *products))completionBlock;

// Chatting
- (void)getSessionsWithMaxIdentifier:(NSNumber *)maxIdentifier
                          completion:(void(^)(BOOL success, NSArray *sessions, NSNumber *nextMaxIdentifier))completionBlock;

- (void)getMessagesWithMaxIdentifier:(NSNumber *)maxIdentifier
                      userIdentifier:(NSNumber *)userId
                          completion:(void(^)(BOOL success, NSArray *notifications, NSNumber *nextMaxIdentifier))completionBlock;

- (void)postTextMessage:(NSString *)message
              receiptor:(NSNumber *)receiptor
                 sender:(NSString *)senderUsername
                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)updateSessionForUser:(NSNumber *)userId
                  completion:(void(^)(BOOL success))completionBlock;


- (void)postMultipartFormWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                              type:(NSNumber *)type
                         receiptor:(NSNumber *)receiptor
                            sender:(NSString *)senderUsername
						   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
						   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)checkUserWithInstagramIdentifier:(NSString *)ig_user_id
                              completion:(void(^)(BOOL success, id result))completionBlock;

- (void)removeSession:(NSNumber *)user_id
           completion:(void (^)(BOOL success, NSError *error))completionBlock;

- (void)postPurchaseStatus:(NSString *)purchased
                completion:(void(^)(BOOL success))completionBlock;

- (void)updateCoinsForRateApp:(void(^)(BOOL success))completionBlock;

- (void)getRatedStatusWithCompletion:(void (^)(BOOL, NSString *))completionBlock;

- (void)updateCoins:(NSNumber *)coins completionBlock:(void(^)(BOOL success, id response))completionBlock;

@end
