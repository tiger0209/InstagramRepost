//
//  InstagramClient.h
//  InstagramFollowers
//
//  Created by Michael Orcutt on 10/20/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "InstagramUser.h"
#import "InstagramMedia.h"
#import "Constants.h"

UIKIT_EXTERN NSString *const InstagramUserURLFormat;
UIKIT_EXTERN NSString *const InstagramMediaItemURLFormat;
UIKIT_EXTERN NSString *const InstagramFollowersURLFormat;
UIKIT_EXTERN NSString *const InstagramFollowingURLFormat;
UIKIT_EXTERN NSString *const InstagramMediaLikeURLFormat;
UIKIT_EXTERN NSString *const InstagramMediaCommentURLFormat;
UIKIT_EXTERN NSString *const InstagramRelationshipURLFormat;
UIKIT_EXTERN NSString *const InstagramUserLikesURLFormat;
UIKIT_EXTERN NSString *const InstagramUserTimelineURLFormat;
UIKIT_EXTERN NSString *const InstagramUserMediaURLFormat;

@interface InstagramClient : AFHTTPRequestOperationManager

// Singleton client used throughout
// the entire application
+ (InstagramClient *)sharedClient;

// User
- (void)getUserForIdentifier:(NSString *)identifier
                  completion:(void (^)(BOOL success, InstagramUser *user))completionBlock;

- (void)getUserForName:(NSString *)name
                  completion:(void (^)(BOOL success, NSArray *users, NSString *cursor))completionBlock;

- (void)getTagForName:(NSString *)identifier
        maxIdentifier:(NSString *)maxIdentifier
           completion:(void (^)(BOOL success, NSArray *mediaItems, NSString *nextMaxIdentifier))completionBlock;


- (void)getUserMediaForIdentifier:(NSString *)identifier
                    maxIdentifier:(NSString *)maxIdentifier
                       completion:(void (^)(BOOL success, NSArray *mediaItems, NSString *nextMaxIdentifier))completionBlock;

- (void)getUserFeedForIdentifier:(NSString *)identifier
                    maxIdentifier:(NSString *)maxIdentifier
                       completion:(void (^)(BOOL success, NSArray *mediaItems, NSString *nextMaxIdentifier))completionBlock;
- (void)getUserLikesForIdentifier:(NSString *)identifier
                   maxIdentifier:(NSString *)maxIdentifier
                      completion:(void (^)(BOOL success, NSArray *mediaItems, NSString *nextMaxIdentifier))completionBlock;

///lgilgilgi
- (void)getUsersForSearching:(NSString *)searchKey
                      cursor:(NSString *)cursor
                  completion:(void (^)(BOOL success, NSArray *users, NSString *cursor))completionBlock;

// Access token
- (void)validateAccessTokenWithCompletion:(void (^)(BOOL success, BOOL valid, InstagramUser *user))completionBlock;

// Relationships
- (void)getUsersForSelection:(Selection)selection
                  identifier:(NSString *)identifier
                      cursor:(NSString *)cursor
                  completion:(void (^)(BOOL success, NSArray *users, NSString *cursor))completionBlock;
- (void)getRelationshipForUserIdentifier:(NSString *)userIdentifier
                              completion:(void (^)(BOOL success,
                                                   Relationship outgoingRelationship,
                                                   Relationship incomingRelationship,
                                                   BOOL private)
                                          )completionBlock;
- (void)getAllRelationshipsForUserIdentifier:(NSString *)userIdentifier
                       relationshipSelection:(Selection)relationshipSelection
                                  completion:(void (^)(BOOL success, NSArray *allUsers, NSArray *allUserIdentifiers))completionBlock;

// Media
- (void)getMediaItemForIdentifier:(NSString *)identifier
                       completion:(void (^)(BOOL success, InstagramMedia *mediaItem))completionBlock;
- (void)getAllMediaForUserIdentifier:(NSString *)userIdentifier
                          completion:(void (^)(BOOL success, NSArray *allMediaItems))completionBlock;

// Likes
- (void)getLikesForMediaIdentifier:(NSString *)mediaIdentifier
                    asModelObjects:(BOOL)asModelObjects
                        completion:(void (^)(BOOL success, NSArray *likes))completionBlock;
- (void)getAllLikesForUserIdentifier:(NSString *)userIdentifier
                          completion:(void (^)(BOOL success, NSArray *allLikes))completionBlock;

// Timeline
- (void)getTimelineWithLocationsCount:(NSInteger)locationsCount
                          maxRequests:(NSInteger)maxRequests
                           completion:(void (^)(BOOL success, NSArray *mediaItems))completionBlock;

// Comments
- (void)getCommentsForMediaIdentifier:(NSString *)mediaIdentifier
                       asModelObjects:(BOOL)asModelObjects
                           completion:(void (^)(BOOL success, NSArray *comments))completionBlock;

- (void)postLikeWithAccessToken:(NSString *)accessToken
                mediaIdentifier:(NSString *)mediaIdentifier
                     completion:(void (^)(BOOL success))completionBlock;

- (void)delLikeWithAccessToken:(NSString *)accessToken
                mediaIdentifier:(NSString *)mediaIdentifier
                    completion:(void (^)(BOOL success))completionBlock;

//Tag
- (void)getTagsForSearching:(NSString *)searchKey
                     cursor:(NSString *)cursor
                 completion:(void (^)(BOOL success, NSArray *users, NSString *cursor))completionBlock;


@end
