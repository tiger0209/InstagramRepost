//
//  UserCell.m
//  Instafollowers
//
//  Created by Michael Orcutt on 2/23/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "UserCell.h"
#import "Constants.h"

@implementation UserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Self
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        // Text labels
        self.textLabel.font          = [UIFont fontWithName:@"Ubuntu-Light" size:16.0];
        self.textLabel.numberOfLines = 3;
        self.textLabel.textColor     = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0];
        
        self.detailTextLabel.font          = [UIFont fontWithName:@"Ubuntu-Light" size:16.0];
        self.detailTextLabel.textColor     = [UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0];
        self.detailTextLabel.numberOfLines = 0;
        
        // Profile picture container
        self.profilePictureContainerView             = [[MORoundedImageContainerView alloc] init];
        self.profilePictureContainerView.borderColor = [UIColor colorWithRed:224.0/255.0 green:226.0/255.0 blue:229.0/255.0 alpha:1.0];
        self.profilePictureContainerView.selected    = NO;
        
        [self addSubview:self.profilePictureContainerView];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGRect profilePictureContainerViewFrame;
    profilePictureContainerViewFrame.size   = CGSizeMake(UserTableCellProfileImageSize, UserTableCellProfileImageSize);
    profilePictureContainerViewFrame.origin = CGPointMake(TableViewCellInset, (VerticalSpacing / 4.0));
    
    self.profilePictureContainerView.frame = profilePictureContainerViewFrame;
    
    // Labels
    CGSize maxLabelSize = CGSizeMake((bounds.size.width
                                      - profilePictureContainerViewFrame.origin.x
                                      - profilePictureContainerViewFrame.size.width
                                      - TableViewCellInset
                                      - TextHorizontalSpacing), CGFLOAT_MAX);
    
    CGRect textLabelFrame;
    
    if(self.textLabel.text) {
        textLabelFrame.size
        = [self.textLabel.text boundingRectWithSize:maxLabelSize
                                            options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                         attributes:@{ NSFontAttributeName : self.textLabel.font }
                                            context:nil].size;
    } else if(self.textLabel.attributedText) {
        textLabelFrame.size
        = [self.textLabel.attributedText boundingRectWithSize:maxLabelSize
                                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                      context:nil].size;
    }
    
    CGRect detailTextLabelFrame;
    
    if(self.detailTextLabel.text) {
        detailTextLabelFrame.size
        = [self.detailTextLabel.text boundingRectWithSize:maxLabelSize
                                                  options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                               attributes:@{ NSFontAttributeName : self.detailTextLabel.font }
                                                  context:nil].size;
    } else if(self.detailTextLabel.attributedText) {
        detailTextLabelFrame.size
        = [self.detailTextLabel.attributedText boundingRectWithSize:maxLabelSize
                                                            options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                            context:nil].size;
    }
    
    // Label origin
    CGPoint labelOrigin
    = CGPointMake((profilePictureContainerViewFrame.origin.x + profilePictureContainerViewFrame.size.width + TextHorizontalSpacing),
                  floorf((bounds.size.height - textLabelFrame.size.height - detailTextLabelFrame.size.height)/2.0));
    
    // Set label frames
    textLabelFrame.origin = labelOrigin;
    
    self.textLabel.frame = textLabelFrame;
    
    labelOrigin.y += textLabelFrame.size.height;
    
    detailTextLabelFrame.origin = labelOrigin;
    
    self.detailTextLabel.frame = detailTextLabelFrame;
}

@end
