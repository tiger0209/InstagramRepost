//
//  IconCell.h
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/27/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserAndRepostCell : UITableViewCell

// user image view
@property (strong, nonatomic) UIView        *userImageOutletView;
@property (strong, nonatomic) UIImageView   *userImageView;
@property (strong, nonatomic) UIButton      *userBtn;
@property (strong, nonatomic) UILabel       *userNameLabel;

//like Btn
@property (strong, nonatomic) UIButton *likeBtn;

//Repost Btn
@property (strong, nonatomic) UIButton *repostBtn;


@end
