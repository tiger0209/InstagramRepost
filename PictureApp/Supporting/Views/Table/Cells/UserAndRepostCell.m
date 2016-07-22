//
//  IconCell.m
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/27/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "UserAndRepostCell.h"
#import "Constants.h"

@implementation UserAndRepostCell

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
        
        // user image view
        self.userImageOutletView       = [[UIView alloc] init];
        [self.userImageOutletView setBackgroundColor:[UIColor lightGrayColor]];
        
        [self.contentView addSubview:self.userImageOutletView];
        
        self.userImageView             = [[UIImageView alloc] init];
        self.userImageView.contentMode = UIViewContentModeLeft;

        self.userNameLabel = [[UILabel alloc] init];
        self.userNameLabel.font      = [UIFont fontWithName:@"Ubuntu-Light" size:12.0];
        self.userNameLabel.textColor = [UIColor colorWithRed:16.0/255.0 green:98.0/255.0 blue:136.0/255.0 alpha:1.0];

        [self.contentView addSubview:self.userImageView];
        [self.contentView addSubview:self.userNameLabel];
        
        
        //Likes Btn
        self.userBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.userBtn setBackgroundColor:[UIColor clearColor]];
        [self.userBtn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [self.userBtn setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        [self.userBtn setTitle:@"" forState:UIControlStateNormal];

        [self.contentView addSubview:self.userBtn];

        
        //Likes Btn
        self.likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"HeartGray"] forState:UIControlStateNormal];
    
        [self.contentView addSubview:self.likeBtn];
        
        //Repost Btn
        self.repostBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.repostBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.repostBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [self.repostBtn setTitle:@"Repost" forState:UIControlStateNormal];
        
        [self.repostBtn setBackgroundColor:[UIColor colorWithRed:51.0/255.0 green:177.0/255.0 blue:233.0/255.0 alpha:1.0]];
        
        [self.contentView addSubview:self.repostBtn];
    }
        return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGRect userImageViewFrame;
    userImageViewFrame.size   = CGSizeMake(bounds.size.height - 10.0f, bounds.size.height - 10.0f);
    userImageViewFrame.origin = CGPointMake(TableViewCellInset, 5.0);
    
    self.userImageView.frame = userImageViewFrame;
    
    CGRect userOutletViewFrame;
    userOutletViewFrame.size   = CGSizeMake(bounds.size.height - 8.0f, bounds.size.height - 8.0f);
    userOutletViewFrame.origin = CGPointMake(TableViewCellInset - 1.0f, 4.0);
    
    self.userImageOutletView.frame = userOutletViewFrame;
    
    self.userImageView.layer.cornerRadius = userImageViewFrame.size.height / 2;
    self.userImageOutletView.layer.cornerRadius = userOutletViewFrame.size.height / 2;
    
    self.userBtn.frame = userOutletViewFrame;

    
    CGRect userLabelFrame     = CGRectMake(0, 0, 0, 0);
    userLabelFrame.origin.x   = (userImageViewFrame.origin.x + userImageViewFrame.size.width + 8.0);
    userLabelFrame.origin.y   = 0.0;
    userLabelFrame.size.width = (bounds.size.width / 2 - userLabelFrame.origin.x);
    userLabelFrame.size.height = bounds.size.height;
    
    self.userNameLabel.frame = userLabelFrame;

    
    CGRect likesButtonFrame;
    likesButtonFrame.size   = CGSizeMake(30.0, 30.0);
    likesButtonFrame.origin = CGPointMake(bounds.size.width - TableViewCellInset - 100.0f - 30.0f, (bounds.size.height - 30.0f) / 2.0f);
    
    self.likeBtn.frame = likesButtonFrame;

    
    CGRect repostButtonFrame     = CGRectMake(0, 0, 0, 0);
    repostButtonFrame.origin.x   = (bounds.size.width - TableViewCellInset  - 100.0f + 8.0);
    repostButtonFrame.origin.y   = 5.0;
    repostButtonFrame.size.height = bounds.size.height - 10.0f;
    repostButtonFrame.size.width = 100.0f;//(bounds.size.width - likesLabelFrame.origin.x - TableViewCellInset);
    
    self.repostBtn.frame = repostButtonFrame;
    
    self.repostBtn.layer.cornerRadius = repostButtonFrame.size.height / 2;

}


@end
