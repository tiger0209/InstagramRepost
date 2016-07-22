//
//  MediaCell.m
//  InstagramFollowers
//
//  Created by Michael Orcutt on 10/30/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "MediaCell.h"

@implementation MediaCell

#pragma mark - Initilization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Image view initialization and properties
        self.imageView                   = [[UIImageView alloc] init];
        self.imageView.layer.borderColor = [UIColor colorWithWhite:.95 alpha:1.0].CGColor;
        self.imageView.layer.borderWidth = 1.0;

        [self addSubview:self.imageView];
        
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Image view takes up
    // entire collection cell
    self.imageView.frame = self.bounds;
}

@end
