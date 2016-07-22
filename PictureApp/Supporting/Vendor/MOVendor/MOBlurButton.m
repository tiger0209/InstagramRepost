//
//  MOBlurButton.m
//  Instafollowers
//
//  Created by Michael Orcutt on 2/28/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "MOBlurButton.h"

@interface MOBlurButton ()

@property (strong, nonatomic) UIToolbar *blurToolbar;

@end

@implementation MOBlurButton

#pragma mark - init

+ (id)buttonWithType:(UIButtonType)buttonType
{
    return [super buttonWithType:buttonType];
}

- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        // Add blur background
        self.blurToolbar                        = [[UIToolbar alloc] init];
        self.blurToolbar.userInteractionEnabled = NO;

        [self insertSubview:self.blurToolbar atIndex:0];
        
        // Add target as self
        [self addTarget:self action:@selector(buttonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.blurToolbar.frame = self.bounds;
}

#pragma mark - Block

- (void)buttonWasTapped:(id)sender
{
    if(_actionBlock) {
        _actionBlock();
    }
}

@end
