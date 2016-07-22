//
//  MOMenuCell.m
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/25/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "MOMenuCell.h"
#import "Constants.h"

@implementation MOMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        // Selection style
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Backgrounds
        self.backgroundColor = [UIColor clearColor];
        
        UIView *selectedBackgroundView         = [[UIView alloc] init];
        selectedBackgroundView.backgroundColor = [UIColor clearColor];
        
        self.selectedBackgroundView = selectedBackgroundView;

        // Text label
        self.textLabel.font      = kTableViewCellTextLabelFont;
        self.textLabel.textColor = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if(selected) {
        self.textLabel.textColor = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0];
        
        UIImageView *accessoryViewImageView = [[UIImageView alloc] init];
        accessoryViewImageView.image        = [UIImage imageNamed:@"Checkmark"];
        
        [accessoryViewImageView sizeToFit];
                                               
        self.accessoryView = accessoryViewImageView;
    } else {
        self.textLabel.textColor = [UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0];
        self.accessoryView = nil;
    }
}

@end
