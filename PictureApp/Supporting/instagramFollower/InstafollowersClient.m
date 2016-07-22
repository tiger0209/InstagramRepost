//
//  InstafollowersClient.m
//  InstagramFollowers
//
//  Created by Michael Orcutt on 2/13/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "InstafollowersClient.h"

// Models
#import "InstafollowersNotification.h"
#import "InstafollowersSession.h"

#import "Constants.h"

// String constants
NSString* const InstafollowersPromotionURL              = @"http://www.instapromote.us/instafollowers/api/promote/followers/index.php";
NSString* const InstafollowersPromotionInventoryURL     = @"http://www.instapromote.us/instafollowers/api/promote/followers/inventory/index.php";
NSString* const InstafollowersPromotionFollowURL        = @"http://www.instapromote.us/instafollowers/api/promote/followers/follow/index.php";
NSString* const InstafollowersPromotionSkipURL          = @"http://www.instapromote.us/instafollowers/api/promote/followers/skip/index.php";
NSString* const InstafollowersPromitionRateAppURL       = @"http://www.instapromote.us/instafollowers/api/promote/rateapp/index.php";
NSString* const InstafollowersLoginURL                  = @"http://www.instapromote.us/instafollowers/api/auth/index.php";
NSString* const InstafollowersUserDevicesURL            = @"http://www.instapromote.us/instafollowers/api/user/devices/index.php";
NSString* const InstafollowersUserCoinsURL              = @"http://www.instapromote.us/instafollowers/api/user/coins/index.php";
NSString* const InstafollowersUserCoinsUpdateURL        = @"http://www.instapromote.us/instafollowers/api/user/coins/update.php";
NSString* const InstafollowersAdsURL                    = @"http://www.instapromote.us/instafollowers/api/ads/index.php";
NSString* const InstafollowersAdSubmissionURL           = @"http://www.instapromote.us/instafollowers/api/ads/submission/index.php";
NSString* const InstafollowersRemoveAdSubmissionURL     = @"http://www.instapromote.us/instafollowers/api/ads/submission/remove/index.php";
NSString* const InstafollowersUnsolicitedUsersURL       = @"http://www.instapromote.us/instafollowers/api/ads/unsolicited/index.php";
NSString* const InstafollowersNotificationsURL          = @"http://www.instapromote.us/instafollowers/api/user/notifications/index.php";
NSString* const InstafollowersNotificationsMarkReadURL  = @"http://www.instapromote.us/instafollowers/api/user/notifications/read/index.php";
NSString* const InstafollowersUnreadNotificationsURL    = @"http://www.instapromote.us/instafollowers/api/user/notifications/count/index.php";
NSString* const InstafollowersRelationshipsURL          = @"http://www.instapromote.us/instafollowers/api/relationship/index.php";
NSString* const InstafollowersProductsURL               = @"http://www.instapromote.us/instafollowers/api/products/index.php";
NSString* const InstafollowersSessionsURL               = @"http://www.instapromote.us/instafollowers/api/user/sessions/index.php";
NSString* const InstafollowersUpdateSessionURL          = @"http://www.instapromote.us/instafollowers/api/user/sessions/update.php";
NSString* const InstafollowersRemoveSessionURL          = @"http://www.instapromote.us/instafollowers/api/user/sessions/remove.php";
NSString* const InstafollowersMessagesURL               = @"http://www.instapromote.us/instafollowers/api/user/messages/index.php";
NSString* const InstafollowersPostMessageURL            = @"http://www.instapromote.us/instafollowers/api/user/messages/post.php";
NSString* const InstafollowersUserURL                   = @"http://www.instapromote.us/instafollowers/api/user/index.php";


@interface InstafollowersClient ()

@property (strong, nonatomic) NSString *token;

@end

@implementation InstafollowersClient

+ (InstafollowersClient *)sharedClient
{
    static InstafollowersClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedClient                    = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.instapromote.us/instafollowers/api/"]];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        _sharedClient.requestSerializer  = [AFHTTPRequestSerializer serializer];
    });
    
    // Set the token from user defaults
    _sharedClient.token = [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken];
    
    return _sharedClient;
}

#pragma mark - Login

- (void)loginUserWithAccessToken:(NSString *)accessToken
                      completion:(void(^)(BOOL success, InstagramUser *user, NSNumber *coins, NSString *failureMessage, BOOL promoting))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    // Make get request
    [self POST:InstafollowersLoginURL parameters:@{ @"access_token" : accessToken } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        InstagramUser *user = [[InstagramUser alloc] init];
        user.dictionary     = [responseObject objectForKey:@"user"];
        
        NSNumber *coins = [NSNumber numberWithInteger:[[responseObject objectForKey:@"coins"] integerValue]];
        
        BOOL promoting = [[responseObject objectForKey:@"promoting"] boolValue];
        
        if(completionBlock) {
            completionBlock(YES, user, coins, nil, promoting);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@", operation.responseString);
        
        if(completionBlock && [operation.responseObject valueForKey:@"error"]) {
            completionBlock(NO, nil, nil, [operation.responseObject valueForKey:@"error"], NO);
        } else if (completionBlock) {
            completionBlock(NO, nil, nil, nil, NO);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

#pragma mark - Push notifications

- (void)postDeviceWithDeviceToken:(NSString *)deviceToken
               preferredLanguaged:(NSString *)preferredLanguage
                       completion:(void(^)(BOOL success))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    // Check if pro version
    BOOL pro;
    
    #ifdef PRO_VERSION
        pro = YES;
    #else
        pro = NO;
    #endif
    
    // Params setup
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];

    NSDictionary *params = @{ @"access_token" : accessToken, @"device_token" : deviceToken, @"preferred_language" : preferredLanguage, @"pro_version" : [NSNumber numberWithBool:pro] };
    
    // Make POST request
    [self POST:InstafollowersUserDevicesURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(completionBlock) {
            completionBlock(YES);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)putDeactivateDeviceWithDeviceToken:(NSString *)deviceToken
                                completion:(void(^)(BOOL success))completionBlock
{
    // Params setup
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];

    NSDictionary *params = @{ @"access_token" : accessToken, @"device_token" : deviceToken };
    
    // Make POST request
    [self PUT:InstafollowersUserDevicesURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(completionBlock) {
            completionBlock(YES);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

#pragma mark - Coins

- (void)postReceipt:(NSString *)receipt
         completion:(void(^)(BOOL success, NSNumber *coins))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];
    
    NSDictionary *params = @{ @"access_token" : accessToken, @"receipt" : receipt };
    
    // Make POST request
    [self POST:InstafollowersUserCoinsURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(completionBlock) {
            completionBlock(YES, [NSNumber numberWithInteger:[[responseObject valueForKey:@"coins"] integerValue]]);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)getCoinsWithCompletion:(void (^)(BOOL, NSNumber *))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];

    // Make get request
    [self GET:InstafollowersUserCoinsURL parameters:@{ @"access_token" : accessToken } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(completionBlock) {
            if([responseObject valueForKey:@"coins"]) {
                completionBlock(YES, [NSNumber numberWithInteger:[[responseObject valueForKey:@"coins"] integerValue]]);
            } else {
                completionBlock(NO, nil);
            }
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

#pragma mark - Notifications

- (void)getNotificationsWithMaxIdentifier:(NSString *)maxIdentifier
                               completion:(void(^)(BOOL success, NSArray *notifications, NSString *nextMaxIdentifier, NSNumber *coins, BOOL promoting))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    // Params
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (maxIdentifier) {
        [params setObject:maxIdentifier forKey:@"max_identifier"];
    }
    
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];

    [params setObject:accessToken forKey:@"access_token"];
    
    // Make get request
    [self GET:InstafollowersNotificationsURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *coins;
        if([responseObject valueForKey:@"coins"]) {
            coins = [NSNumber numberWithInteger:[[responseObject objectForKey:@"coins"] integerValue]];
        }
        
        BOOL promoting = NO;
        if([responseObject valueForKey:@"promoting"]) {
            promoting = [[responseObject valueForKey:@"promoting"] boolValue];
        }
        
        if(completionBlock && [responseObject objectForKey:@"next_max_identifier"]) {
            completionBlock(YES, [InstafollowersNotification modelsFromDictionaries:[responseObject objectForKey:@"data"]], [responseObject objectForKey:@"next_max_identifier"], coins, promoting);
        } else {
            completionBlock(YES, [InstafollowersNotification modelsFromDictionaries:[responseObject objectForKey:@"data"]], nil, coins, promoting);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@", operation.responseString);
        
        if(completionBlock) {
            completionBlock(NO, nil, nil, nil, NO);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)getUnreadNotificationsCountWithCompletion:(void(^)(BOOL success, NSNumber *count))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    // Params
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];

    NSDictionary *params = @{ @"access_token" : accessToken };
    
    // Make get request
    [self GET:InstafollowersUnreadNotificationsURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(completionBlock) {
            completionBlock(YES, [NSNumber numberWithInteger:[[responseObject objectForKey:@"unread_notifications"] integerValue]]);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)postNotificationsReadWithCompletion:(void(^)(BOOL success))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    // Params
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];

    NSDictionary *params = @{ @"access_token" : accessToken };
    
    // Make get request
    [self POST:InstafollowersNotificationsMarkReadURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(completionBlock) {
            completionBlock(YES);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

#pragma mark - Promotion

- (void)postPromotionForCategoryIdentifier:(NSString *)categoryIdentifier
                        followersRequested:(NSNumber *)followersRequested
                                completion:(void(^)(BOOL success, BOOL promoting, NSNumber *coins, NSString *failureMessage))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    // Params
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];

    NSDictionary *params
    = @{ @"access_token" : accessToken, @"category_id" : categoryIdentifier, @"followers_requested" : followersRequested };
    
    // Make get request
    [self POST:InstafollowersPromotionURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *coins;
        if([responseObject objectForKey:@"coins"]) {
            coins = [NSNumber numberWithInteger:[[responseObject objectForKey:@"coins"] integerValue]];
        }
        
        if(completionBlock) {
            completionBlock(YES, [[responseObject objectForKey:@"promoting"] boolValue], coins, nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock && [operation.responseObject objectForKey:@"error"]) {
            completionBlock(NO, [[operation.responseObject objectForKey:@"promoting"] boolValue], nil, [operation.responseObject objectForKey:@"error"]);
        } else {
            completionBlock(NO, NO, nil, nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)getPromotionForCategoryIdentifier:(NSString *)categoryIdentifier
                               completion:(void (^)(BOOL success, BOOL results, InstafollowersPromotion *promotion))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    // Params
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{ @"access_token" : accessToken }];
    
    if(categoryIdentifier.length > 0) {
        [params setObject:categoryIdentifier forKey:@"category_id"];
    }
    
    // Make get request
    [self GET:InstafollowersPromotionInventoryURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(operation.response.statusCode == 204) {
            
            // 204 returns no reponse but we still create a promotion in order
            // to have the category identifier
            
            InstafollowersPromotion *promotion = [[InstafollowersPromotion alloc] init];
            
            if(categoryIdentifier.length > 0) {
                promotion.dictionary = @{ @"category_id" : categoryIdentifier };
            }
            
            completionBlock(YES, NO, promotion);
            
        } else if(completionBlock && [responseObject objectForKey:@"data"]) {
            
            InstafollowersPromotion *promotion = [[InstafollowersPromotion alloc] init];
            promotion.dictionary               = [responseObject objectForKey:@"data"];

            completionBlock(YES, YES, promotion);
         
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, NO, nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)getCurrentUserPromotingWithCompletion:(void(^)(BOOL success, BOOL promoting))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    // Params
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{ @"access_token" : accessToken }];
    
    // Make get request
    [self GET:InstafollowersPromotionURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
        if(completionBlock && [responseObject objectForKey:@"promoting"]) {
            
            BOOL promoting = [[responseObject objectForKey:@"promoting"] boolValue];
            
            completionBlock(YES, promoting);
            
        } else if(completionBlock) {
            
            completionBlock(NO, NO);
            
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, NO);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)postFollowPromotionWithPromotionIdentifier:(NSString *)promotionIdentifier completion:(void (^)(BOOL success, NSNumber *coins, NSString *errorMessage))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    // Params
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];

    NSDictionary *params = @{ @"access_token" : accessToken, @"promotion_id" : promotionIdentifier };
    
    // Make get request
    [self POST:InstafollowersPromotionFollowURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *coins;
        if([responseObject objectForKey:@"coins"]) {
            coins = [NSNumber numberWithInteger:[[responseObject objectForKey:@"coins"] integerValue]];
        }
        
        NSString *errorMessage;
        if([responseObject objectForKey:@"error"]) {
            errorMessage = [responseObject objectForKey:@"error"];
        }
        
        if(completionBlock) {
            completionBlock(YES, coins, errorMessage);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSString *errorMessage;
        if([operation.responseObject objectForKey:@"error"]) {
            errorMessage = [operation.responseObject objectForKey:@"error"];
        }

        if(completionBlock) {
            completionBlock(NO, nil, errorMessage);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)postSkipPromotionWithPromotionIdentifier:(NSString *)promotionIdentifier completion:(void (^)(BOOL success, NSString *errorMessage))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    // Params
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];

    NSDictionary *params = @{ @"access_token" : accessToken, @"promotion_id" : promotionIdentifier };
    
    // Make get request
    [self POST:InstafollowersPromotionSkipURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(completionBlock) {
            completionBlock(YES, nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSString *errorMessage;
        if([operation.responseObject objectForKey:@"error"]) {
            errorMessage = [operation.responseObject objectForKey:@"error"];
        }
        
        if(completionBlock) {
            completionBlock(NO, errorMessage);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

#pragma mark - Promotions

- (void)postAdSubmission:(InstafollowersAd *)ad
                 caption:(NSString *)caption
         userIdentifiers:(NSArray *)userIdentifiers
              completion:(void (^)(BOOL success))completionBlock
{
    
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    // Params
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];

    NSDictionary *params = @{ @"access_token" : accessToken,
                              @"caption" : caption,
                              @"ad_id" : ad.identifier,
                              @"user_identifiers" : [userIdentifiers componentsJoinedByString:@","] };
    
    // Make get request
    [self POST:InstafollowersAdSubmissionURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(completionBlock) {
            completionBlock(YES);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)deleteAdSubmissionWithCaption:(NSString *)caption completion:(void (^)(BOOL success))completionBlock;
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    // Params
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];

    NSDictionary *params = @{ @"access_token" : accessToken, @"caption" : caption };
    
    // Make get request
    [self POST:InstafollowersRemoveAdSubmissionURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(completionBlock) {
            completionBlock(YES);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)getAdsWithCompletion:(void(^)(BOOL success, NSArray *ads))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    // Make get request
    [self GET:InstafollowersAdsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(completionBlock) {
            completionBlock(YES, [InstafollowersAd modelsFromDictionaries:[responseObject objectForKey:@"data"]]);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)getUnsolicitedUsersWithCursor:(NSString *)cursor
                           completion:(void(^)(BOOL success, NSArray *users, NSString *nextCursor))completionBlock;
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];

    dispatch_async(kBgQueue, ^{
        
        // Properties used in while condition
        // and to return completion block
        NSMutableArray *users = [NSMutableArray array];
        NSString *nextCursor  = cursor;
        
        // While completion value
        BOOL complete = NO;
        
        // Use while statement to load media items, some data sets may not return
        // full as some media objects are being promoted
        while (!complete) {
            
            // Constuct URL string
            NSString *urlString = [NSString stringWithFormat:@"%@?access_token=%@", InstafollowersUnsolicitedUsersURL, accessToken];
            if(nextCursor) {
                urlString = [NSString stringWithFormat:@"%@&cursor=%@", urlString, nextCursor];
            }
            
            // Make URL request
            NSURLRequest *preparedURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            
            NSURLResponse *response;
            NSError       *error = nil;
            
            NSData *responseData = [NSURLConnection sendSynchronousRequest:preparedURLRequest
                                                         returningResponse:&response
                                                                     error:&error];
            
            // If an error occurs, return failure
            if(error != nil) {
                
                // Return completion block
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(completionBlock) {
                        completionBlock(NO, nil, nil);
                    }
                });
                
                // Hide activity indicator
                HideNetworkActivityIndicator();
                
                // Mark complete and return
                complete = YES;
                return;
            }
            
            // Parse JSON response
            NSError *jsonError;
            
            id jsonResponse
            = [NSJSONSerialization JSONObjectWithData:responseData
                                              options:NSJSONReadingMutableLeaves
                                                error:&jsonError];
            
            // If there is a json error, return failure
            if(jsonError || ![jsonResponse objectForKey:@"data"]) {
                
                // Return completion block
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(completionBlock) {
                        completionBlock(NO, nil, nil);
                    }
                });
                
                // Hide activity indicator
                HideNetworkActivityIndicator();
                
                // Mark complete and return
                complete = YES;
                return;
            }
            
            // Add instagram user models to media items array
            [users addObjectsFromArray:[InstagramUser modelsFromDictionaries:[jsonResponse objectForKey:@"data"]]];
            
            // Get next max identifier
            nextCursor = [jsonResponse objectForKey:@"next_cursor"];
            
            // If there are more than 12 users and there is no next
            // max identifier, return. Otherwise, keep iterating.
            if(users.count >= 12 || nextCursor.length == 0) {
                
                // Return completion block
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(completionBlock) {
                        completionBlock(YES, users, nextCursor);
                    }
                });
                
                // Hide activity indicator
                HideNetworkActivityIndicator();
                
                // Mark complete
                complete = YES;
                
            }
            
        }
        
    });
}

#pragma mark - Relationship

- (void)postRelationshipChangeForUserIdentifier:(NSString *)userIdentifier
                                         action:(NSString *)action
                                     completion:(void (^)(BOOL success, Relationship outgoingRelationship, NSString *errorMessage))completionBlock;
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    // Params
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];

    NSDictionary *params = @{ @"access_token" : accessToken, @"action" : action, @"user_identifier" : userIdentifier };
    
    // Make get request
    [self POST:InstafollowersRelationshipsURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([responseObject objectForKey:@"data"]) { // Return success if there is data
            
            // Check if target user is private
            BOOL private = [[responseObject valueForKeyPath:@"data.target_user_is_private"] boolValue];
            
            // Outgoing relationship response
            Relationship outgoingRelationship;
            
            if([[responseObject valueForKeyPath:@"data.outgoing_status"] isEqualToString:@"follows"]) {
                outgoingRelationship = RelationshipFollowing;
            } else if([[responseObject valueForKeyPath:@"data.outgoing_status"] isEqualToString:@"none"]) {
                if(private) {
                    outgoingRelationship = RelationshipNotFollowingPrivate;
                } else {
                    outgoingRelationship = RelationshipNotFollowing;
                }
            } else if([[responseObject valueForKeyPath:@"data.outgoing_status"] isEqualToString:@"requested"]) {
                outgoingRelationship = RelationshipRequested;
            } else {
                outgoingRelationship = RelationshipUnknown;
            }
            
            // Error message
            NSString *errorMessage;
            
            if([responseObject objectForKey:@"error"]) {
                errorMessage = [responseObject objectForKey:@"error"];
            }
            
            // Completion block
            if(completionBlock) {
                completionBlock(YES, outgoingRelationship, errorMessage);
            }

        } else { // Return failure if there is no data
            
            // Completion block
            if(completionBlock) {
                completionBlock(NO, RelationshipUnknown, nil);
            }

        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // Error message
        NSString *errorMessage;
        
        if([operation.responseObject objectForKey:@"error"]) {
            errorMessage = [operation.responseObject objectForKey:@"error"];
        }

        // Completion block
        if(completionBlock) {
            completionBlock(NO, RelationshipUnknown, errorMessage);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

// Products
- (void)getProductsWithCompletion:(void(^)(BOOL success, NSArray *products))completionBlock
{
    // Make get request
    [self GET:InstafollowersProductsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(completionBlock && [responseObject objectForKey:@"data"]) {
            completionBlock(YES, [responseObject objectForKey:@"data"]);
        } else {
            completionBlock(NO, nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

#pragma mark - Sessions & Messaging

- (void)getSessionsWithMaxIdentifier:(NSNumber *)maxIdentifier
                          completion:(void(^)(BOOL success, NSArray *notifications, NSNumber *nextMaxIdentifier))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    // Params
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if(maxIdentifier) {
        [params setObject:maxIdentifier forKey:@"max_identifier"];
    }
    
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];
    
    [params setObject:accessToken forKey:@"access_token"];
    
    // Make get request
    [self GET:InstafollowersSessionsURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (completionBlock && [responseObject objectForKey:@"next_max_identifier"]) {
            completionBlock(YES, [InstafollowersSession modelsFromDictionaries:[responseObject objectForKey:@"data"]], [responseObject objectForKey:@"next_max_identifier"]);
        } else {
            completionBlock(YES, [InstafollowersSession modelsFromDictionaries:[responseObject objectForKey:@"data"]], nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@", operation.responseObject);
        
        if(completionBlock) {
            completionBlock(NO, nil, nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)getMessagesWithMaxIdentifier:(NSNumber *)maxIdentifier
                      userIdentifier:(NSNumber *)userId
                          completion:(void(^)(BOOL success, NSArray *messages, NSNumber *nextMaxIdentifier))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    // Params
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (maxIdentifier)
        [params setObject:maxIdentifier forKey:@"max_identifier"];
    
    if (userId)
        [params setObject:userId forKey:@"user_id"];
    
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];
    [params setObject:accessToken forKey:@"access_token"];
    
    // Make get request
    [self GET:InstafollowersMessagesURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (completionBlock && [responseObject objectForKey:@"next_max_identifier"]) {
            completionBlock(YES, [InstafollowersMessage modelsFromDictionaries:[responseObject objectForKey:@"data"]], [responseObject objectForKey:@"next_max_identifier"]);
        } else {
            completionBlock(YES, [InstafollowersMessage modelsFromDictionaries:[responseObject objectForKey:@"data"]], nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@", operation.responseObject);
        
        if(completionBlock) {
            completionBlock(NO, nil, nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)postTextMessage:(NSString *)message
              receiptor:(NSNumber *)receiptor
                 sender:(NSString *)senderUsername
                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];
    
    NSDictionary *params = @ {
        @"access_token" :accessToken,
        @"receiptor"    :receiptor,
        @"sender_username"    :senderUsername,
        @"type"         :[NSNumber numberWithInt:0],
        @"content"      :message/*[message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]*/,
    };
    
    [self POST:InstafollowersMessagesURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) {
            success(operation, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (success) {
            success(operation, nil);
        }
    }];
    
    //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	//[manager POST:InstafollowersPostMessagesURL parameters:params success:success failure:failure];
}

- (void)updateSessionForUser:(NSNumber *)userId
                  completion:(void(^)(BOOL success))completionBlock
{
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];
    
    NSDictionary *params = @ {
        @"access_token" :accessToken,
        @"user_id"      :userId,
    };
    
    [self GET:InstafollowersUpdateSessionURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            NSString *result = responseObject[@"result"];
            if (result && [result isEqualToString:@"success"]) {
                if (completionBlock) {
                    completionBlock(YES);
                }
                return;
            }
        }
        
        if (completionBlock) {
            completionBlock(NO);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (completionBlock) {
            completionBlock(NO);
        }
    }];
}


- (void)postMultipartFormWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                              type:(NSNumber *)type
                         receiptor:(NSNumber *)receiptor
                            sender:(NSString *)senderUsername
						   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
						   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];
    
    NSDictionary *params = @ {
        @"access_token"     :accessToken,
        @"receiptor"        :receiptor,
        @"type"             :[NSNumber numberWithInt:1],
        @"sender_username"  :senderUsername,
    };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
	AFHTTPRequestOperation *operation = [manager POST:InstafollowersPostMessageURL
                                           parameters:params
							constructingBodyWithBlock:block
											  success:success failure:failure];
    
	[operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
		//float progress = (totalBytesWritten / (float)totalBytesExpectedToWrite);
		//[SVProgressHUD showProgress:progress status:FLPhraseWithKey(@"iflynax+uploading") maskType:SVProgressHUDMaskTypeClear];
	}];
}

- (void)checkUserWithInstagramIdentifier:(NSString *)ig_user_id
                              completion:(void(^)(BOOL success, id result))completionBlock
{
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];
    
    NSDictionary *params = @{
        @"access_token" :accessToken,
        @"ig_user_id"   :ig_user_id,
    };
    
    // Make get request
    [self GET:InstafollowersUserURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        completionBlock(YES, responseObject);
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@", operation.responseString);
        
        if (completionBlock) {
            completionBlock(NO, nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)removeSession:(NSNumber *)user_id
           completion:(void (^)(BOOL success, NSError *error))completionBlock
{
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];
    
    NSDictionary *params = @{
                             @"access_token":accessToken,
                             @"user_id"     :user_id,
                             };
    
    // Make get request
    [self GET:InstafollowersRemoveSessionURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (completionBlock) {
            completionBlock(YES, nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@", operation.responseObject);
        
        if (completionBlock) {
            completionBlock(NO, error);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)postPurchaseStatus:(NSString *)purchased
                completion:(void(^)(BOOL success))completionBlock
{
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];
    
    NSDictionary *params = @{
                             @"access_token":accessToken,
                             @"purchased"   :purchased,
                             };
    
    // Make get request
    [self POST:InstafollowersUserURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (completionBlock) {
            completionBlock(YES);
        }
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@", operation.responseString);
        
        if (completionBlock) {
            completionBlock(NO);
        }
        
    }];
}

- (void)updateCoinsForRateApp:(void(^)(BOOL success))completionBlock
{
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];
    
    NSDictionary *params = @{ @"access_token":accessToken };
    
    // Make get request
    [self POST:InstafollowersPromitionRateAppURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (completionBlock) {
            completionBlock(YES);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@", operation.responseString);
        
        if (completionBlock) {
            completionBlock(NO);
        }
        
    }];
}

- (void)getRatedStatusWithCompletion:(void (^)(BOOL, NSString *))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];
    
    // Make get request
    [self GET:InstafollowersPromitionRateAppURL parameters:@{ @"access_token" : accessToken } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(completionBlock) {
            if([responseObject valueForKey:@"rated"]) {
                completionBlock(YES, [NSString stringWithFormat:@"%@", [responseObject valueForKey:@"rated"]]);
            } else {
                completionBlock(NO, nil);
            }
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, nil);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)updateCoins:(NSNumber *)coins completionBlock:(void(^)(BOOL success, id response))completionBlock
{
    NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];
    
    NSDictionary *params = @{ @"access_token":accessToken, @"coins":coins };
    
    // Make get request
    [self POST:InstafollowersUserCoinsUpdateURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (completionBlock) {
            completionBlock(YES, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@", operation.responseString);
        
        if (completionBlock) {
            completionBlock(NO, nil);
        }
        
    }];
}

@end
