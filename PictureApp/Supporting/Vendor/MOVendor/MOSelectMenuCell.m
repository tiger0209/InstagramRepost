//
//  MOSelectMenuCell.m
//  Instafollowers
//
//  Created by Michael Orcutt on 2/16/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "MOSelectMenuCell.h"

@interface MOSelectMenuCell ()

@property (strong, nonatomic) UIView *underline;

@end

@implementation MOSelectMenuCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.textLabel                 = [[UILabel alloc] init];
        self.textLabel.font            = [UIFont fontWithName:@"Ubuntu-Light" size:16.0];
        self.textLabel.textColor       = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.textLabel];
        
        self.underline                 = [[UIView alloc] init];
        self.underline.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:226.0/255.0 blue:229.0/255.0 alpha:1.0];
        
        [self addSubview:self.underline];
        
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Setup
    CGRect bounds = self.bounds;
    
    // Text label
    CGRect textLabelFrame;
    textLabelFrame.size   = [self.textLabel.text sizeWithAttributes:@{ NSFontAttributeName : self.textLabel.font }];
    textLabelFrame.origin = CGPointMake(0.0, floorf((bounds.size.height - textLabelFrame.size.height)/2.0));
    
    self.textLabel.frame = self.bounds;
    
    // Underline text label
    CGRect underlineFrame;
    underlineFrame             = bounds;
    underlineFrame.size.height = .50;
    underlineFrame.origin.y    = (textLabelFrame.origin.y + textLabelFrame.size.height + 2.0);

    self.underline.frame = underlineFrame;
}

#pragma mark - Highlight and select

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if(highlighted == YES) {
        self.textLabel.textColor = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0];
        self.underline.hidden    = NO;
    } else {
        if(self.selected) {
            self.textLabel.textColor = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0];
            self.underline.hidden    = NO;
        } else {
            self.textLabel.textColor = [UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0];
            self.underline.hidden    = YES;
        }
    }

}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if(selected == YES) {
        self.textLabel.textColor = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0];
        self.underline.hidden    = NO;
    } else {
        self.textLabel.textColor = [UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0];
        self.underline.hidden    = YES;
    }
}

@end
