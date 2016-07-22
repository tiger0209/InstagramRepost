//
//  ActivityIndicatorFooterView.m
//  InstagramFollowers
//
//  Created by Michael Orcutt on 11/3/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "ActivityIndicatorFooterView.h"

@implementation ActivityIndicatorFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.activityIndicator       = [[UIActivityIndicatorView alloc] init];
        self.activityIndicator.color = [UIColor colorWithRed:75.0/255.0 green:84.0/255.0 blue:87.0/255.0 alpha:1.0];

        [self addSubview:self.activityIndicator];
        
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.activityIndicator.frame = self.bounds;
}

@end
