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

@interface UsersViewController : UIViewController

//- (id)initWithSelection:(Selection)selection presentedAsModalViewController:(BOOL)presentedAsModalViewController;
//- (id)initWithSelection:(Selection)selection user:(InstagramUser *)user presentedAsModalViewController:(BOOL)presentedAsModalViewController;
- (id)initWithSelection:(Selection)selection;
- (id)initWithSelection:(Selection)selection user:(InstagramUser *)user;

@end
