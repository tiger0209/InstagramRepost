//
//  MOCancelButton.m
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/31/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "MOCancelButton.h"

@interface MOCancelButton ()

@property (strong, nonatomic) UIView *separator;

@property (strong, nonatomic) UIImageView *cancelImageView;

@end

@implementation MOCancelButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.cornerRadius = 2.0;

        self.textLabel                 = [[UILabel alloc] init];
        self.textLabel.font            = [UIFont fontWithName:@"Ubuntu-Light" size:15.5];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor       = [UIColor colorWithWhite:1.0 alpha:.90];
        
        [self addSubview:self.textLabel];
        
        self.imageView             = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.alpha       = .90;
        
        [self addSubview:self.imageView];
        
        self.cancelImageView             = [[UIImageView alloc] init];
        self.cancelImageView.image       = [UIImage imageNamed:@"Cancel"];
        self.cancelImageView.alpha       = .60;
        self.cancelImageView.contentMode = UIViewContentModeCenter;
        
        [self addSubview:self.cancelImageView];
        
        self.separator                 = [[UIView alloc] init];
        self.separator.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.60];
        
        [self addSubview:self.separator];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        
        [self addGestureRecognizer:tapGesture];
    
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGRect imageViewFrame;
    imageViewFrame.size   = CGSizeMake(bounds.size.height, bounds.size.height);
    imageViewFrame.origin = CGPointMake(0.0, 0.0);
    
    self.imageView.frame = imageViewFrame;
    
    CGRect cancelImageViewFrame   = imageViewFrame;
    cancelImageViewFrame.origin.x = (bounds.size.width - cancelImageViewFrame.size.width);
    
    self.cancelImageView.frame = cancelImageViewFrame;
    
    CGRect separatorFrame;
    separatorFrame.origin.x = cancelImageViewFrame.origin.x;
    separatorFrame.origin.y = 5.0;
    separatorFrame.size     = CGSizeMake(.50, (bounds.size.height - 10.0));
    
    self.separator.frame = separatorFrame;
    
    CGRect textLabelFrame;
    textLabelFrame.origin      = CGPointMake(imageViewFrame.size.width, 0.0);
    textLabelFrame.size.width  = (bounds.size.width - imageViewFrame.size.width - cancelImageViewFrame.size.width);
    textLabelFrame.size.height = bounds.size.height;
    
    self.textLabel.frame = textLabelFrame;
}

- (void)handleTap:(id)sender
{
    CGPoint tapPoint = [sender locationInView:self];
    
    if(CGRectContainsPoint(self.cancelImageView.frame, tapPoint)) {

        if(self.cancelBlock) {
            self.cancelBlock();
        }
        
    } else {

        if(self.actionBlock) {
            self.actionBlock();
        }
        
    }
}

@end
