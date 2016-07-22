//
//  DataManagement.h
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/16/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// Model
#import "InstagramUser.h"

#import "Constants.h"

@interface DataManagement : NSObject

// Singleton method
+ (DataManagement *)sharedClient;

// Logged in user methods
- (void)logoutUser;
- (InstagramUser *)user;
- (BOOL)userIsLoggedIn;

/* Update methods: start updating
   relays other update methods
 */
- (void)startUpdating;

@property (readonly) BOOL relationshipsLoading;
@property (readonly) BOOL timelineLoading;
@property (readonly) BOOL mediaLoading;
@property (readonly) BOOL likedMediaLoading;

- (BOOL)selectionLoading:(Selection)selection;
- (BOOL)selectionFileExists:(Selection)selection;

/* User methods from updates */
- (void)usersForSelection:(Selection)selection
               completion:(void (^)(NSArray *users, Selection selection))completionBlock;

- (void)usersForSelection:(Selection)selection
             fromLocation:(CLLocation *)location
               completion:(void (^)(NSArray *users, Selection selection))completionBlock;

// Products and categories
- (NSArray *)followerProducts;
- (NSArray *)categories;

// Failed transactions
- (NSArray *)failedTransactions;
- (void)addFailedTransactionWithReceiptIdentifier:(NSString *)receiptIdentifier;
- (void)removeFailedTransactionWithReceiptIdentifier:(NSString *)receiptIdentifier;

@end
