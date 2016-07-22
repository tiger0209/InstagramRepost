//
//  IconCell.h
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/27/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentAndLikesCell : UITableViewCell

// Comment Icon image view
@property (strong, nonatomic) UIImageView *commentImageView;
@property (strong, nonatomic) UILabel *commentDescriptionLabel;
// Likes Icon image view
@property (strong, nonatomic) UIImageView *likesImageView;
@property (strong, nonatomic) UILabel *likesDescriptionLabel;

@end
