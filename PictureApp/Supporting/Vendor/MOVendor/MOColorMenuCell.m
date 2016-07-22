//
//  MOColorMenuCell.m
//  Instafollowers
//
//  Created by Michael Orcutt on 2/26/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "MOColorMenuCell.h"

@interface MOColorMenuCell ()

@property (strong, nonatomic) UIView *colorContainerView;
@property (strong, nonatomic) UIView *colorView;

@end

@implementation MOColorMenuCell

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.colorContainerView                   = [[UIView alloc] init];
        self.colorContainerView.layer.borderWidth = 1.0;
        
        [self addSubview:self.colorContainerView];
        
        self.colorView = [[UIView alloc] init];
        
        [self.colorContainerView addSubview:self.colorView];
    
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Layout setup
    CGRect bounds = self.bounds;
    
    // Color containe view frame and corner radius
    CGRect colorContainerViewFrame     = bounds;
    colorContainerViewFrame.size.width = colorContainerViewFrame.size.height;
    colorContainerViewFrame.origin.x   = floorf((bounds.size.width - colorContainerViewFrame.size.width)/2.0);
    
    self.colorContainerView.frame              = colorContainerViewFrame;
    self.colorContainerView.layer.cornerRadius = (colorContainerViewFrame.size.height/2.0);

    // Color view frame and corner radius
    CGFloat inset = 3.0;
    
    CGRect colorViewFrame   = colorContainerViewFrame;
    colorViewFrame.origin.x = inset;
    colorViewFrame.origin.y = inset;
    colorViewFrame.size     = CGSizeMake((colorContainerViewFrame.size.width - (inset * 2.0)), (colorContainerViewFrame.size.height - (inset * 2.0)));
    
    self.colorView.frame              = colorViewFrame;
    self.colorView.layer.cornerRadius = (colorViewFrame.size.width/2.0);
}

#pragma mark - Selected

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if(selected) {
        self.colorContainerView.layer.borderWidth = 1.0;
    } else {
        self.colorContainerView.layer.borderWidth = 0.0;
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if(highlighted) {
        self.colorContainerView.layer.borderWidth = 1.0;
    } else {
        if(self.selected) {
            self.colorContainerView.layer.borderWidth = 1.0;
        } else {
            self.colorContainerView.layer.borderWidth = 0.0;
        }
    }
}

#pragma mark - Color

- (void)setColor:(UIColor *)color
{
    if(_color == color) {
        return;
    }
    
    _color = color;
    
    self.colorContainerView.layer.borderColor = _color.CGColor;
    self.colorView.backgroundColor            = _color;
}

@end
