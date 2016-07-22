//
//  DataManagement.m
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/16/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "DataManagement.h"

// Networking
#import "InstagramClient.h"

// Models
#import "InstafollowersProduct.h"
#import "InstafollowersCategory.h"
#import "InstagramMedia.h"
#import "InstagramLike.h"
#import "InstagramComment.h"

// Categories
#import "NSString+Path.h"
#import "NSAttributedString+DataManagement.h"

@interface DataManagement ()

// BOOL values
@property (nonatomic) BOOL relationshipsLoading;
@property (nonatomic) BOOL timelineLoading;
@property (nonatomic) BOOL mediaLoading;
@property (nonatomic) BOOL likedMediaLoading;

@end

@implementation DataManagement

#pragma mark - Singleton intialization

+ (DataManagement *)sharedClient
{
    static DataManagement *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] init];
    });
    
    return _sharedClient;
}

#pragma mark - Logged in user methods

- (InstagramUser *)user
{
    InstagramUser *user = [[InstagramUser alloc] init];
    user.dictionary     = [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramUserDictionary];
    
    return user;
}

- (BOOL)userIsLoggedIn
{
    BOOL userIsLoggedIn;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]) {
        userIsLoggedIn = YES;
    } else {
        userIsLoggedIn = NO;
    }
    
    return userIsLoggedIn;
}

#pragma mark - Logout user

- (void)logoutUser
{
    // Remove user defaults related to the logged in user
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:UserDefaultsKeyInstagramUserDictionary];
    [defaults removeObjectForKey:UserDefaultsKeyInstagramAccessToken];
    
    // Remove any cookies that have been store via instagram's login page
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [[storage cookies] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [storage deleteCookie:(NSHTTPCookie *)obj];
    }];
}

#pragma mark - Products

- (NSArray *)followerProducts
{
    // File path setup
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    // Product and category file path
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"follower_products.json"];
    
    // Products array to be populated
    NSArray *products;
    
    // If the file does not exist, open the file from the bundled follower products file
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        NSString *packagedPath = [[NSBundle mainBundle] pathForResource:@"packaged_follower_products" ofType:@"json"];
        
        products =[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:packagedPath]
                                                  options:NSJSONReadingMutableContainers
                                                    error:nil];
        
        
    } else {
        
        products = [NSArray arrayWithContentsOfFile:filePath];

    }
    
    // Sort followers
    NSSortDescriptor *sortDescriptor
    = [[NSSortDescriptor alloc] initWithKey:@"followers"
                                  ascending:YES
                                   selector:@selector(localizedStandardCompare:)];
    
    NSArray *sortedProducts = [products sortedArrayUsingDescriptors:@[ sortDescriptor ]];
    
    products = [InstafollowersProduct modelsFromDictionaries:sortedProducts];
    
    // Return products
    return products;
}

#pragma mark - Categories

- (NSArray *)categories
{
    // File path setup
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    // Product and category file path
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"categories.json"];
    
    // Products array to be populated
    NSArray *categories;
    
    // If the file does not exist, open the file from the bundled follower products file
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        NSString *packagedPath = [[NSBundle mainBundle] pathForResource:@"packaged_categories" ofType:@"json"];
        
        categories =[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:packagedPath]
                                                    options:NSJSONReadingMutableContainers
                                                      error:nil];
        
    } else {
        
        categories = [NSArray arrayWithContentsOfFile:filePath];
        
    }
    
    // Sort categories
    NSSortDescriptor *sortDescriptor
    = [[NSSortDescriptor alloc] initWithKey:@"title"
                                  ascending:YES
                                   selector:@selector(localizedStandardCompare:)];
    
    NSArray *sortedProducts = [categories sortedArrayUsingDescriptors:@[ sortDescriptor ]];
    
    categories = [InstafollowersCategory modelsFromDictionaries:sortedProducts];
    
    // Return categories
    return categories;
}

#pragma mark - Failed transactions

- (NSArray *)failedTransactions
{
    NSString *key = [NSString stringWithFormat:@"%@%@", UserDefaultsKeyFailedTransactionsStringFormat, self.user.identifier];
    
    NSArray *failedTransactions = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    return failedTransactions;
}

- (void)addFailedTransactionWithReceiptIdentifier:(NSString *)receiptIdentifier
{
    NSString *key = [NSString stringWithFormat:@"%@%@", UserDefaultsKeyFailedTransactionsStringFormat, self.user.identifier];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *failedTransactions = [NSMutableArray arrayWithArray:[defaults objectForKey:key]];
    
    [failedTransactions addObject:receiptIdentifier];
    
    [defaults setObject:failedTransactions forKey:key];
}

- (void)removeFailedTransactionWithReceiptIdentifier:(NSString *)receiptIdentifier
{
    NSString *key = [NSString stringWithFormat:@"%@%@", UserDefaultsKeyFailedTransactionsStringFormat, self.user.identifier];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *failedTransactions = [NSMutableArray arrayWithArray:[defaults objectForKey:key]];
    
    [failedTransactions removeObject:receiptIdentifier];
    
    [defaults setObject:failedTransactions forKey:key];
}

#pragma mark - Code Readability Networking Completion Methods

- (void)getAllRelationshipsWithCompletion:(void (^)(BOOL success,
                                                     NSArray *followers,
                                                     NSArray *followerIdentifiers,
                                                     NSArray *following,
                                                     NSArray *followingIdentifiers))completionBlock
{
    // Arrays to store relationships
    __block NSArray *followers;
    __block NSArray *followerIdentifiers;
    __block NSArray *following;
    __block NSArray *followingIdentifiers;
    
    // Failure BOOL check
    __block BOOL failure = NO;
    
    // Load relationships
    [[InstagramClient sharedClient] getAllRelationshipsForUserIdentifier:@"self"
                                                   relationshipSelection:SelectionFollowers
                                                              completion:^(BOOL success, NSArray *allUsers, NSArray *allUserIdentifiers)
    {
        
        // Already failed, return
        if(failure)
            return;
        
        // Set followers
        followers           = allUsers;
        followerIdentifiers = allUserIdentifiers;
        
        if(success) {
            
            // Return completion block
            if(followers && followerIdentifiers && following && followingIdentifiers && completionBlock) {
                completionBlock(YES, followers, followerIdentifiers, following, followingIdentifiers);
            }
            
        } else if(!success) {
            
            // Set failure
            failure = YES;
            
            // Return completion block with failure
            if(completionBlock) {
                completionBlock(NO, nil, nil, nil, nil);
            }
            
        }

    }];
    
    [[InstagramClient sharedClient] getAllRelationshipsForUserIdentifier:@"self"
                                                   relationshipSelection:SelectionFollowing
                                                              completion:^(BOOL success, NSArray *allUsers, NSArray *allUserIdentifiers)
    {
        
        // Already failed, return
        if(failure)
            return;
        
        // Set followers
        following            = allUsers;
        followingIdentifiers = allUserIdentifiers;
        
        if(success) {
            
            // Return completion block
            if(followers && followerIdentifiers && following && followingIdentifiers && completionBlock) {
                completionBlock(YES, followers, followerIdentifiers, following, followingIdentifiers);
            }
            
        } else if(!success) {
            
            // Set failure
            failure = YES;
            
            // Return completion block with failure
            if(completionBlock) {
                completionBlock(NO, nil, nil, nil, nil);
            }
            
        }

    }];
}

#pragma mark - Update methods

- (void)startUpdating
{
    // If already loading, return
    if(self.relationshipsLoading) {
        return;
    }
    
    // Set all methods as loading
    self.relationshipsLoading = YES;
    
    // Post notifications
    [[NSNotificationCenter defaultCenter] postNotificationName:RelationshipsChanged object:[NSNumber numberWithInt:UpdateBegan]];
    [[NSNotificationCenter defaultCenter] postNotificationName:TimelineChanged      object:[NSNumber numberWithInt:UpdateBegan]];
    [[NSNotificationCenter defaultCenter] postNotificationName:LikedMediaChanged    object:[NSNumber numberWithInt:UpdateBegan]];
    [[NSNotificationCenter defaultCenter] postNotificationName:MediaChanged         object:[NSNumber numberWithInt:UpdateBegan]];

    // Get all relationships
    [self getAllRelationshipsWithCompletion:^(BOOL success,
                                               NSArray *followers,
                                               NSArray *followerIdentifiers,
                                               NSArray *following,
                                               NSArray *followingIdentifiers)
     {
         
         // If there was no success,
         // return and end method
         if(!success) {
             
             // Failure, not loading any further
             self.relationshipsLoading = NO;
 
             // Post notification for relationships changed
             [[NSNotificationCenter defaultCenter] postNotificationName:RelationshipsChanged object:[NSNumber numberWithInt:UpdateFailed]];
             [[NSNotificationCenter defaultCenter] postNotificationName:TimelineChanged      object:[NSNumber numberWithInt:UpdateFailed]];
             [[NSNotificationCenter defaultCenter] postNotificationName:LikedMediaChanged    object:[NSNumber numberWithInt:UpdateFailed]];
             [[NSNotificationCenter defaultCenter] postNotificationName:MediaChanged         object:[NSNumber numberWithInt:UpdateFailed]];
             
             return;
             
         }
         
         // Setup for changes
         __block InstagramUser *user = self.user;
         
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         
         NSString *defaultsKeyLastUpdated = [NSString stringWithFormat:UserDefaultsKeyLastUpdatedStringFormat, user.identifier];
         
         NSDate *lastUpdated = [defaults objectForKey:defaultsKeyLastUpdated];
         
         // Paths for followers and following
         NSString *followersPath = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameFollowersFormat, user.identifier]];
         NSString *followingPath = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameFollowingFormat, user.identifier]];
         

         dispatch_async(kBgQueue, ^{
         
         // Que: Save users with no duplicates
         
         // Users setup
         NSString *usersPath = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameUsersFormat, user.identifier]];
         
         // Combine followers and following arrays to create one array
         NSMutableArray *combineFollowersAndFollowing = [NSMutableArray arrayWithArray:followers];
         [combineFollowersAndFollowing addObjectsFromArray:following];
         
         // Remove duplicates
         NSArray *newUsers = [[NSOrderedSet orderedSetWithArray:combineFollowersAndFollowing] array];
         
         // Get past users from file
         NSArray *pastUsers = [NSArray arrayWithContentsOfFile:usersPath];
         
         // Update users file
         NSArray *users = [self usersWithNewUsers:newUsers pastUsers:pastUsers];
         
         [users writeToFile:usersPath atomically:YES];
         
         // Que: Calculate unfollowers
         // and save to file
         
         NSString *defaultsKeyUnfollowerRecent = [NSString stringWithFormat:UserDefaultsKeyUnfollowersRecentCountStringFormat, user.identifier];
         NSString *defaultsKeyUnfollowerTotal  = [NSString stringWithFormat:UserDefaultsKeyUnfollowersTotalCountStringFormat, user.identifier];
         
         if(lastUpdated) {
             
             // If the user has updated in the past,
             // proceed to calculate unfollowers
             
             // Unfollowers
             NSString *unfollowersPath = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameUnfollowersFormat, user.identifier]];
             
             NSArray *previousUnfollowers = [NSArray arrayWithContentsOfFile:unfollowersPath];
             
             // Unfollowers array that will be saved
             NSMutableArray *unfollowers = [NSMutableArray arrayWithArray:previousUnfollowers];
             
             // Remove objects that are now followers (unfollower re-followed the user case)
             [previousUnfollowers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                 
                 // Remove the object from unfollowers
                 if([followerIdentifiers containsObject:[obj objectForKey:@"id"]]) {
                     [unfollowers removeObject:obj];
                 }
                 
             }];
             
             // Calculate unfollowers
             NSArray *previousFollowerIdentifiers = [NSArray arrayWithContentsOfFile:followersPath];
             
             NSMutableArray *unfollowerIdentifiers = [[NSMutableArray alloc] initWithArray:previousFollowerIdentifiers];
             [unfollowerIdentifiers removeObjectsInArray:followerIdentifiers];
             
             // Add date object to unfollowers
             NSDate *date = [NSDate date];
             
             [unfollowerIdentifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                 [unfollowers addObject:@{ @"id" : obj, @"date" : date }];
             }];
             
             // Save
             [unfollowers writeToFile:unfollowersPath atomically:YES];
             
             // Set user defaults
             [defaults setObject:[NSNumber numberWithInteger:unfollowers.count]           forKey:defaultsKeyUnfollowerTotal];
             [defaults setObject:[NSNumber numberWithInteger:unfollowerIdentifiers.count] forKey:defaultsKeyUnfollowerRecent];
             
         } else {
             
             // The user has never calculated unfollowers
             // Return 0 for recent and total
             [defaults setObject:[NSNumber numberWithInteger:0] forKey:defaultsKeyUnfollowerRecent];
             [defaults setObject:[NSNumber numberWithInteger:0] forKey:defaultsKeyUnfollowerTotal];
             
         }
         
         
         // Que: Calculate unfollowed
         // and save to file
         
         NSString *defaultsKeyUnfollowedRecent = [NSString stringWithFormat:UserDefaultsKeyUnfollowedRecentCountStringFormat, user.identifier];
         NSString *defaultsKeyUnfollowedTotal  = [NSString stringWithFormat:UserDefaultsKeyUnfollowedTotalCountStringFormat, user.identifier];
         
         if(lastUpdated) {
             
             // If the user has updated in the past,
             // proceed to calculate unfollowed users
             
             // Unfollowed
             NSString *unfollowedPath = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameUnfollowedFormat, user.identifier]];
             
             NSArray *previousUnfollowed = [NSArray arrayWithContentsOfFile:unfollowedPath];
             
             // Unfollowed array that will be saved
             NSMutableArray *unfollowed = [NSMutableArray arrayWithArray:previousUnfollowed];
             
             // Remove objects that the user is now now following (unfollowed re-followed)
             [previousUnfollowed enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                 
                 // Remove the object from unfollowers
                 if([followingIdentifiers containsObject:[obj objectForKey:@"id"]]) {
                     [unfollowed removeObject:obj];
                 }
                 
             }];
             
             // Calculate unfollowed
             NSArray *previousFollowedIdentifiers = [NSArray arrayWithContentsOfFile:followingPath];
             
             NSMutableArray *unfollowedIdentifiers = [[NSMutableArray alloc] initWithArray:previousFollowedIdentifiers];
             [unfollowedIdentifiers removeObjectsInArray:followingIdentifiers];
             
             // Add date object to unfollowed
             NSDate *date = [NSDate date];
             
             [unfollowedIdentifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                 [unfollowed addObject:@{ @"id" : obj, @"date" : date }];
             }];
             
             // Save
             [unfollowed writeToFile:unfollowedPath atomically:YES];
             
             // Set user defaults
             [defaults setObject:[NSNumber numberWithInteger:unfollowed.count]            forKey:defaultsKeyUnfollowedTotal];
             [defaults setObject:[NSNumber numberWithInteger:unfollowedIdentifiers.count] forKey:defaultsKeyUnfollowedRecent];
             
         } else {
             
             // The user has never calculated unfollowed
             // Return 0 for recent and total
             [defaults setObject:[NSNumber numberWithInteger:0] forKey:defaultsKeyUnfollowedRecent];
             [defaults setObject:[NSNumber numberWithInteger:0] forKey:defaultsKeyUnfollowedTotal];
             
         }
         
         // Que: Calculate new followers
         // and save to file
         
         NSString *defaultsKeyNewFollowerRecent = [NSString stringWithFormat:UserDefaultsKeyNewFollowersRecentCountStringFormat, user.identifier];
         NSString *defaultsKeyNewFollowerTotal  = [NSString stringWithFormat:UserDefaultsKeyNewFollowersTotalCountStringFormat, user.identifier];
         
         if(lastUpdated) {
             
             // Paths (new cannot start pointers in objective-c with ARC)
             NSString *nFollowersPath
             = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameNewFollowersFormat, user.identifier]];
             
             // New followers setup
             NSArray *previousFollowerIdentifiers = [NSArray arrayWithContentsOfFile:followersPath];
             
             NSArray *previousNewFollowers = [NSArray arrayWithContentsOfFile:nFollowersPath];
             
             // New followers array that will be saved
             NSMutableArray *nFollowers = [NSMutableArray arrayWithArray:previousNewFollowers];
             
             // If a previous new follower unfollowed this user, remove that user from new followers
             [previousNewFollowers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                 
                 // Remove the object from new followers
                 if(![followerIdentifiers containsObject:[obj objectForKey:@"id"]]) {
                     [nFollowers removeObject:obj];
                 }
                 
             }];
             
             // Calclulate new followers
             NSMutableArray *nFollowerIdentifiers = [[NSMutableArray alloc] initWithArray:followerIdentifiers];
             [nFollowerIdentifiers removeObjectsInArray:previousFollowerIdentifiers];
             
             // Add date object to unfollowers
             NSDate *date = [NSDate date];
             
             [nFollowerIdentifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                 [nFollowers addObject:@{ @"id" : obj, @"date" : date }];
             }];
             
             // Save
             [nFollowers writeToFile:nFollowersPath atomically:YES];
             
             // Set user defaults
             [defaults setObject:[NSNumber numberWithInteger:nFollowers.count]           forKey:defaultsKeyNewFollowerTotal];
             [defaults setObject:[NSNumber numberWithInteger:nFollowerIdentifiers.count] forKey:defaultsKeyNewFollowerRecent];
             
         } else {
             
             // The user has never calculated new followers
             // Return 0 for recent and total
             [defaults setObject:[NSNumber numberWithInteger:0] forKey:defaultsKeyNewFollowerTotal];
             [defaults setObject:[NSNumber numberWithInteger:0] forKey:defaultsKeyNewFollowerRecent];
             
         }
         

         // Que: Fans
         
         // Calculate fans
         NSMutableArray *fans = [[NSMutableArray alloc] initWithArray:followerIdentifiers];
         [fans removeObjectsInArray:followingIdentifiers];
         
         // Path to save
         NSString *fansPath = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameFansFormat, user.identifier]];
         
         // Save
         [fans writeToFile:fansPath atomically:YES];
         
         // Set user defaults
         [defaults setObject:[NSNumber numberWithInteger:fans.count]
                      forKey:[NSString stringWithFormat:UserDefaultsKeyFansCountStringFormat, user.identifier]];
         
         
         // Que: Non followers
         
         // Calculate non followers
         NSMutableArray *nonFollowers = [[NSMutableArray alloc] initWithArray:followingIdentifiers];
         [nonFollowers removeObjectsInArray:followerIdentifiers];
         
         // Path to save
         NSString *nonFollowersPath = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameNonFollowersFormat, user.identifier]];
         
         // Save
         [nonFollowers writeToFile:nonFollowersPath atomically:YES];
         
         // Set user defaults
         [defaults setObject:[NSNumber numberWithInteger:nonFollowers.count]
                      forKey:[NSString stringWithFormat:UserDefaultsKeyNonFollowersCountStringFormat, user.identifier]];

         
         // Que: Mutual friends

         // Calculate mutual friends
         NSMutableSet *intersectFollowersAndFollowing = [NSMutableSet setWithArray:followerIdentifiers];
         [intersectFollowersAndFollowing intersectSet:[NSSet setWithArray:followingIdentifiers]];
         
         NSArray *mutualFriends = [intersectFollowersAndFollowing allObjects];
         
         // Path to save
         NSString *mutualFriendsPath = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameMutualFriendsFormat, user.identifier]];
         
         // Save
         [mutualFriends writeToFile:mutualFriendsPath atomically:YES];
         
         // Set user defaults
         [defaults setObject:[NSNumber numberWithInteger:mutualFriends.count]
                      forKey:[NSString stringWithFormat:UserDefaultsKeyMutualFriendsCountStringFormat, user.identifier]];

         // Que: save followers and following
         // This takes place last because
         // we need the old follower and following
         // identifiers to calculate new followers
         // and unfollowers
         
         // Save followers and following
         [followerIdentifiers  writeToFile:followersPath  atomically:YES];
         [followingIdentifiers writeToFile:followingPath atomically:YES];
         
         
             // Update last updated to current date
             [defaults setObject:[NSDate date] forKey:defaultsKeyLastUpdated];
             
             // Set relationships to no longer loading
             self.relationshipsLoading = NO;
             
             // Make main thread changes
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 // Post notification
                 [[NSNotificationCenter defaultCenter] postNotificationName:RelationshipsChanged object:[NSNumber numberWithInt:UpdateEnded]];
                 
                 // Relay other changes
                 [self updateTimeline];
                 [self updateMedia];
                 
             });
         });
         
     }];
}

- (void)updateTimeline
{
    if(self.timelineLoading)
        return;
    
    // Timeline loading
    self.timelineLoading = YES;
    
    // Get timeline locations
    [[InstagramClient sharedClient] getTimelineWithLocationsCount:30
                                                      maxRequests:10
                                                       completion:^(BOOL success, NSArray *mediaItems)
    {
        
        if(success) {
            
            dispatch_async(kBgQueue, ^{

                // Location objects that will be saved
                NSMutableArray *locationObjects = [NSMutableArray array];
                
                // Iterate over media objects and create an array of dictionary objects
                [mediaItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    // Latitude and longitude as numbers
                    NSNumber *latitude  = [NSNumber numberWithDouble:[(InstagramMedia *)obj location].coordinate.latitude];
                    NSNumber *longitude = [NSNumber numberWithDouble:[(InstagramMedia *)obj location].coordinate.longitude];
                    
                    NSDictionary *dictionary
                    = @{ @"latitude" : latitude, @"longitude" : longitude, @"id" : [(InstagramMedia *)obj user].identifier };
                    
                    [locationObjects addObject:dictionary];
                    
                }];
                
                // Path to save
                NSString *path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNamePostLocationsFormat, self.user.identifier]];
                
                // Save
                [locationObjects writeToFile:path atomically:YES];
                
                // Notify main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Set relationships no longer loading
                    self.timelineLoading = NO;
                    
                    // Post notification
                    [[NSNotificationCenter defaultCenter] postNotificationName:TimelineChanged object:[NSNumber numberWithInt:UpdateEnded]];

                });

            });
            
        } else {
            
            // Failure
            // Set relationships no longer loading
            self.timelineLoading = NO;
            
            // Post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:TimelineChanged object:[NSNumber numberWithInt:UpdateFailed]];

        }
        
    }];
    
}

- (void)updateMedia
{
    if(self.mediaLoading)
        return;
    
    // Media loading
    self.mediaLoading = YES;
    
    // getAllMediaForUserIdentifier: Loads all media and associated comment and like data
    [[InstagramClient sharedClient] getAllMediaForUserIdentifier:@"self" completion:^(BOOL success, NSArray *allMediaItems) {

        if(!success) {
            
            // Set media and liked no longer loading
            self.mediaLoading = NO;
            
            // Post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:MediaChanged object:[NSNumber numberWithInt:UpdateFailed]];
            
            return;
            
        }
        
        dispatch_async(kBgQueue, ^{

            // Setup for calculations
            __block NSMutableArray *likers           = [NSMutableArray array];
            __block NSMutableArray *commenters       = [NSMutableArray array];
            __block NSMutableArray *admirersLikes    = [NSMutableArray array];
            __block NSMutableArray *admirersComments = [NSMutableArray array];
            
            __block NSMutableArray *users = [NSMutableArray array];
            
            // Follower identifiers
            NSString *followersPath      = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameFollowersFormat, self.user.identifier]];
            NSArray *followerIdentifiers = [NSArray arrayWithContentsOfFile:followersPath];

            // Que: Likes by user id, comments by user id,
            // admirers by user id
            
            // Enumerate over media objects
            [allMediaItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                // Likes (this returns user objects)
                [[(InstagramMedia *)obj likeData] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    [likers addObject:[obj identifier]];
                    
                    // If like the like identifier is not a follower, add the user as an admirer and user to be updated
                    if(![followerIdentifiers containsObject:[obj identifier]]) {
                        [admirersLikes addObject:[obj identifier]];
                        [users addObject:[(InstagramLike *)obj dictionary]];
                    }
                    
                }];
                
                // Comments
                [[(InstagramMedia *)obj commentData] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    [commenters addObject:[(InstagramComment *)obj userIdentifier]];
                    
                    // If commenter identifier is not a follower, add the user as an admirer and user to be updated
                    if(![followerIdentifiers containsObject:[(InstagramComment *)obj userIdentifier]]) {
                        [admirersComments addObject:[(InstagramComment *)obj userIdentifier]];
                        [users addObject:[(InstagramComment *)obj from]];
                    }
                    
                }];
                
            }];
            
            // Que: remove all identifiers that match the logged in users identifiers
            
            [commenters       removeObject:self.user.identifier];
            [admirersComments removeObject:self.user.identifier];
            [likers           removeObject:self.user.identifier];
            [admirersLikes    removeObject:self.user.identifier];
            
            // Que: Count sets by user id for likes, comments

            // Counted sets for likers and commeters
            NSCountedSet *likersCountedSet     = [[NSCountedSet alloc] initWithArray:likers];
            NSCountedSet *commentersCountedSet = [[NSCountedSet alloc] initWithArray:commenters];
            
            // Combine identifiers
            NSMutableArray *combinedIdentifiers = [NSMutableArray arrayWithArray:commenters];
            [combinedIdentifiers addObjectsFromArray:likers];
            [combinedIdentifiers addObjectsFromArray:followerIdentifiers];
            
            // Identifiers without duplicates
            NSArray *identifiers = [[NSSet setWithArray:combinedIdentifiers] allObjects];
            
            // Likes and comments
            NSMutableArray *likesAndComments = [NSMutableArray array];
            
            // Enumerate and construct dictionaries from counted sets
            [identifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                NSInteger likes    = [likersCountedSet     countForObject:obj];
                NSInteger comments = [commentersCountedSet countForObject:obj];

                NSDictionary *dictionary = @{ @"id"       : obj,
                                              @"comments" : @(comments),
                                              @"likes"    : @(likes),
                                              @"total"    : @(likes + comments) };
                
                [likesAndComments addObject:dictionary];
                
            }];
            
            // Save to file
            NSString *likesAndCommentsPath
            = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameCommentsAndLikesFormat, self.user.identifier]];

            [likesAndComments writeToFile:likesAndCommentsPath atomically:YES];

            // Que: Count sets by admirers user id for likes, comments

            NSCountedSet *admirersLikesCountedSet    = [[NSCountedSet alloc] initWithArray:admirersLikes];
            NSCountedSet *admirersCommentsCountedSet = [[NSCountedSet alloc] initWithArray:admirersComments];

            // Combine identifiers
            NSMutableArray *combinedAdmirerIdentifiers = [NSMutableArray arrayWithArray:admirersComments];
            [combinedAdmirerIdentifiers addObjectsFromArray:admirersLikes];
            
            // Identifiers without duplicates
            NSArray *admirerIdentifiers = [[NSSet setWithArray:combinedAdmirerIdentifiers] allObjects];
            
            // Likes and comments
            NSMutableArray *admirerLikesAndComments = [NSMutableArray array];
            
            // Enumerate and construct dictionaries from counted sets
            [admirerIdentifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                NSInteger likes    = [admirersLikesCountedSet    countForObject:obj];
                NSInteger comments = [admirersCommentsCountedSet countForObject:obj];
                
                NSDictionary *dictionary = @{ @"id"       : obj,
                                              @"comments" : @(comments),
                                              @"likes"    : @(likes),
                                              @"total"    : @(likes + comments) };
                
                [admirerLikesAndComments addObject:dictionary];
                
            }];
            
            // Save to file
            NSString *secretAdmirersPath
            = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameSecredAdmirersFormat, self.user.identifier]];
            
            [admirerLikesAndComments writeToFile:secretAdmirersPath atomically:YES];
            
            // Que: Save users

            if(users.count > 0) {
                
                // Update users
                NSString *usersPath
                = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameUsersFormat, self.user.identifier]];
                
                NSArray *pastUsers = [NSArray arrayWithContentsOfFile:usersPath];
                
                [[self usersWithNewUsers:users pastUsers:pastUsers] writeToFile:usersPath atomically:YES];
                
            }
            
            // Notify main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Set media no longer loading
                self.mediaLoading = NO;
                
                // Post notifications
                [[NSNotificationCenter defaultCenter] postNotificationName:MediaChanged object:[NSNumber numberWithInt:UpdateEnded]];
                
                // Relay other changes
                [self updateLikedMedia];
                
            });

        });
    
    }];
}

- (void)updateLikedMedia
{
    if(self.likedMediaLoading)
        return;
    
    // Liked media loading
    self.likedMediaLoading = YES;
    
    [[InstagramClient sharedClient] getAllLikesForUserIdentifier:@"self" completion:^(BOOL success, NSArray *allLikes) {
        
        // If there was no success,
        // return completion block
        // and end method
        if(!success) {
            return;
            
            // Set relationships no longer loading
            self.likedMediaLoading = NO;
            
            // Post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:LikedMediaChanged object:[NSNumber numberWithInt:UpdateFailed]];
            
            return;
        }
        
        dispatch_async(kBgQueue, ^{
            
            // Array setup
            NSMutableArray *users                          = [NSMutableArray array];
            NSMutableArray *likedIdentifiers               = [NSMutableArray array];
            NSMutableArray *likedButDoNotFollowIdentifiers = [NSMutableArray array];
            
            // Following
            NSString *followingPath       = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameFollowingFormat, self.user.identifier]];
            NSArray *followingIdentifiers = [NSArray arrayWithContentsOfFile:followingPath];
            
            [allLikes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                // If the user has not been added to the users array, add it
                if(![users containsObject:[[(InstagramLike *)obj likedUser] dictionary]]) {
                    [users addObject:[[(InstagramLike *)obj likedUser] dictionary]];
                }
                
                // Add liked identifier to liked identifiers, if we follow that user
                if([followingIdentifiers containsObject:[(InstagramLike *)obj likedUser].identifier] ) {
                    [likedIdentifiers addObject:[(InstagramLike *)obj likedUser].identifier];
                } else { // otherwise add it to, liked but do not follow identifiers
                    [likedButDoNotFollowIdentifiers addObject:[(InstagramLike *)obj likedUser].identifier];
                }
                
            }];
            
            // Create array of liked identifiers
            NSCountedSet *likedIdentifiersSet = [[NSCountedSet alloc] initWithArray:likedIdentifiers];
            
            NSMutableArray *likeDictionaryArray = [NSMutableArray array];
            [likedIdentifiersSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                [likeDictionaryArray addObject:@{@"id": obj,
                                              @"count": @([likedIdentifiersSet countForObject:obj])}];
            }];
            
            // Create array of liked identifiers that we do not follow
            NSCountedSet *likedButDoNotFollowIdentifiersArraySet = [[NSCountedSet alloc] initWithArray:likedButDoNotFollowIdentifiers];
            
            NSMutableArray *likedButDoNotFollowIdentifiersArrayDictionaryArray = [NSMutableArray array];
            [likedButDoNotFollowIdentifiersArraySet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                [likedButDoNotFollowIdentifiersArrayDictionaryArray addObject:@{@"id"    : obj,
                                                                                @"count" : @([likedButDoNotFollowIdentifiersArraySet countForObject:obj])}];
            }];
            
            // If there are results for likeDictionaryArray, save
            if(likeDictionaryArray.count > 0) {
                
                // Path to save
                NSString *path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameFavoriteUsersFormat, self.user.identifier]];
                
                // Save
                [[likeDictionaryArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO]]] writeToFile:path atomically:YES];
                
            }
            
            // If there are results for likedButDoNotFollowIdentifiersArrayDictionaryArray, save
            if(likedButDoNotFollowIdentifiersArrayDictionaryArray.count > 0) {
                
                // Path to save
                NSString *path
                = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameLikedDoNotFollowUsersFormat, self.user.identifier]];
                
                // Save
                [[likedButDoNotFollowIdentifiersArrayDictionaryArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO]]] writeToFile:path atomically:YES];
                
            }
            
            // If there are users to save, make save
            if(users.count > 0) {
                
                // Update users
                NSString *usersPath
                = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameUsersFormat, self.user.identifier]];
                
                NSArray *pastUsers = [NSArray arrayWithContentsOfFile:usersPath];
                
                [[self usersWithNewUsers:users pastUsers:pastUsers] writeToFile:usersPath atomically:YES];
                
            }
            
            // Notify main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Set relationships no longer loading
                self.likedMediaLoading = NO;
                
                // Post notification
                [[NSNotificationCenter defaultCenter] postNotificationName:LikedMediaChanged object:[NSNumber numberWithInt:UpdateEnded]];
                
            });
            
        });
        
    }];
}


#pragma mark - Users

- (NSArray *)usersWithNewUsers:(NSArray *)newUsers pastUsers:(NSArray *)pastUsers
{
    // All users
    __block NSMutableArray *allUsers = [NSMutableArray arrayWithArray:pastUsers];
    
    // Enumerate over combined array to check:
    // if the object already exists
    // if it does, check if it needs any updating
    // if it does not, add it
    [newUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        // Filter through users for current state in array
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", [obj valueForKey:@"id"]];
        NSArray *filteredUsers = [allUsers filteredArrayUsingPredicate:predicate];
        
        if(filteredUsers.count == 1) { // Update the object
            
            [allUsers replaceObjectAtIndex:[allUsers indexOfObject:[filteredUsers lastObject]] withObject:obj];
            
        } else if(filteredUsers.count == 0) { // Add the object
            
            [allUsers addObject:obj];
            
        } else if(filteredUsers.count > 1) { // Remove duplicates, if for whatever reason there is one
            
            // Remove filtered users
            [filteredUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [allUsers removeObject:obj];
            }];
            
            // Add new object
            [allUsers addObject:obj];
            
        }
        
    }];
    
    return allUsers;
}

#pragma mark - BOOL relationship values

- (BOOL)selectionLoading:(Selection)selection
{
    BOOL loading;

    if(selection == SelectionUnfollowers
       || selection == SelectionNewFollowers
       || selection == SelectionFans
       || selection == SelectionMutualFriends
       || selection == SelectionNonFollowers
       || selection == SelectionNewestUsers
       || selection == SelectionOldestUsers) { // Relationships loading
        loading = self.relationshipsLoading;
    } else if(selection == SelectionMostLikes
              || selection == SelectionLeastLikes
              || selection == SelectionMostComments
              || selection == SelectionLeastComments
              || selection == SelectionMostCommentsAndLikes
              || selection == SelectionLeastCommentsAndLikes
              || selection == SelectionSecretAdmirers) { // Media loading
        if(self.mediaLoading || self.relationshipsLoading) {
            loading = YES;
        } else {
            loading = NO;
        }
    } else if(selection == SelectionFavoriteUsers
           || selection == SelectionLikedDoNotFollow) { // Liked media
        if(self.mediaLoading || self.timelineLoading || self.relationshipsLoading || self.likedMediaLoading) {
            loading = YES;
        } else {
            loading = NO;
        }
    } else { // Timeline loading
        if(self.relationshipsLoading || self.timelineLoading) {
            loading = YES;
        } else {
            loading = NO;
        }
    }

    return loading;
}

- (BOOL)selectionFileExists:(Selection)selection
{
    NSString *path;
    if(selection == SelectionNonFollowers) {
        path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameNonFollowersFormat, self.user.identifier]];
    } else if(selection == SelectionMutualFriends) {
        path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameMutualFriendsFormat, self.user.identifier]];
    } else if(selection == SelectionFans) {
        path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameFansFormat, self.user.identifier]];
    } else if(selection == SelectionUnfollowers) {
        path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameUnfollowersFormat, self.user.identifier]];
    } else if(selection == SelectionNewFollowers) {
        path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameNewFollowersFormat, self.user.identifier]];
    } else if(selection == SelectionMostComments
              || selection == SelectionMostLikes
              || selection == SelectionMostCommentsAndLikes
              || selection == SelectionLeastComments
              || selection == SelectionLeastLikes
              || selection == SelectionLeastCommentsAndLikes) {
        path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameCommentsAndLikesFormat, self.user.identifier]];
    } else if(selection == SelectionFavoriteUsers) {
        path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameFavoriteUsersFormat, self.user.identifier]];
    } else if(selection == SelectionLikedDoNotFollow) {
        path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameLikedDoNotFollowUsersFormat, self.user.identifier]];
    } else if(selection == SelectionSecretAdmirers) {
        path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameSecredAdmirersFormat, self.user.identifier]];
    } else if(selection == SelectionNearby || selection == SelectionFarAway) {
        path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNamePostLocationsFormat, self.user.identifier]];
    } else if(selection == SelectionNewestUsers || selection == SelectionOldestUsers) {
        path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameUsersFormat, self.user.identifier]];
    }
    
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

#pragma mark - Users

- (void)usersForIdentifiers:(NSArray *)identifiers
                    asModel:(BOOL)asModel
                 completion:(void (^)(NSArray *users))completionBlock
{
    // Compound predicates array
    NSMutableArray *predicates = [NSMutableArray array];
    
    // All users array
    NSString *usersPath = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameUsersFormat, self.user.identifier]];
    NSArray *allUsers   = [NSArray arrayWithContentsOfFile:usersPath];
    
    // Iterate over identifiers
    [identifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        // Add predicate
        [predicates addObject:[NSPredicate predicateWithFormat:@"id == %@", obj]];
        
    }];
    
    // Sort in alphabetical order
    NSArray *filteredUsers = [allUsers filteredArrayUsingPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:predicates]];
    filteredUsers          = [filteredUsers sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES] ]];

    // Return completion block
    if(completionBlock) {
        if(asModel) {
            completionBlock([InstagramUser modelsFromDictionaries:filteredUsers]);
        } else {
            completionBlock(filteredUsers);
        }
    }
}

- (void)usersForSelection:(Selection)selection
               completion:(void (^)(NSArray *users, Selection selection))completionBlock
{
    dispatch_async(kBgQueue, ^{
        
        if(selection == SelectionNonFollowers
        || selection == SelectionMutualFriends
        || selection == SelectionFans) {
            
            // File path
            NSString *path;
            if(selection == SelectionNonFollowers) {
                path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameNonFollowersFormat, self.user.identifier]];
            } else if(selection == SelectionMutualFriends) {
                path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameMutualFriendsFormat, self.user.identifier]];
            } else if(selection == SelectionFans) {
                path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameFansFormat, self.user.identifier]];
            }
            
            // Request array from file path
            NSArray *identifiers = [NSArray arrayWithContentsOfFile:path];
            
            // Request users
            [self usersForIdentifiers:identifiers asModel:YES completion:^(NSArray *users) {
                
                // Return on main thread
                if(completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(users, selection);
                    });
                }
                
            }];
            
        } else if(selection == SelectionUnfollowers
               || selection == SelectionNewFollowers
               || selection == SelectionMostComments
               || selection == SelectionMostLikes
               || selection == SelectionMostCommentsAndLikes
               || selection == SelectionLeastCommentsAndLikes
               || selection == SelectionLeastLikes
               || selection == SelectionLeastComments
               || selection == SelectionFavoriteUsers
               || selection == SelectionLikedDoNotFollow
               || selection == SelectionSecretAdmirers
               || selection == SelectionUnfollowed) {
            
            // File path
            NSString *path;
            if(selection == SelectionUnfollowers) {
                path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameUnfollowersFormat, self.user.identifier]];
            } else if(selection == SelectionNewFollowers) {
                path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameNewFollowersFormat, self.user.identifier]];
            } else if(selection == SelectionMostComments
                   || selection == SelectionMostLikes
                   || selection == SelectionMostCommentsAndLikes
                   || selection == SelectionLeastComments
                   || selection == SelectionLeastLikes
                   || selection == SelectionLeastCommentsAndLikes) {
                path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameCommentsAndLikesFormat, self.user.identifier]];
            } else if(selection == SelectionFavoriteUsers) {
                path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameFavoriteUsersFormat, self.user.identifier]];
            } else if(selection == SelectionLikedDoNotFollow) {
                path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameLikedDoNotFollowUsersFormat, self.user.identifier]];
            } else if(selection == SelectionSecretAdmirers) {
                path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameSecredAdmirersFormat, self.user.identifier]];
            } else if(selection == SelectionUnfollowed) {
                path = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameUnfollowedFormat, self.user.identifier]];
            }
            
            // Request array from file path
            NSArray *array = [NSArray arrayWithContentsOfFile:path];
            
            NSArray *identifiers = [array valueForKey:@"id"];
            
            // Get user objects from identifiers
            [self usersForIdentifiers:identifiers asModel:YES completion:^(NSArray *users) {
                
                if(selection == SelectionUnfollowers || selection == SelectionNewFollowers || selection == SelectionUnfollowed) {
                    
                    // Users by date array to return
                    NSMutableArray *usersByDate = [NSMutableArray array];
                    
                    // Iterate over objects and break them up into sections by date
                    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        // Get the date
                        NSString *date = [obj valueForKey:@"date"];
                        
                        // Check if this date section exists
                        NSPredicate *sectionPredicate = [NSPredicate predicateWithFormat:@"SectionDictionaryKey == %@", date];
                        
                        NSArray *sectionFilteredArray = [usersByDate filteredArrayUsingPredicate:sectionPredicate];
                        
                        // Cells based on filtered section results
                        NSMutableArray *cells;
                        
                        if(sectionFilteredArray.count == 0) {
                            cells = [NSMutableArray array];
                            [usersByDate addObject:@{ SectionDictionaryKey : date, CellsDictionaryKey : cells }];
                        } else {
                            NSDictionary *section = [sectionFilteredArray lastObject];
                            cells = section[CellsDictionaryKey];
                        }
                        
                        // Find the user object by id
                        NSArray *filteredUsers
                        = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", [obj valueForKey:@"id"]]];
                        
                        [cells addObject:[filteredUsers lastObject]];
                        
                    }];
                    
                    // Reorder users by date
                    [usersByDate sortUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:SectionDictionaryKey ascending:NO] ]];
                    
                    // Return completion block
                    if(completionBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock(usersByDate, selection);
                        });
                    }

                } else if(selection == SelectionMostComments
                       || selection == SelectionMostLikes
                       || selection == SelectionMostCommentsAndLikes
                       || selection == SelectionLeastComments
                       || selection == SelectionLeastLikes
                       || selection == SelectionLeastCommentsAndLikes
                       || selection == SelectionFavoriteUsers
                       || selection == SelectionLikedDoNotFollow
                       || selection == SelectionSecretAdmirers) {
                    
                    // Enumerate over users setting attributed string and order
                    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        // User
                        InstagramUser *user = (InstagramUser *)obj;

                        // Set associated number
                        NSArray *countFilteredArray
                        = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", [obj identifier]]];
                        
                        // Key based on selection
                        NSString *key;
                        if(selection == SelectionMostCommentsAndLikes
                        || selection == SelectionLeastCommentsAndLikes
                        || selection == SelectionSecretAdmirers) {
                            key = TotalDictionaryKey;
                        } else if(selection == SelectionMostComments || selection == SelectionLeastComments) {
                            key = CommentsDictionaryKey;
                        } else if(selection == SelectionMostLikes || selection == SelectionLeastLikes) {
                            key = LikesDictionaryKey;
                        } else if(selection == SelectionFavoriteUsers || selection == SelectionLikedDoNotFollow) {
                            key = CountDictionaryKey;
                        }
                        
                        // Set the order number in order to sort the array
                        user.associatedNumber = [[countFilteredArray lastObject] objectForKey:key];

                        // If neccessary, set asscociated attributed text
                        if(selection == SelectionMostComments || selection == SelectionLeastComments) {
                            user.associatedAttributedString
                            = [NSAttributedString commentsAttributedStringWithCommentCount:user.associatedNumber username:user.username];
                        } else if(selection == SelectionMostLikes || selection == SelectionLeastLikes) {
                            user.associatedAttributedString
                            = [NSAttributedString likesAttributedStringWithLikeCount:user.associatedNumber username:user.username];
                        } else if(selection == SelectionMostCommentsAndLikes
                               || selection == SelectionLeastCommentsAndLikes
                               || selection == SelectionSecretAdmirers) {
                            NSNumber *comments = [[countFilteredArray lastObject] objectForKey:CommentsDictionaryKey];
                            NSNumber *likes    = [[countFilteredArray lastObject] objectForKey:LikesDictionaryKey];

                            user.associatedAttributedString
                            = [NSAttributedString likesAndCommentsAttributedStringWithLikeCount:likes commentCount:comments username:user.username];
                        } else if(selection == SelectionFavoriteUsers || selection == SelectionLikedDoNotFollow) {
                            user.associatedAttributedString
                            = [NSAttributedString youLikedAttributedStringWithLikeCount:user.associatedNumber username:user.username];
                        }
                        
                    }];
                    
                    // Reorder based upon selection
                    NSSortDescriptor *sortDescriptor;
                    
                    if(selection == SelectionMostCommentsAndLikes
                    || selection == SelectionMostComments
                    || selection == SelectionMostLikes
                    || selection == SelectionFavoriteUsers
                    || selection == SelectionLikedDoNotFollow
                    || selection == SelectionSecretAdmirers) {
                        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"associatedNumber" ascending:NO];
                    } else if(selection == SelectionLeastCommentsAndLikes
                           || selection == SelectionLeastComments
                           || selection == SelectionLeastLikes) {
                        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"associatedNumber" ascending:YES];
                    }
                    
                    users = [users sortedArrayUsingDescriptors:@[ sortDescriptor ]];
                    
                    // Return completion block
                    if(completionBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock(users, selection);
                        });
                    }
                    
                }

            }];
            
        } else if(selection == SelectionNewestUsers || selection == SelectionOldestUsers) {
            
            // Setup
            NSString *followersPath
            = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameFollowersFormat, self.user.identifier]];
            NSString *followingPath
            = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameFollowingFormat, self.user.identifier]];
            
            // Arrays
            NSArray *followers = [NSArray arrayWithContentsOfFile:followersPath];
            NSArray *following = [NSArray arrayWithContentsOfFile:followingPath];
            
            // Combine followers and following arrays
            NSMutableArray *combinedUsers = [NSMutableArray arrayWithArray:followers];
            [combinedUsers addObjectsFromArray:following];
            
            // Remove duplicates
            NSArray *allIdentifiers = [[NSOrderedSet orderedSetWithArray:combinedUsers] array];
            
            [self usersForIdentifiers:allIdentifiers asModel:YES completion:^(NSArray *users) {
                
                NSSortDescriptor *sortDescriptor;
                
                // Add users to array
                if(selection == SelectionNewestUsers) {
                    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"identifierNumber" ascending:NO];
                } else if(selection == SelectionOldestUsers) {
                    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"identifierNumber" ascending:YES];
                }
                
                NSArray *sortedArray = [users sortedArrayUsingDescriptors:@[ sortDescriptor ]];
                
                // Return only 25 users
                NSArray *usersToReturn = [sortedArray subarrayWithRange:NSMakeRange(0, MIN(sortedArray.count, 25))];
                
                //  Enumerate over users and create attributed string
                [usersToReturn enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    // User setup
                    InstagramUser *user = (InstagramUser *)obj;
                    
                    // Number string
                    NSString *numberString = [NSString stringWithFormat:@"#%@",
                                              [NSString localizedStringWithFormat:@"%.0f", [[(InstagramUser *)obj identifierNumber] floatValue]]
                                              ];
                    
                    // Associated string
                    user.associatedAttributedString = [NSAttributedString userAttributedStringWithNumberString:numberString username:user.username];
                    
                }];
                
                // Return completion block
                if(completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(usersToReturn, selection);
                    });
                }

            }];
            
        }
        
    });
}

- (void)usersForSelection:(Selection)selection
             fromLocation:(CLLocation *)location
               completion:(void (^)(NSArray *users, Selection selection))completionBlock
{
    dispatch_async(kBgQueue, ^{
        
        // Array for returned users
        NSMutableArray *blockUsers = [NSMutableArray array];
        
        // Paths
        NSString *usersPath
        = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNameUsersFormat, self.user.identifier]];
        NSString *locationsPath
        = [NSString pathWithPathComponent:[NSString stringWithFormat:FileNamePostLocationsFormat, self.user.identifier]];
        
        // Request arrays from file paths
        NSArray *users     = [NSArray arrayWithContentsOfFile:usersPath];
        NSArray *locations = [NSArray arrayWithContentsOfFile:locationsPath];
        
        // Enumerate over locations, find the user associated with it
        // and reconstruct the array
        [locations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            // Filter users, if count == 0, proceed and add the user
            NSArray *filteredUsers
            = [blockUsers filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:@"identifier == %@", [obj valueForKey:@"id"]]];
            
            if(filteredUsers.count == 0) {
                
                // Filter users (method users not self.users) again to find user
                NSArray *filteredUsers
                = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", [obj valueForKey:@"id"]]];
                
                // Alloc user object
                InstagramUser *user = [[InstagramUser alloc] init];
                user.dictionary     = [filteredUsers lastObject];
                
                // Alloc post location from obj dictionary values
                CLLocationDegrees latitude  = [[obj valueForKey:@"latitude"] floatValue];
                CLLocationDegrees longitude = [[obj valueForKey:@"longitude"] floatValue];
                
                CLLocation *postLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
                
                // Distance in meters
                CGFloat meters = [location distanceFromLocation:postLocation];
                
                // Check if the user localization is metric or imperial
                BOOL isMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
                
                // Values based on locale measurement system
                CGFloat distance = 0.0;
                NSString *unit;
                
                if(isMetric) { // Metric, calculate in kilometers
                    distance = (meters / 1000.0);
                    unit         = @"kilometers";
                } else if(!isMetric) { // Not metric, calculate in miles
                    distance = (meters * 0.000621371192); // Miles
                    unit         = @"miles";
                }
            
                // Set associated string with provided information
                user.associatedAttributedString = [NSAttributedString distanceAttributedStringWithDistance:distance unit:unit username:user.username];
                user.associatedNumber           = [NSNumber numberWithFloat:distance];
                
                // Add user object to users
                [blockUsers addObject:user];
                
            }
            
        }];
        
        // Sort users
        NSSortDescriptor *sortDescriptor;
        
        if(selection == SelectionNearby) {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"associatedNumber" ascending:YES];
        } else if(selection == SelectionFarAway) {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"associatedNumber" ascending:NO];
        }
        
        [blockUsers sortUsingDescriptors:@[ sortDescriptor ]];
                
        if(completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(blockUsers, selection);
            });
        }
        
    });
}

@end
