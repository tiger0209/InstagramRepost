//
//  UserView.h
//  Instafollowers
//
//  Created by Michael Orcutt on 2/17/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramUser.h"

#import "MORoundedImageContainerView.h"

typedef enum {
    UserViewLayoutCompareViewController,
    UserViewLayoutFollowUsersViewController,
    UserViewLayoutPromoteViewController,
    UserViewLayoutProfileViewController
} UserViewLayout;

@protocol UserViewDelegate <NSObject>

@optional

- (void)profilePictureContainerViewWasTapped;
- (void)textLabelWasTapped;
- (void)followersLabelWasTapped;
- (void)followingLabelWasTapped;

@end

@interface UserView : UIView

// Init with layout
- (id)initWithLayout:(UserViewLayout)layout;

// Max detail label height
@property (nonatomic) CGFloat maxDetailTextLabelHeight;

// Insets
@property (nonatomic) CGFloat topContentInset;

// Profile picture
@property (strong, nonatomic) MORoundedImageContainerView *profilePictureContainerView;

// Labels
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UILabel *detailTextLabel;
@property (strong, nonatomic) UILabel *followingLabel;
@property (strong, nonatomic) UILabel *followersLabel;

// User
@property (weak, nonatomic) InstagramUser *user;

// Delegate
@property (weak, nonatomic) id<UserViewDelegate> delegate;

// Height
- (CGFloat)height;

@end
