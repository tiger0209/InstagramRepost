//
//  MOTabBarItem.m
//  InstagramLikes
//
//  Created by Michael Orcutt on 1/23/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "MOTabBarItem.h"

@implementation MOTabBarItem

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // By default, 'userInteractionEnabled' is set to NO on
        // UIImageView. Change this to YES for tapping purposes.
        self.userInteractionEnabled = YES;
        
        // Set 'contentMode' to UIViewContentModeCenter
        self.contentMode = UIViewContentModeCenter;

        // Initialize 'highlightedIndicatorImageView, set properties, and add to subview
        self.highlightedIndicatorImageView             = [[UIImageView alloc] init];
        self.highlightedIndicatorImageView.contentMode = UIViewContentModeCenter;
        self.highlightedIndicatorImageView.hidden      = YES;
        
        [self addSubview:self.highlightedIndicatorImageView];
        
        
        /////////lgilgilgi
        self.textLabel               = [[UILabel alloc] init];
        self.textLabel.font          = [UIFont fontWithName:@"Ubuntu-Light" size:12.0];
        self.textLabel.textColor     = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0];
        self.textLabel.numberOfLines = 1;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.textLabel];

        

        // Initialize 'tapGesture' and add as gesture recogonizer
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        
        [self addGestureRecognizer:tapGesture];
        
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Layout setup
    CGRect bounds = self.bounds;
    
    // 'highlightedIndicatorImageView' frame setup
    CGRect highlightedIndicatorImageViewFrame;
    highlightedIndicatorImageViewFrame.size   = CGSizeMake(bounds.size.width, self.highlightedIndicatorImageView.image.size.height);
    highlightedIndicatorImageViewFrame.origin = CGPointMake(0.0, (bounds.size.height - highlightedIndicatorImageViewFrame.size.height));
    
    // Set 'highlightedIndicatorImageView' frame from 'highlightedIndicatorImageViewFrame'
    self.highlightedIndicatorImageView.frame = highlightedIndicatorImageViewFrame;
    
    ////////////lgilgilgi
    CGRect textLabelFrame;
    textLabelFrame.size   = CGSizeMake(bounds.size.width, 20);
    textLabelFrame.origin = CGPointMake(0.0, (bounds.size.height - 20));
    self.textLabel.frame = textLabelFrame;

}

#pragma mark - Gesture

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture
{
    // Return 'tapBlock'
    if(self.tapBlock) {
        self.tapBlock();
    }
}

@end
