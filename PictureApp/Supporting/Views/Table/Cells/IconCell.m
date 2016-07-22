//
//  IconCell.m
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/27/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "IconCell.h"
#import "Constants.h"

@implementation IconCell

#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Selected background view
        UIView *selectedBackgroundView         = [[UIView alloc] init];
        selectedBackgroundView.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:226.0/255.0 blue:229.0/255.0 alpha:1.0];
        
        self.selectedBackgroundView = selectedBackgroundView;

        // Text label
        self.textLabel.font      = [UIFont fontWithName:@"Ubuntu-Light" size:16.0];
        self.textLabel.textColor = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0];
        
        // Icon image view
        self.iconImageView             = [[UIImageView alloc] init];
        self.iconImageView.contentMode = UIViewContentModeLeft;
        
        [self.contentView addSubview:self.iconImageView];

    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGRect iconImageViewFrame;
    iconImageViewFrame.size   = CGSizeMake(23.0, bounds.size.height);
    iconImageViewFrame.origin = CGPointMake(TableViewCellInset, 0.0);
    
    self.iconImageView.frame = iconImageViewFrame;
    
    CGRect textLabelFrame     = self.textLabel.frame;
    textLabelFrame.origin.x   = (iconImageViewFrame.origin.x + iconImageViewFrame.size.width + 8.0);
    textLabelFrame.size.width = (bounds.size.width - textLabelFrame.origin.x - TableViewCellInset);
    
    self.textLabel.frame = textLabelFrame;
}

@end
