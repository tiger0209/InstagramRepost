//
//  ProfileHeaderView.m
//  Instafollowers
//
//  Created by Michael Orcutt on 2/27/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "ProfileHeaderView.h"

#import "UIColor+String.h"

@implementation ProfileHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // User view takes care of
        self.userView                          = [[UserView alloc] initWithLayout:UserViewLayoutProfileViewController];
        self.userView.topContentInset          = VerticalSpacing;
        self.userView.maxDetailTextLabelHeight = CGFLOAT_MAX;

        [self addSubview:self.userView];
        
        // Follow button
        self.followButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        [self.followButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, -5.0)];
        [self.followButton setContentEdgeInsets:UIEdgeInsetsMake(0.0, 12.0, 0.0, 17.0)];
        [self.followButton.titleLabel setFont:[UIFont fontWithName:@"Ubuntu" size:15.0]];
        [self.followButton.layer setCornerRadius:4.0];
        [self.followButton.layer setBorderWidth:1.0];
        [self.followButton setAlpha:0.0];
        [self.followButton addTarget:self action:@selector(handleFollowButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.followButton];
        
        // Relationship label
        self.relationshipLabel               = [[UILabel alloc] init];
        self.relationshipLabel.font          = [UIFont fontWithName:@"Ubuntu-Light" size:16.0];
        self.relationshipLabel.textColor     = [UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0];
        self.relationshipLabel.textAlignment = NSTextAlignmentCenter;
        self.relationshipLabel.alpha         = 0.0;
        
        [self addSubview:self.relationshipLabel];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Layout setup
    CGRect bounds = self.bounds;
    
    // Size to fit user view
    CGRect userViewFrame      = bounds;
    userViewFrame.origin      = CGPointMake(0.0, 0.0);
    userViewFrame.size.width  = bounds.size.width;
    userViewFrame.size.height = self.userView.height;
    
    self.userView.frame = userViewFrame;
 
    // Layout relationship views
    [self layoutRelationshipViews];
}

- (void)layoutRelationshipViews
{
    // Setup
    CGRect bounds = self.bounds;
    
    // Follow button
    [self.followButton sizeToFit];
    
    CGRect followButtonFrame      = self.followButton.bounds;
    followButtonFrame.size.height = RoundedButtonHeight;
    followButtonFrame.origin.x    = floorf((bounds.size.width - followButtonFrame.size.width)/2.0);
    followButtonFrame.origin.y    = floorf(self.userView.frame.size.height) + (VerticalSpacing / 2.0);
    
    self.followButton.frame = followButtonFrame;
    
    // Relationshiop label
    CGRect relationshipLabelFrame;
    relationshipLabelFrame.size.width  = (bounds.size.width - TableViewCellInset * 2.0);
    relationshipLabelFrame.origin.x    = TableViewCellInset;
    relationshipLabelFrame.origin.y    = (followButtonFrame.origin.y + followButtonFrame.size.height + VerticalSpacing / 2.0);
    relationshipLabelFrame.size.height
    = [self.relationshipLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 20.0)
                                                options:(NSStringDrawingUsesLineFragmentOrigin |    NSStringDrawingUsesFontLeading)
                                             attributes:@{ NSFontAttributeName : self.relationshipLabel.font }
                                                context:nil].size.height;
    
    self.relationshipLabel.frame = relationshipLabelFrame;
}

- (void)setIncomingRelationship:(Relationship)incomingRelationship
{
    _incomingRelationship = incomingRelationship;
    
    if(_incomingRelationship == RelationshipUnknown || _incomingRelationship == RelationshipNotLoaded || _incomingRelationship == RelationshipSelf)
        return;
    
    NSString *relationshipDetailsLabelText;
    
    if(_incomingRelationship == RelationshipFollowing) {
        relationshipDetailsLabelText = NSLocalizedString(@"Follows you", nil);
    } else if(_incomingRelationship == RelationshipRequested) {
        relationshipDetailsLabelText = NSLocalizedString(@"Requested you", nil);
    } else if(_incomingRelationship == RelationshipNotFollowing) {
        relationshipDetailsLabelText = NSLocalizedString(@"Not following you", nil);
    } else if(_incomingRelationship == RelationshipSelf) {
        relationshipDetailsLabelText = NSLocalizedString(@"This is you", nil);
    }
    
    self.relationshipLabel.text = relationshipDetailsLabelText;
    
    // Relayout
    [self layoutRelationshipViews];

    // Animate in view with delay, setting tint
    // appears to have an animation that we do
    // not want the user to see
    [UIView animateWithDuration:.25 delay:.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.relationshipLabel.alpha = 1.0;
    } completion:nil];
}

- (void)setOutgoingRelationship:(Relationship)outgoingRelationship
{
    _outgoingRelationship = outgoingRelationship;
    
    if(_outgoingRelationship == RelationshipSelf || _outgoingRelationship == RelationshipUnknown || _outgoingRelationship == RelationshipNotLoaded)
        return;
    
    NSString *followButtonTitle;
    UIColor *color;
    UIImage *image;
    
    if(_outgoingRelationship == RelationshipFollowing) {
        followButtonTitle = NSLocalizedString(@"Following", nil);
        color             = [UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0];
        image             = [UIImage imageNamed:@"UserMinus"];
    } else if(_outgoingRelationship == RelationshipRequested) {
        followButtonTitle = NSLocalizedString(@"Requested", nil);
        color             = [UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0];
        image             = [UIImage imageNamed:@"User"];
    } else if(_outgoingRelationship == RelationshipNotFollowing || _outgoingRelationship == RelationshipNotFollowingPrivate) {
        if(_outgoingRelationship == RelationshipNotFollowingPrivate) {
            followButtonTitle = NSLocalizedString(@"Request", nil);
        } else {
            followButtonTitle = NSLocalizedString(@"Follow", nil);
        }
        color             = [UIColor colorWithRed:51.0/255.0 green:177.0/255.0 blue:233.0/255.0 alpha:1.0];
        image             = [UIImage imageNamed:@"UserPlus"];
    }
    
    // Set follow button border color, tint color, and image
    [[self.followButton layer] setBorderColor:color.CGColor];
    [self.followButton setTitleColor:color forState:UIControlStateNormal];
    [self.followButton setTintColor:color];
    
    // Set title
    [self.followButton setTitle:followButtonTitle forState:UIControlStateNormal];
    
    // Set image
    [self.followButton setImage:image forState:UIControlStateNormal];
    
    // Relayout
    [self layoutRelationshipViews];
    
    // Animate in view with delay, setting tint
    // appears to have an animation that we do
    // not want the user to see
    [UIView animateWithDuration:.25 delay:.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.followButton setAlpha:1.0];
    } completion:nil];
}

- (void)handleFollowButtonTap:(id)sender
{
    if(self.followButtonTapBlock) {
        self.followButtonTapBlock();
    }
}

@end
