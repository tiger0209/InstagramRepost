//
//  InstagramClient.m
//  InstagramFollowers
//
//  Created by Michael Orcutt on 10/20/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "InstagramClient.h"

// Networking
#import "AFNetworking.h"
#import "AFURLResponseSerialization.h"

// Models
#import "InstagramMedia.h"
#import "InstagramLike.h"
#import "InstagramComment.h"

#import "InstagramTag.h"

// URL string constants
NSString* const InstagramUserURLFormat         = @"https://api.instagram.com/v1/users/%@/?access_token=%@";
NSString* const InstagramMediaItemURLFormat    = @"https://api.instagram.com/v1/media/%@?access_token=%@";
NSString* const InstagramFollowersURLFormat    = @"https://api.instagram.com/v1/users/%@/followed-by?access_token=%@";
NSString* const InstagramFollowingURLFormat    = @"https://api.instagram.com/v1/users/%@/follows?access_token=%@";
NSString* const InstagramMediaLikeURLFormat    = @"https://api.instagram.com/v1/media/%@/likes?access_token=%@&count=10";
NSString* const InstagramMediaCommentURLFormat = @"https://api.instagram.com/v1/media/%@/comments?access_token=%@";
NSString* const InstagramRelationshipURLFormat = @"https://api.instagram.com/v1/users/%@/relationship?access_token=%@";
NSString* const InstagramUserLikesURLFormat    = @"https://api.instagram.com/v1/users/%@/media/liked?access_token=%@&count=200";
NSString* const InstagramUserTimelineURLFormat = @"https://api.instagram.com/v1/users/self/feed?access_token=%@";
NSString* const InstagramUserMediaURLFormat    = @"https://api.instagram.com/v1/users/%@/media/recent?access_token=%@";

NSString* const InstagramUserLikesURLFormat111    = @"https://api.instagram.com/v1/users/self/media/liked?access_token=%@&count=200";


/////lgilgilgi
NSString* const InstagramMediaPostLikeFormat    = @"https://api.instagram.com/v1/media/%@/likes";
NSString* const InstagramMediaDelLikeFormat    = @"https://api.instagram.com/v1/media/%@/likes";
NSString* const InstagramUsersSearch   = @"https://api.instagram.com/v1/users/search?q=%@&access_token=%@";
NSString* const InstagramTagsSearch   = @"https://api.instagram.com/v1/tags/%@/media/recent?access_token=%@";

NSString* const InstagramSearchingUsersURLFormat    = @"https://api.instagram.com/v1/users/search?q=%@&access_token=%@";

NSString* const InstagramSearchingTagsURLFormat    = @"https://api.instagram.com/v1/tags/search?q=%@&access_token=%@";


@interface InstagramClient ()

@property (strong, nonatomic) NSString *token;

@end

@implementation InstagramClient

+ (InstagramClient *)sharedClient
{
    static InstagramClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedClient                    = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.instagram.com/v1/"]];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
    });
    
    // Set the token from user defaults
    _sharedClient.token = [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken];
    
    return _sharedClient;
}

#pragma mark - User

- (void)getUserForIdentifier:(NSString *)identifier completion:(void (^)(BOOL, InstagramUser *))completionBlock
{
    // Create url string for get request
    NSString *urlString = [NSString stringWithFormat:InstagramUserURLFormat, identifier, self.token];
    
    // Make get request
    [self GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"]) {
            
            // Create instagram user object
            InstagramUser *user = [[InstagramUser alloc] init];
            user.dictionary     = responseObject[@"data"];
            
            // Return block
            if(completionBlock) {
                completionBlock(YES, user);
            }
            
        } else { // Not a dictionary, return failure
            
            // Return block
            if(completionBlock) {
                completionBlock(NO, nil);
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // Return block
        if(completionBlock) {
            completionBlock(NO, nil);
        }
        
    }];
}

- (void)getUserForName:(NSString *)name completion:(void (^)(BOOL success, NSArray *users, NSString *cursor))completionBlock
{
    // Create url string for get request
    NSString *urlString = [NSString stringWithFormat:InstagramUsersSearch, name, self.token];
    
    // Make get request
    [self GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"]) {
            
            // Return success block
            if(completionBlock) {
                completionBlock(YES,
                                [InstagramUser modelsFromDictionaries:responseObject[@"data"]],
                                [responseObject valueForKeyPath:@"pagination.next_cursor"]
                                );
            }
            
        } else { // Not a dictionary, return failure
            
            if(completionBlock) {
                completionBlock(NO, nil, nil);
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // Return block
        if(completionBlock) {
            completionBlock(NO, nil, nil);
        }
        
    }];
}

- (void)getTagForName:(NSString *)identifier
                    maxIdentifier:(NSString *)maxIdentifier
                       completion:(void (^)(BOOL success, NSArray *mediaItems, NSString *nextMaxIdentifier))completionBlock
{
    // Create url string for relationship request
    NSString *urlString = [NSString stringWithFormat:InstagramTagsSearch, identifier, self.token];
    
    // Parameters
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{ @"count" : @"60" }];
    
    if(maxIdentifier.length > 0) {
        [parameters setObject:maxIdentifier forKey:@"max_id"];
    }
    
    // Make get request
    [self GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"]) {
            
            // Return completion block
            if(completionBlock) {
                completionBlock(YES,
                                [InstagramMedia modelsFromDictionaries:responseObject[@"data"]],
                                [responseObject valueForKeyPath:@"pagination.next_max_id"]
                                );
            }
            
        } else { // Not a dictionary, return failure
            
            if(completionBlock) {
                completionBlock(NO, nil, nil);
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, nil, nil);
        }
        
    }];
}


- (void)getUserMediaForIdentifier:(NSString *)identifier
                    maxIdentifier:(NSString *)maxIdentifier
                       completion:(void (^)(BOOL success, NSArray *mediaItems, NSString *nextMaxIdentifier))completionBlock
{
    // Create url string for relationship request
    NSString *urlString = [NSString stringWithFormat:InstagramUserMediaURLFormat, identifier, self.token];
    
    // Parameters
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{ @"count" : @"60" }];
    
    if(maxIdentifier.length > 0) {
        [parameters setObject:maxIdentifier forKey:@"max_id"];
    }
    
    // Make get request
    [self GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
        if([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"]) {
            
            // Return completion block
            if(completionBlock) {
                completionBlock(YES,
                                [InstagramMedia modelsFromDictionaries:responseObject[@"data"]],
                                [responseObject valueForKeyPath:@"pagination.next_max_id"]
                                );
            }
            
        } else { // Not a dictionary, return failure
            
            if(completionBlock) {
                completionBlock(NO, nil, nil);
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, nil, nil);
        }
        
    }];
}

- (void)getUserFeedForIdentifier:(NSString *)identifier
                    maxIdentifier:(NSString *)maxIdentifier
                       completion:(void (^)(BOOL success, NSArray *mediaItems, NSString *nextMaxIdentifier))completionBlock
{
    // Create url string for relationship request
    NSString *urlString = [NSString stringWithFormat:InstagramUserTimelineURLFormat, self.token];
    
    // Parameters
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{ @"count" : @"60" }];
    
    if(maxIdentifier.length > 0) {
        [parameters setObject:maxIdentifier forKey:@"max_id"];
    }
    
    // Make get request
    [self GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"]) {
            
            // Return completion block
            if(completionBlock) {
                completionBlock(YES,
                                [InstagramMedia modelsFromDictionaries:responseObject[@"data"]],
                                [responseObject valueForKeyPath:@"pagination.next_max_id"]
                                );
            }
            
        } else { // Not a dictionary, return failure
            
            if(completionBlock) {
                completionBlock(NO, nil, nil);
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, nil, nil);
        }
        
    }];
}

- (void)getUserLikesForIdentifier:(NSString *)identifier
                   maxIdentifier:(NSString *)maxIdentifier
                      completion:(void (^)(BOOL success, NSArray *mediaItems, NSString *nextMaxIdentifier))completionBlock
{
    // Create url string for relationship request
    NSString *urlString = [NSString stringWithFormat:InstagramUserLikesURLFormat111, self.token];
    
    // Parameters
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{ @"count" : @"60" }];
    
    if(maxIdentifier.length > 0) {
        [parameters setObject:maxIdentifier forKey:@"max_id"];
    }
    
    // Make get request
    [self GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"]) {
            
            // Return completion block
            if(completionBlock) {
                completionBlock(YES,
                                [InstagramMedia modelsFromDictionaries:responseObject[@"data"]],
                                [responseObject valueForKeyPath:@"pagination.next_max_id"]
                                );
            }
            
        } else { // Not a dictionary, return failure
            
            if(completionBlock) {
                completionBlock(NO, nil, nil);
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, nil, nil);
        }
        
    }];
}

- (void)getUsersForSearching:(NSString *)searchKey
                      cursor:(NSString *)cursor
                  completion:(void (^)(BOOL success, NSArray *users, NSString *cursor))completionBlock
{
    // Create url string for relationship request
    NSString *urlString;
    
    
    urlString = [NSString stringWithFormat:InstagramSearchingUsersURLFormat, searchKey, self.token];
    
    // Parameters
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{ @"count" : @"200" }];
    
    if(cursor.length > 0) {
        [parameters setObject:cursor forKey:@"cursor"];
    }
    
    // Make get request
    [self GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"]) {
            
            // Return success block
            if(completionBlock) {
                completionBlock(YES,
                                [InstagramUser modelsFromDictionaries:responseObject[@"data"]],
                                [responseObject valueForKeyPath:@"pagination.next_cursor"]
                                );
            }
            
        } else { // Not a dictionary, return failure
            
            if(completionBlock) {
                completionBlock(NO, nil, nil);
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, nil, nil);
        }
        
    }];
}


#pragma mark - Access Token

- (void)validateAccessTokenWithCompletion:(void (^)(BOOL success, BOOL valid, InstagramUser *user))completionBlock
{
    // Create url string for get request
    NSString *urlString = [NSString stringWithFormat:InstagramUserURLFormat, @"self", self.token];
    
    // Make get request
    [self GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        InstagramUser *igUser = [[InstagramUser alloc] init];
        igUser.dictionary = responseObject[@"data"];
        
        // Return block success
        if(completionBlock) {
            completionBlock(YES, YES, igUser);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if([operation.responseObject isKindOfClass:[NSDictionary class]] && operation.responseObject[@"meta"]) {
            
            NSDictionary *meta = operation.responseObject[@"meta"];

            BOOL valid;

            if([[meta objectForKey:@"error_message"] isEqualToString:@"The access_token provided is invalid."]) {
                valid = NO;
            } else {
                valid = YES;
            }

            // Return block
            if(completionBlock) {
                completionBlock(YES, valid, nil);
            }
            return;
            
        }
        
        // Return block no success but still return a valid token since
        // we do not know whether it is valid or not
        if(completionBlock) {
            completionBlock(NO, YES, nil);
        }
        
    }];
}

#pragma mark - Relationships

- (void)getUsersForSelection:(Selection)selection
                  identifier:(NSString *)identifier
                      cursor:(NSString *)cursor
                  completion:(void (^)(BOOL success, NSArray *users, NSString *cursor))completionBlock
{
    // Create url string for relationship request
    NSString *urlString;
    
    if(selection == SelectionFollowers) {
        urlString = [NSString stringWithFormat:InstagramFollowersURLFormat, identifier, self.token];
    } else if(selection == SelectionFollowing) {
        urlString = [NSString stringWithFormat:InstagramFollowingURLFormat, identifier, self.token];
    }
    
    // Parameters
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{ @"count" : @"200" }];
    
    if(cursor.length > 0) {
        [parameters setObject:cursor forKey:@"cursor"];
    }
    
    // Make get request
    [self GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"]) {
            
            // Return success block
            if(completionBlock) {
                completionBlock(YES,
                                [InstagramUser modelsFromDictionaries:responseObject[@"data"]],
                                [responseObject valueForKeyPath:@"pagination.next_cursor"]
                                );
            }
            
        } else { // Not a dictionary, return failure
            
            if(completionBlock) {
                completionBlock(NO, nil, nil);
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, nil, nil);
        }
        
    }];
}

- (void)getAllRelationshipsForUserIdentifier:(NSString *)userIdentifier
                       relationshipSelection:(Selection)relationshipSelection
                                  completion:(void (^)(BOOL success, NSArray *allUsers, NSArray *allUserIdentifiers))completionBlock;
{
    
    // If it is not followers or following, return
    if(relationshipSelection != SelectionFollowers && relationshipSelection != SelectionFollowing) {
        return;
    }
    
    // Users array for all users returned
    __block NSMutableArray *allUsers = [NSMutableArray array]; // Instagram user models (non-core data models)
    
    // While BOOL value used to
    // return all relationships
    __block BOOL complete = NO;
    
    // Cursor property is used
    // to page through relationships
    __block NSString *cursor = @"";
    
    // Run requests on background thread
    // due to requests being made as
    // synchronous calls/performance
    // purposes
    dispatch_async(kBgQueue, ^{
        
        while (!complete) {
            
            // Create url string for relationship request
            NSString *urlString;
            if(relationshipSelection == SelectionFollowers) {
                urlString = [NSString stringWithFormat:InstagramFollowersURLFormat, userIdentifier, self.token];
            } else if(relationshipSelection == SelectionFollowing) {
                urlString = [NSString stringWithFormat:InstagramFollowingURLFormat, userIdentifier, self.token];
            }
            
            // If there is a cursor, add
            // the cursor to the request
            if(cursor.length > 0) {
                urlString = [NSString stringWithFormat:@"%@&cursor=%@", urlString, cursor];
            }
            
            // Create the GET URL request
            NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                       timeoutInterval:10.0];
            
            NSURLResponse *response;
            NSError       *error = nil;
            
            NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                         returningResponse:&response
                                                                     error:&error];
            
            // If there is an error, stop
            // future requests and return
            // failure block
            if(error) {
                
                if(completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(NO, nil, nil);
                    });
                }
                
                complete = YES;
                
                return;
            }
            
            // Turn response data into
            // a json object
            NSError *jsonError = nil;
            
            id jsonObject
            = [NSJSONSerialization JSONObjectWithData:responseData
                                              options:NSJSONReadingMutableLeaves
                                                error:&jsonError];
            
            // If there is an error turning
            // the response data into a
            // json object, return failure
            // block
            if(jsonError) {
                
                if(completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(NO, nil, nil);
                    });
                }
                
                complete = YES;
                
                return;
            } else if([jsonObject class] != [NSDictionary class] && ![jsonObject valueForKey:@"data"]) {
                
                // Return failure block as well because
                // the returned data is not parseable
                // in current form
                if(completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(NO, nil, nil);
                    });
                }
                
                complete = YES;
                
                return;
            }
            
            // If there is a next cursor, keep iterating
            if([jsonObject valueForKeyPath:@"pagination.next_cursor"]) {
                // Set cursor from jsonObject
                cursor = [jsonObject valueForKeyPath:@"pagination.next_cursor"];
                // Set complete to NO
                complete = NO;
            } else { // otherwise, calculate relationships that need to be removed and update
                complete = YES;
            }
            
            // Since the data has passed add to the users array
            [allUsers addObjectsFromArray:[jsonObject objectForKey:@"data"]];
            
            // If complete, return realationship completion block
            if(complete == YES) {
                if(completionBlock) {
                    
                    NSArray *allUserIdentifiers = [allUsers valueForKey:@"id"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(YES, allUsers, allUserIdentifiers);
                    });
                }
            }
            
        }
    });
    
}

- (void)getRelationshipForUserIdentifier:(NSString *)userIdentifier
                              completion:(void (^)(BOOL success, Relationship outgoingRelationship, Relationship incomingRelationship, BOOL private))completionBlock
{
    // Create url string for relationship request
    NSString *urlString = [NSString stringWithFormat:InstagramRelationshipURLFormat, userIdentifier, self.token];
    
    // Make get request
    [self GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"]) {
            
            Relationship outgoingRelationship;
            Relationship incomingRelationship;
            
            BOOL private = [[responseObject valueForKeyPath:@"data.target_user_is_private"] boolValue];
            
            if([[responseObject valueForKeyPath:@"data.incoming_status"] isEqualToString:@"followed_by"]) {
                incomingRelationship = RelationshipFollowing;
            } else if([[responseObject valueForKeyPath:@"data.incoming_status"] isEqualToString:@"none"]) {
                incomingRelationship = RelationshipNotFollowing;
            } else if([[responseObject valueForKeyPath:@"data.incoming_status"] isEqualToString:@"requested_by"]) {
                incomingRelationship = RelationshipRequested;
            } else {
                incomingRelationship = RelationshipUnknown;
            }
            
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
             
            // Return success block
            if(completionBlock) {
                completionBlock(YES,
                                outgoingRelationship,
                                incomingRelationship,
                                private
                                );
            }
            
        } else { // Not a dictionary, return failure
            
            if(completionBlock) {
                completionBlock(NO, RelationshipUnknown, RelationshipUnknown, NO);
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, RelationshipUnknown, RelationshipUnknown, NO);
        }
        
    }];
}

#pragma mark - Media

- (void)getAllMediaForUserIdentifier:(NSString *)userIdentifier
                          completion:(void (^)(BOOL success, NSArray *allMediaItems))completionBlock
{
    dispatch_async(kBgQueue, ^{
        
        // Media array for all media items returned
        __block NSMutableArray *allMediaItems = [NSMutableArray array]; // Instagram media item models (non-core data models)
        
        // Query counts
        __block NSInteger queryLikesCount    = 0;
        __block NSInteger queryCommentsCount = 0;
        
        // Complete bool value used
        // to iterate over media objects
        __block BOOL complete = NO;
        __block BOOL failure  = NO;
        
        // Next max identifier string used
        // to iterate over objects
        __block NSString *nextMaxIdentifier;
        
        // Use while loop to iterate
        // over all media objects
        while (complete == NO) {
            
            // Create url string for request
            NSString *urlString = [NSString stringWithFormat:InstagramUserMediaURLFormat, userIdentifier, self.token];
            
            // If there is a cursor, add
            // the cursor to the request
            if(nextMaxIdentifier.length > 0) {
                urlString = [NSString stringWithFormat:@"%@&max_id=%@", urlString, nextMaxIdentifier];
            }
            
            // Create the GET URL request
            NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
            
            NSURLResponse *response;
            NSError       *error = nil;
            
            NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                         returningResponse:&response
                                                                     error:&error];
            
            // If there is an error, stop
            // future requests and return
            // failure block
            if(error) {
                
                if(completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(NO, nil);
                    });
                }
                
                complete = YES;
                
                return;
            }
            
            // Turn response data into
            // a json object
            NSError *jsonError = nil;
            
            id jsonObject
            = [NSJSONSerialization JSONObjectWithData:responseData
                                              options:NSJSONReadingMutableLeaves
                                                error:&jsonError];
            
            // If there is an error turning
            // the response data into a
            // json object, return failure
            // block
            if(jsonError) {
                
                if(completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(NO, nil);
                    });
                }
                
                complete = YES;
                
                return;
            } else if([jsonObject class] != [NSDictionary class] && ![jsonObject valueForKey:@"data"]) {
                
                // Return failure block as well because
                // the returned data is not parseable
                // in it's current form
                if(completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(NO, nil);
                    });
                }
                
                complete = YES;
                
                return;
            }
            
            // Turn dictionary objects into model objects
            NSArray *mediaItems = [InstagramMedia modelsFromDictionaries:[jsonObject objectForKey:@"data"]];
            
            [allMediaItems addObjectsFromArray:mediaItems];
            
            // Enumerate over objects and check if there are comments or likes
            [mediaItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                // Failure took place, return
                if(failure == YES)
                    return;
                
                // Query all likes if they exist
                if([(InstagramMedia *)obj likeCount] > 0) {
                    
                    // Query likes
                    queryLikesCount++;
                    
                    [[InstagramClient sharedClient] getLikesForMediaIdentifier:[(InstagramMedia *)obj identifier]
                                                                asModelObjects:NO
                                                                    completion:^(BOOL success, NSArray *likes)
                    {
                        
                        if(success) {
                            
                            // Failure took place, return
                            if(failure == YES)
                                return;
                            
                            queryLikesCount--;
                            
                            // Search for media object
                            NSPredicate *predicate      = [NSPredicate predicateWithFormat:@"identifier == %@", [(InstagramMedia *)obj identifier]];
                            NSArray *filteredMediaIetms = [allMediaItems filteredArrayUsingPredicate:predicate];
                            
                            // Reset likes
                            InstagramMedia *mediaItem = [filteredMediaIetms lastObject];
                            
                            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:mediaItem.dictionary];
                            [dictionary setValue:@{ @"data" : likes, @"count" : [dictionary valueForKeyPath:@"likes.count"] } forKey:@"likes"];
                            
                            mediaItem.dictionary = dictionary;
                            
                            if(queryLikesCount == 0 && queryCommentsCount == 0 && complete) { // All likes have returned
                                // Return block with all media items
                                if(completionBlock) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        completionBlock(YES, allMediaItems);
                                    });
                                }
                            }

                        } else {
                            
                            // Failure took place, return
                            if(failure == YES)
                                return;
                            
                            // Mark failure
                            failure = YES;
                            
                            // Return completion block with failure
                            if(completionBlock) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completionBlock(NO, nil);
                                });
                            }
                            
                            return;

                        }

                    }];

                }
                
                // Query comments if they exist
                if([(InstagramMedia *)obj commentCount] > 0) {
                    
                    // Query comments
                    queryCommentsCount++;
                    
                    [[InstagramClient sharedClient] getCommentsForMediaIdentifier:[(InstagramMedia *)obj identifier]
                                                                   asModelObjects:NO
                                                                       completion:^(BOOL success, NSArray *comments)
                    {
                        
                        if(success) {
                            
                            // Failure took place, return
                            if(failure == YES)
                                return;
                            
                            queryCommentsCount--;
                            
                            // Search for media object
                            NSPredicate *predicate      = [NSPredicate predicateWithFormat:@"identifier == %@", [(InstagramMedia *)obj identifier]];
                            NSArray *filteredMediaIetms = [allMediaItems filteredArrayUsingPredicate:predicate];
                            
                            // Reset comments
                            InstagramMedia *mediaItem = [filteredMediaIetms lastObject];
                            
                            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:mediaItem.dictionary];
                            [dictionary setValue:@{ @"data" : comments, @"count" : [dictionary valueForKeyPath:@"comments.count"] } forKey:@"comments"];
                            
                            if(queryLikesCount == 0 && queryCommentsCount == 0 && complete) { // All likes have returned
                                // Return block with all media items
                                if(completionBlock) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        completionBlock(YES, allMediaItems);
                                    });
                                }
                            }

                        } else {
                            
                            // Failure took place, return
                            if(failure == YES)
                                return;
                            
                            // Mark failure
                            failure = YES;
                            
                            // Return completion block with failure
                            if(completionBlock) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completionBlock(NO, nil);
                                });
                            }
                            
                            return;
                            
                        }
                        
                    }];
                    
                }
                
                
            }];
            
            // Set next max identifier if there is one
            if([jsonObject valueForKeyPath:@"pagination.next_max_id"]) {
                nextMaxIdentifier = [jsonObject valueForKeyPath:@"pagination.next_max_id"];
            } else {
                // There is no next max identifier
                // so set complete to yes
                complete = YES;
                
                // Return block with all media items
                if(queryLikesCount == 0 && queryCommentsCount == 0 && complete) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(YES, allMediaItems);
                    });
                }
            }
            
        }
        
    });
}

- (void)getMediaItemForIdentifier:(NSString *)identifier
                       completion:(void (^)(BOOL success, InstagramMedia *mediaItem))completionBlock
{
    // Create url string for get request
    NSString *urlString = [NSString stringWithFormat:InstagramMediaItemURLFormat, identifier, self.token];
    
    // Make get request
    [self GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"]) {
            
            // Create instagram user object
            InstagramMedia *mediaItem = [[InstagramMedia alloc] init];
            mediaItem.dictionary      = responseObject[@"data"];
            
            // Return block
            if(completionBlock) {
                completionBlock(YES, mediaItem);
            }
            
        } else { // Not a dictionary, return failure
            
            // Return block
            if(completionBlock) {
                completionBlock(NO, nil);
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // Return block
        if(completionBlock) {
            completionBlock(NO, nil);
        }
        
    }];
}

#pragma mark - Post, Del like

- (void)postLikeWithAccessToken:(NSString *)accessToken
                mediaIdentifier:(NSString *)mediaIdentifier
                     completion:(void (^)(BOOL success))completionBlock
{
    // Show activity indicator
    //ShowNetworkActivityIndicator();
    
    NSString *urlString = [NSString stringWithFormat:InstagramMediaPostLikeFormat, mediaIdentifier];
    
    NSDictionary *params = [self dictionaryWithAccessTokenAndParameters:nil];
    // Make get request
    [self POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(completionBlock) {
            completionBlock(YES);
        }
        
        // Hide activity indicator
//        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@", operation.responseString);
        
        if(completionBlock && [operation.responseObject valueForKey:@"error"]) {
            completionBlock(NO);
        } else if (completionBlock) {
            completionBlock(NO);
        }
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

- (void)delLikeWithAccessToken:(NSString *)accessToken
               mediaIdentifier:(NSString *)mediaIdentifier
                    completion:(void (^)(BOOL success))completionBlock
{
    // Show activity indicator
    ShowNetworkActivityIndicator();
    
    NSDictionary *params = [self dictionaryWithAccessTokenAndParameters:nil];
    
    NSString *urlString = [NSString stringWithFormat:InstagramMediaDelLikeFormat, mediaIdentifier];
    
    // Make get request
    [self DELETE:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(completionBlock) {
            completionBlock(YES);
        }
        
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@", operation.responseString);
        
        if(completionBlock && [operation.responseObject valueForKey:@"error"]) {
            completionBlock(NO);
        } else if (completionBlock) {
            completionBlock(NO);
        }
        // Hide activity indicator
        HideNetworkActivityIndicator();
        
    }];
}

NSString* const InstagramClientIdentifier111           = @"51fd356043ee4987ad84fd2c11f54955";

- (NSDictionary *)dictionaryWithAccessTokenAndParameters:(NSDictionary *)params
{
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:params];
    if (self.token) {
        [mutableDictionary setObject:self.token forKey:@"access_token"];
    }
    else
    {
        [mutableDictionary setObject:InstagramClientIdentifier111 forKey:@"client_id"];
    }
    return [NSDictionary dictionaryWithDictionary:mutableDictionary];
}

#pragma mark - Likes

- (void)getLikesForMediaIdentifier:(NSString *)mediaIdentifier
                    asModelObjects:(BOOL)asModelObjects
                        completion:(void (^)(BOOL success, NSArray *likes))completionBlock
{
    // Create url string for like request
    NSString *urlString = [NSString stringWithFormat:InstagramMediaLikeURLFormat, mediaIdentifier, self.token];
    
    // Make GET request
    [self GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"]) {
            
            // Return success block
            if(completionBlock) {
                if(asModelObjects) {
                    completionBlock(YES, [InstagramLike modelsFromDictionaries:responseObject[@"data"]]);
                } else {
                    completionBlock(YES, responseObject[@"data"]);
                }
            }
            
        } else { // Not a dictionary, return failure
            
            if(completionBlock) {
                completionBlock(NO, nil);
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, nil);
        }
        
    }];
}

- (void)getAllLikesForUserIdentifier:(NSString *)userIdentifier
                          completion:(void (^)(BOOL success, NSArray *allLikes))completionBlock
{
    dispatch_async(kBgQueue, ^{
        
        // Media array for all like items returned
        __block NSMutableArray *allLikes = [NSMutableArray array]; // Instagram media item models (non-core data models)
        
        // Complete bool value used
        // to iterate over like objects
        __block BOOL complete = NO;
        
        // Next max identifier string used
        // to iterate over objects
        __block NSString *nextMaxIdentifier;
        
        // Use while loop to iterate
        // over all like objects
        while (complete == NO) {
            
            // Create url string for request
            NSString *urlString = [NSString stringWithFormat:InstagramUserLikesURLFormat, userIdentifier, self.token];
            
            // If there is a cursor, add
            // the cursor to the request
            if(nextMaxIdentifier.length > 0) {
                urlString = [NSString stringWithFormat:@"%@&max_like_id=%@", urlString, nextMaxIdentifier];
            }
            
            // Create the GET URL request
            NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
            
            NSURLResponse *response;
            NSError       *error = nil;
            
            NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                         returningResponse:&response
                                                                     error:&error];
            
            // If there is an error, stop
            // future requests and return
            // failure block
            if(error) {
                
                if(completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(NO, nil);
                    });
                }
                
                complete = YES;
                
                return;
            }
            
            // Turn response data into
            // a json object
            NSError *jsonError = nil;
            
            id jsonObject
            = [NSJSONSerialization JSONObjectWithData:responseData
                                              options:NSJSONReadingMutableLeaves
                                                error:&jsonError];
            
            // If there is an error turning
            // the response data into a
            // json object, return failure
            // block
            if(jsonError) {
                
                if(completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(NO, nil);
                    });
                }
                
                complete = YES;
                
                return;
            } else if([jsonObject class] != [NSDictionary class] && ![jsonObject valueForKey:@"data"]) {
                
                // Return failure block as well because
                // the returned data is not parseable
                // in it's current form
                if(completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(NO, nil);
                    });
                }
                
                complete = YES;
                
                return;
            }
            
            // Turn dictionary objects into model objects
            [allLikes addObjectsFromArray:[InstagramLike modelsFromDictionaries:[jsonObject objectForKey:@"data"]]];
            
            // Set next max identifier if there is one
            if([jsonObject valueForKeyPath:@"pagination.next_max_like_id"]) {
                nextMaxIdentifier = [jsonObject valueForKeyPath:@"pagination.next_max_like_id"];
            } else {
                // There is no next max identifier
                // so set complete to yes
                complete = YES;
                
                // Return block with all like items
                if(complete) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(YES, allLikes);
                    });
                }
            }
            
        }
        
    });
}

#pragma mark - Comments

- (void)getCommentsForMediaIdentifier:(NSString *)mediaIdentifier
                       asModelObjects:(BOOL)asModelObjects
                           completion:(void (^)(BOOL success, NSArray *comments))completionBlock
{
    // Create url string for comments request
    NSString *urlString = [NSString stringWithFormat:InstagramMediaCommentURLFormat, mediaIdentifier, self.token];
    
    // Make GET request
    [self GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"]) {
            // Return success block
            if(completionBlock) {
                if(asModelObjects) {
                    completionBlock(YES, [InstagramComment modelsFromDictionaries:responseObject[@"data"]]);
                } else {
                    completionBlock(YES, responseObject[@"data"]);
                }
            }
            
        } else { // Not a dictionary, return failure
            
            if(completionBlock) {
                completionBlock(NO, nil);
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, nil);
        }
        
    }];
    
}

#pragma mark - Timeline

- (void)getTimelineWithLocationsCount:(NSInteger)locationsCount
                          maxRequests:(NSInteger)maxRequests
                           completion:(void (^)(BOOL success, NSArray *mediaItems))completionBlock
{

    // Run requests on background thread
    dispatch_async(kBgQueue, ^{
        
        // Media array for all media items returned
        __block NSMutableArray *mediaItems = [NSMutableArray array];
        
        // While BOOL value used to
        // return all media items
        // from the timeline
        __block BOOL complete = NO;
        
        // Cursor property is used
        // to page through relationships
        __block NSString *maxIdentifier = @"";
        __block NSInteger requests = 0;
        
        while (!complete) {
            
            // Create url string for request
            NSString *urlString = [NSString stringWithFormat:InstagramUserTimelineURLFormat, self.token];
            
            // If there is a cursor, add
            // the cursor to the request
            if(maxIdentifier.length > 0) {
                urlString = [NSString stringWithFormat:@"%@&max_id=%@", urlString, maxIdentifier];
            }
            
            // Create the GET URL request
            NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                       timeoutInterval:10.0];
            
            NSURLResponse *response;
            NSError       *error = nil;
            
            NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                         returningResponse:&response
                                                                     error:&error];
            
            // If there is an error, stop
            // future requests and return
            if(error) {
                
                complete = YES;
                
                // Notify main thread
                if(completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(NO, nil);
                    });
                }

                return;
            }
            
            // Turn response data into
            // a json object
            NSError *jsonError = nil;
            
            id jsonObject
            = [NSJSONSerialization JSONObjectWithData:responseData
                                              options:NSJSONReadingMutableLeaves
                                                error:&jsonError];
            
            
            // If there is an error turning
            // the response data into a
            // json object, return
            if(jsonError) {
                
                complete = YES;
                
                // Notify main thread
                if(completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(NO, nil);
                    });
                }
                
                return;
                
            } else if([jsonObject class] != [NSDictionary class] && ![jsonObject valueForKey:@"data"]) {
                
                // Return failure as well because
                // the returned data is not parseable
                // in it's current form
                
                complete = YES;
                
                // Notify main thread
                if(completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(NO, nil);
                    });
                }

                return;
                
            }
            
            // If there is a next cursor, keep iterating
            if([jsonObject valueForKeyPath:@"pagination.next_max_id"]) {
                // Set cursor from jsonObject
                maxIdentifier = [jsonObject valueForKeyPath:@"pagination.next_max_id"];
                // Set complete to NO
                complete = NO;
            } else {
                complete = YES;
            }
            
            // Increment the count
            requests++;
            
            // Parse data into objects
            NSArray *modelsFromDictionaries = [InstagramMedia modelsFromDictionaries:[jsonObject objectForKey:@"data"]];
            
            [modelsFromDictionaries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

                // Add object only if the post has a location
                if([(InstagramMedia *)obj location] != nil) {
                    [mediaItems addObject:obj];
                }
                
            }];
            
            // If criteria is met, requests are complete
            if(mediaItems.count >= locationsCount || requests == maxRequests || complete == YES) {
                complete = YES;
                
                // Notify main thread
                if(completionBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(YES, mediaItems);
                    });
                }
            }
            
        }
    });
    
}

#pragma maek TAG
- (void)getTagsForSearching:(NSString *)searchKey
                      cursor:(NSString *)cursor
                  completion:(void (^)(BOOL success, NSArray *users, NSString *cursor))completionBlock
{
    // Create url string for relationship request
    NSString *urlString;
    
    
    urlString = [NSString stringWithFormat:InstagramSearchingTagsURLFormat, searchKey, self.token];
    
    // Parameters
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{ @"count" : @"200" }];
    
    if(cursor.length > 0) {
        [parameters setObject:cursor forKey:@"cursor"];
    }
    
    // Make get request
    [self GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"data"]) {
            
            // Return success block
            if(completionBlock) {
                completionBlock(YES,
                                [InstagramTag modelsFromDictionaries:responseObject[@"data"]],
                                [responseObject valueForKeyPath:@"pagination.next_cursor"]
                                );
            }
            
        } else { // Not a dictionary, return failure
            
            if(completionBlock) {
                completionBlock(NO, nil, nil);
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completionBlock) {
            completionBlock(NO, nil, nil);
        }
        
    }];
}


@end
