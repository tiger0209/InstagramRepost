//
//  IconCell.m
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/27/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "CommentAndLikesCell.h"
#import "Constants.h"

@implementation CommentAndLikesCell

#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Selected background view
        UIView *selectedBackgroundView         = [[UIView alloc] init];
        selectedBackgroundView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0];
        
        self.selectedBackgroundView = selectedBackgroundView;

        // Text label
//        self.textLabel.font      = [UIFont fontWithName:@"Ubuntu-Light" size:16.0];
//        self.textLabel.textColor = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0];
        
        // Comment image view
        self.commentImageView             = [[UIImageView alloc] init];
        self.commentImageView.contentMode = UIViewContentModeLeft;

        self.commentDescriptionLabel = [[UILabel alloc] init];
        self.commentDescriptionLabel.font      = [UIFont fontWithName:@"Ubuntu-Light" size:12.0];
        self.commentDescriptionLabel.textColor = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0];

        [self.contentView addSubview:self.commentImageView];
        [self.contentView addSubview:self.commentDescriptionLabel];
        
        // Likes image view
        self.likesImageView             = [[UIImageView alloc] init];
        self.likesImageView.contentMode = UIViewContentModeLeft;
        
        self.likesDescriptionLabel = [[UILabel alloc] init];
        self.likesDescriptionLabel.font      = [UIFont fontWithName:@"Ubuntu-Light" size:12.0];
        self.likesDescriptionLabel.textColor = [UIColor colorWithRed:16.0/255.0 green:98.0/255.0 blue:136.0/255.0 alpha:1.0];
        
        [self.contentView addSubview:self.likesImageView];
        [self.contentView addSubview:self.likesDescriptionLabel];


    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGRect commentImageViewFrame;
    commentImageViewFrame.size   = CGSizeMake(18.0, bounds.size.height);
    commentImageViewFrame.origin = CGPointMake(TableViewCellInset, 0.0);
    
    self.commentImageView.frame = commentImageViewFrame;
    
    CGRect commentLabelFrame     = CGRectMake(0, 0, 0, 0);
    commentLabelFrame.origin.x   = (commentImageViewFrame.origin.x + commentImageViewFrame.size.width + 8.0);
    commentLabelFrame.origin.y   = 0.0;
    commentLabelFrame.size.width = (bounds.size.width / 2 - commentLabelFrame.origin.x - TableViewCellInset);
    commentLabelFrame.size.height = bounds.size.height;
    
    self.commentDescriptionLabel.frame = commentLabelFrame;

    
    CGRect likesImageViewFrame;
    likesImageViewFrame.size   = CGSizeMake(18.0, bounds.size.height);
    likesImageViewFrame.origin = CGPointMake(bounds.size.width - TableViewCellInset - 80.0f, 0.0);
    
    self.likesImageView.frame = likesImageViewFrame;

    
    CGRect likesLabelFrame     = CGRectMake(0, 0, 0, 0);
    likesLabelFrame.origin.x   = (likesImageViewFrame.origin.x + likesImageViewFrame.size.width + 8.0);
    likesLabelFrame.origin.y   = 0.0;
    likesLabelFrame.size.height = bounds.size.height;
    likesLabelFrame.size.width = commentLabelFrame.size.width;//(bounds.size.width - likesLabelFrame.origin.x - TableViewCellInset);
    
    self.likesDescriptionLabel.frame = likesLabelFrame;
}

@end
