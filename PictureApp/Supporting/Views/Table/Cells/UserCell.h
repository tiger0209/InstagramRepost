//
//  UserCell.h
//  Instafollowers
//
//  Created by Michael Orcutt on 2/23/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MORoundedImageContainerView.h"

@protocol UserCellDelegate <NSObject>

- (void)handleProfilePictureContainerViewTapped:(id)sender;

@end

@interface UserCell : UITableViewCell

// Profile picture
@property (strong, nonatomic) MORoundedImageContainerView *profilePictureContainerView;

// Delegate
@property (weak, nonatomic) id<UserCellDelegate> delegate;

@end
