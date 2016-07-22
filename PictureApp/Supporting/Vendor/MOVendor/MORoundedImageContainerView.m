//
//  MORoundedImageContainerView.m
//  InstagramLikes
//
//  Created by Michael Orcutt on 1/28/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "MORoundedImageContainerView.h"

@interface MORoundedImageContainerView ()

@property (strong, nonatomic) UIImageView *selectedImageView;

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@end

@implementation MORoundedImageContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Border
        self.layer.borderWidth   = 2.0;
        self.layer.masksToBounds = YES;
        
        // Image view
        self.imageView               = [[UIImageView alloc] init];
        self.imageView.clipsToBounds = YES;

        [self addSubview:self.imageView];
        
        // Not selected by default
        self.selected = NO;
        
        // By default, make tappable
        self.tappable = YES;
        
        self.cornerRadiusRatio = 0.5f;//.45;
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    // Corner radius
    self.layer.cornerRadius = floorf(bounds.size.width * self.cornerRadiusRatio);
    
    // Image view inset by 1 pixel
    CGRect imageViewFrame = bounds;
    imageViewFrame.size.width  -= 2.0;
    imageViewFrame.size.height -= 2.0;
    imageViewFrame.origin       = CGPointMake(1.0, 1.0);
    
    self.imageView.frame = imageViewFrame;
    
    // Corner radius of image view
    self.imageView.layer.cornerRadius = floorf(imageViewFrame.size.width * self.cornerRadiusRatio);
    
    // Set selectedImageView properties equal to image view properties
    if(self.selectedImageView) {
        self.selectedImageView.frame = imageViewFrame;
    }
}

#pragma mark - Border

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    
    if(!self.selected) {
        self.imageView.layer.borderColor = _borderColor.CGColor;
    } else {
        self.imageView.layer.borderColor = _selectedBorderColor.CGColor;
    }
}

- (void)setSelectedBorderColor:(UIColor *)selectedBorderColor
{
    _selectedBorderColor = selectedBorderColor;
 
    if(self.selected) {
        self.imageView.layer.borderColor = _selectedBorderColor.CGColor;
    } else {
        self.imageView.layer.borderColor = _borderColor.CGColor;
    }
}

#pragma mark - Selected

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if(_selected == YES) {
        
        if(!self.selectedImageView) {
            self.selectedImageView                 = [[UIImageView alloc] init];
            self.selectedImageView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.50];
            self.selectedImageView.image           = [UIImage imageNamed:@"Checkmark"];
            self.selectedImageView.contentMode     = UIViewContentModeCenter;
            
            [self.imageView addSubview:self.selectedImageView];
        }
        
        self.layer.borderColor = self.selectedBorderColor.CGColor;
        
        [self layoutSubviews];
        
    } else {
        
        if(self.selectedImageView) {
            [self.selectedImageView removeFromSuperview];
            _selectedImageView = nil;
        }

        self.layer.borderColor = self.borderColor.CGColor;

    }
}

#pragma mark - Tap

- (void)handleTap:(id)sender
{
    if(self.actionBlock) {
        self.actionBlock(self);
    }
}

- (void)setTappable:(BOOL)tappable
{
    _tappable = tappable;
    
    if(_tappable == YES) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        
        [self addGestureRecognizer:self.tapGesture];
    } else if (!_tappable && self.tapGesture) {
        [self removeGestureRecognizer:self.tapGesture];
    }
}
@end
