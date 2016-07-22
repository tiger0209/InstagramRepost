//
//  PrivateCell.m
//  Instafollowers
//
//  Created by Michael Orcutt on 4/1/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "PrivateCell.h"

#import "MOMessageIconView.h"

@interface PrivateCell ()

@property (strong, nonatomic) MOMessageIconView *messageIconView;
@end

@implementation PrivateCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
        self.messageIconView                 = [[MOMessageIconView alloc] initWithFrame:CGRectZero layout:MOMessageIconViewLayoutDefault];
        self.messageIconView.textLabel.text  = @"This user is private";
        self.messageIconView.imageView.image = [UIImage imageNamed:@"LockMessageIcon"];

        [self addSubview:self.messageIconView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.messageIconView.frame = self.bounds;
}

@end
