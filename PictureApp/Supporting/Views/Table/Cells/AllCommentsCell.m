//
//  IconCell.m
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/27/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "AllCommentsCell.h"
#import "Constants.h"

#define FONT_SIZE 15.0f

@implementation AllCommentsCell

#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Selected background view
        UIView *selectedBackgroundView         = [[UIView alloc] init];
        selectedBackgroundView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0];
        
        self.selectedBackgroundView = selectedBackgroundView;


//        self.allCommentViewLabel = [[UILabel alloc] init];
//        self.allCommentViewLabel.font      = [UIFont systemFontOfSize:FONT_SIZE];
//        self.allCommentViewLabel.textColor = [UIColor grayColor];
//
//        [self.allCommentViewLabel setTextAlignment:NSTextAlignmentCenter];
//        [self.allCommentViewLabel setLineBreakMode:NSLineBreakByWordWrapping];
//        [self.allCommentViewLabel setMinimumFontSize:FONT_SIZE];
//        [self.allCommentViewLabel setNumberOfLines:1];
//        [self.allCommentViewLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
//        [self.allCommentViewLabel setTag:1];
//        [self.contentView addSubview:self.allCommentViewLabel];
       
        self.allCommentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.allCommentBtn.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [self.allCommentBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.allCommentBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [self.allCommentBtn setTitle:@"" forState:UIControlStateNormal];
        
        [self.allCommentBtn setBackgroundColor:[UIColor clearColor]];

        [self.contentView addSubview:self.allCommentBtn];
        
        
//        [self setNeedsUpdateConstraints];

    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGRect commentLabelFrame     = CGRectMake(0, 0, 0, 0);
    commentLabelFrame.origin.x   = TableViewCellInset;
    commentLabelFrame.origin.y   = 0.0;
    commentLabelFrame.size.width = (bounds.size.width - commentLabelFrame.origin.x - TableViewCellInset);
    commentLabelFrame.size.height = bounds.size.height;
    
//    self.allCommentViewLabel.frame = commentLabelFrame;
    
    self.allCommentBtn.frame = commentLabelFrame;
    
}

//-(void)updateConstraints{
//    // add your constraints
//    [super updateConstraints];
//    
//    self.commentDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.commentDescriptionLabel
//                                                                 attribute:NSLayoutAttributeLeft
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.contentView
//                                                                 attribute:NSLayoutAttributeLeft
//                                                                multiplier:1
//                                                                  constant:12]];
//    
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.commentDescriptionLabel
//                                                                 attribute:NSLayoutAttributeRight
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.contentView
//                                                                 attribute:NSLayoutAttributeRight
//                                                                multiplier:1
//                                                                  constant:12]];
//    
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.commentDescriptionLabel
//                                                                 attribute:NSLayoutAttributeTop
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.contentView
//                                                                 attribute:NSLayoutAttributeTop
//                                                                multiplier:1
//                                                                  constant:5]];
//    
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.commentDescriptionLabel
//                                                                 attribute:NSLayoutAttributeBottom
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.contentView
//                                                                 attribute:NSLayoutAttributeBottom
//                                                                multiplier:1
//                                                                  constant:5]];
//
//}

@end
