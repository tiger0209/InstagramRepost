//
//  UsersViewController.h
//  Instafollowers
//
//  Created by Michael Orcutt on 2/20/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "UIKit/UIKit.h"

#import "InstagramUser.h"
#import "Constants.h"
#import "ARSegmentControllerDelegate.h"


@interface SearchUsersViewController : UIViewController <ARSegmentControllerDelegate>

// Selection
@property (strong, nonatomic) NSString *searchKey;

- (id)initWithSearchkey:(NSString*)searchKey;
- (id)initWithSearchkey:(NSString*)searchKey user:(InstagramUser *)user;

- (void)loadUsers:(BOOL) forScroll;

@end
