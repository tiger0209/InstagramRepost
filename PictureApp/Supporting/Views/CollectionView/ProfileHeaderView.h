//
//  ProfileHeaderView.h
//  Instafollowers
//
//  Created by Michael Orcutt on 2/27/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UserView.h"
#import "Constants.h"

typedef void (^FollowButtonTapBlock)(void);

@interface ProfileHeaderView : UICollectionReusableView

// User view handles text label, detail text label,
// profile picture, and relationship labels
@property (strong, nonatomic) UserView *userView;

// Follow unfollow button
@property (strong, nonatomic) UIButton *followButton;

// Relationship label for incoming relationship
@property (strong, nonatomic) UILabel *relationshipLabel;

// Relationship statuses
@property (nonatomic) Relationship outgoingRelationship;
@property (nonatomic) Relationship incomingRelationship;

// Action blocks
@property (nonatomic, copy) FollowButtonTapBlock followButtonTapBlock;

@end
