//
//  UserView.m
//  Instafollowers
//
//  Created by Michael Orcutt on 2/17/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "UserView.h"

// Networking
//#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "Constants.h"

@interface UserView ()

// Layout
@property (nonatomic) UserViewLayout layout;

@end

@implementation UserView

#pragma mark - init

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithLayout:UserViewLayoutCompareViewController];
}

- (id)initWithLayout:(UserViewLayout)layout
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        // Set the layout
        self.layout = layout;
        
        // Profile picture container
        self.profilePictureContainerView             = [[MORoundedImageContainerView alloc] init];
        self.profilePictureContainerView.borderColor = [UIColor whiteColor];
        self.profilePictureContainerView.selected    = NO;

        // Action block for profile picture
        __unsafe_unretained typeof(self) weakSelf = self;

        self.profilePictureContainerView.actionBlock = ^(id sender){
            if([weakSelf.delegate respondsToSelector:@selector(profilePictureContainerViewWasTapped)]) {
                [weakSelf.delegate profilePictureContainerViewWasTapped];
            }
        };
        
        [self addSubview:self.profilePictureContainerView];
        
        // Text label
        self.textLabel               = [[UILabel alloc] init];
        self.textLabel.font          = [UIFont fontWithName:@"Ubuntu-Light" size:17.0];
        self.textLabel.textColor     = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.textLabel];
        
        // Add detail text label in these cases
        if(self.layout == UserViewLayoutPromoteViewController
        || self.layout == UserViewLayoutFollowUsersViewController
        || self.layout == UserViewLayoutProfileViewController) {
            
            // Detail text label
            self.detailTextLabel               = [[UILabel alloc] init];
            self.detailTextLabel.font          = [UIFont fontWithName:@"Ubuntu-Light" size:16.0];
            self.detailTextLabel.textColor     = [UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0];
            self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
            self.detailTextLabel.numberOfLines = 0;
            
            [self addSubview:self.detailTextLabel];

            // Set the max detail text label height
            // by default to be 40.0
            self.maxDetailTextLabelHeight = 40.0;
            
        }
        
        // Add relationship labels in these cases
        if(self.layout == UserViewLayoutCompareViewController
        || self.layout == UserViewLayoutFollowUsersViewController
        || self.layout == UserViewLayoutProfileViewController) {
            
            // Relationship labels text color based upon layout
            UIColor *relationshipLabelsTextColor;
            if(self.layout == UserViewLayoutProfileViewController || self.layout == UserViewLayoutFollowUsersViewController) {
                relationshipLabelsTextColor = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0];
            } else {
                relationshipLabelsTextColor = [UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0];
            }
            
            // Following label
            self.followingLabel               = [[UILabel alloc] init];
            self.followingLabel.font          = [UIFont fontWithName:@"Ubuntu-Light" size:16.0];
            self.followingLabel.textColor     = relationshipLabelsTextColor;
            self.followingLabel.textAlignment = NSTextAlignmentCenter;
            self.followingLabel.numberOfLines = 2;

            [self addSubview:self.followingLabel];
            
            // Followers label
            self.followersLabel               = [[UILabel alloc] init];
            self.followersLabel.font          = [UIFont fontWithName:@"Ubuntu-Light" size:16.0];
            self.followersLabel.textColor     = relationshipLabelsTextColor;
            self.followersLabel.textAlignment = NSTextAlignmentCenter;
            self.followersLabel.numberOfLines = 2;
            
            [self addSubview:self.followersLabel];
            
        }
     
        // Add tap gesture to handle label delegate methods
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];

        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Layout setup
    CGRect bounds = self.bounds;
    
    // Center profile picture
    CGRect profilePictureContainerViewFrame;
    profilePictureContainerViewFrame.origin = CGPointMake(floor((bounds.size.width - UserProfileImageSize)/2.0), self.topContentInset);
    profilePictureContainerViewFrame.size   = CGSizeMake(UserProfileImageSize, UserProfileImageSize);
    
    self.profilePictureContainerView.frame = profilePictureContainerViewFrame;

    // Text label under profile picture
    CGRect textLabelFrame;
    textLabelFrame.size
    = [self.textLabel.text sizeWithAttributes:@{ NSFontAttributeName : self.textLabel.font }];
    textLabelFrame.size.width
    = (bounds.size.width - TableViewCellInset * 2.0);
    textLabelFrame.origin
    = CGPointMake(TableViewCellInset, (profilePictureContainerViewFrame.origin.y + profilePictureContainerViewFrame.size.height + VerticalSpacing/2.0));
    
    self.textLabel.frame = textLabelFrame;
    
    // If this user view layout is supplied to a profile view controller, compare view controller, or a
    // follow users view controller, layout the relationship labels
    if(self.layout == UserViewLayoutCompareViewController
    || self.layout == UserViewLayoutFollowUsersViewController
    || self.layout == UserViewLayoutProfileViewController) {
        
        // Relationship labels
        CGRect followersLabelFrame;
        followersLabelFrame.size
        = CGSizeMake(floorf((bounds.size.width - UserProfileImageSize - TableViewCellInset * 4.0)/2.0), UserProfileImageSize);
        followersLabelFrame.origin
        = CGPointMake(TableViewCellInset, profilePictureContainerViewFrame.origin.y);
        
        self.followersLabel.frame = followersLabelFrame;
        
        CGRect followingLabelFrame;
        followingLabelFrame.size
        = CGSizeMake(floorf((bounds.size.width - UserProfileImageSize - TableViewCellInset * 4.0)/2.0), UserProfileImageSize);
        followingLabelFrame.origin
        = CGPointMake((bounds.size.width - followingLabelFrame.size.width - TableViewCellInset), profilePictureContainerViewFrame.origin.y);
        
        self.followingLabel.frame = followingLabelFrame;

        
        // If the layout is supplied for a profile view controller or promote view controller,
        // layout the detail text label prior to laying out relationship labels
        if(self.layout == UserViewLayoutFollowUsersViewController || self.layout == UserViewLayoutProfileViewController) {
            
            // Detail text label under text label
            CGRect detailTextLabelFrame;
            detailTextLabelFrame.origin     = CGPointMake(TableViewCellInset, (textLabelFrame.origin.y + textLabelFrame.size.height));
            detailTextLabelFrame.size.width = (bounds.size.width - TableViewCellInset * 2.0);
            detailTextLabelFrame.size.height
            = [self.detailTextLabel.text boundingRectWithSize:CGSizeMake(detailTextLabelFrame.size.width, self.maxDetailTextLabelHeight)
                                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                   attributes:@{ NSFontAttributeName : self.detailTextLabel.font }
                                                      context:nil].size.height;
            
            self.detailTextLabel.frame = detailTextLabelFrame;
            
        }
        
    } else if(self.layout == UserViewLayoutPromoteViewController) {
        
        // Detail text label under text label
        CGRect detailTextLabelFrame;
        detailTextLabelFrame.origin     = CGPointMake(TableViewCellInset, (textLabelFrame.origin.y + textLabelFrame.size.height));
        detailTextLabelFrame.size.width = (bounds.size.width - TableViewCellInset * 2.0);
        detailTextLabelFrame.size.height
        = [self.detailTextLabel.text boundingRectWithSize:CGSizeMake(detailTextLabelFrame.size.width, self.maxDetailTextLabelHeight)
                                                  options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                               attributes:@{ NSFontAttributeName : self.detailTextLabel.font }
                                                  context:nil].size.height;
        
        self.detailTextLabel.frame = detailTextLabelFrame;
        
    }
}

- (void)sizeToFit
{
    [super sizeToFit];
    
    // Layout setup
    CGRect superViewBounds = self.superview.bounds;
    
    CGRect bounds;
    bounds.origin = CGPointMake(0.0, 0.0);
    
    // Add profile picture height and offset height
    //bounds.size.height += self.topContentInset;
    bounds.size.height += UserProfileImageSize;
    bounds.size.height += self.topContentInset;
    
    // Add text label text plus vertical spacing between
    // profile picture and text label
    bounds.size.height += (VerticalSpacing / 2.0);
    bounds.size.height += [self.textLabel.text sizeWithAttributes:@{ NSFontAttributeName : self.textLabel.font }].height;
    
    // Add height detail text label
    CGSize detailTextLabelMaxSize = CGSizeMake((superViewBounds.size.width - TableViewCellInset * 2.0), self.maxDetailTextLabelHeight);
    
    bounds.size.height
    += [self.detailTextLabel.text boundingRectWithSize:detailTextLabelMaxSize
                                               options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                            attributes:@{ NSFontAttributeName : self.detailTextLabel.font }
                                               context:nil].size.height;
    
    // Set bounds
    self.bounds = bounds;
}

- (CGFloat)height
{
    CGRect superViewBounds = self.superview.bounds;
    
    CGRect bounds;
    bounds.origin = CGPointMake(0.0, 0.0);
    
    // Add profile picture height and offset height
    //bounds.size.height += self.topContentInset;
    bounds.size.height += UserProfileImageSize;
    bounds.size.height += self.topContentInset;
    
    // Add text label text plus vertical spacing between
    // profile picture and text label
    bounds.size.height += (VerticalSpacing / 2.0);
    bounds.size.height += [self.textLabel.text sizeWithAttributes:@{ NSFontAttributeName : self.textLabel.font }].height;
    
    // Add height detail text label
    CGSize detailTextLabelMaxSize = CGSizeMake((superViewBounds.size.width - TableViewCellInset * 2.0), self.maxDetailTextLabelHeight);
    
    bounds.size.height
    += [self.detailTextLabel.text boundingRectWithSize:detailTextLabelMaxSize
                                               options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                            attributes:@{ NSFontAttributeName : self.detailTextLabel.font }
                                               context:nil].size.height;
    
    return bounds.size.height;
}

- (void)setUser:(InstagramUser *)user
{
    _user = user;
    
    // Set text label as username
    self.textLabel.text = self.user.username;
    
    // Profile picture
    [self.profilePictureContainerView.imageView sd_setImageWithURL:self.user.profilePictureURL];
    
    // Set detail text label based upon layout
    if(self.layout == UserViewLayoutFollowUsersViewController
    || self.layout == UserViewLayoutProfileViewController
    || self.layout == UserViewLayoutPromoteViewController) {
        self.detailTextLabel.text = self.user.bio;
    }
    
    // Set followers and following labels
    // with attributed strings
    [self setFollowersAndFollowingLabels];
}

#pragma mark - Set text labels

- (void)setFollowersAndFollowingLabels
{
    // Setup for attributed strings
    NSDictionary *attributes
    = @{ NSFontAttributeName            : [UIFont fontWithName:@"Ubuntu-Light" size:16.0],
         NSForegroundColorAttributeName : [UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0] };

    NSDictionary *numberAttributes
    = @{ NSFontAttributeName            : [UIFont fontWithName:@"Ubuntu-Light" size:17.0],
         NSForegroundColorAttributeName : [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0] };

    // Followers setup
    NSString *followersString;
    if([self.user.followersCount integerValue] == 1) {
        followersString = @"Follower";
    } else {
        followersString = @"Followers";
    }
    
    // Followers attributed string
    NSMutableAttributedString *followersAttributedString
    = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", self.user.followersCount, followersString]
                                             attributes:attributes];
    
    // Number attributes
    [followersAttributedString setAttributes:numberAttributes range:NSMakeRange(0, self.user.followersCount.length)];
    
    // Set attributed text
    self.followersLabel.attributedText = followersAttributedString;
    
    // Following attributed string
    NSMutableAttributedString *followingAttributedString
    = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nFollowing", self.user.followsCount] attributes:attributes];
    
    [followingAttributedString setAttributes:numberAttributes range:NSMakeRange(0, self.user.followsCount.length)];
    
    self.followingLabel.attributedText = followingAttributedString;
}

#pragma mark - Tap Gesture

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    CGPoint tapPoint = [sender locationInView:self];
    
    if(CGRectContainsPoint(self.textLabel.frame, tapPoint)) {
        if([self.delegate respondsToSelector:@selector(textLabelWasTapped)]) {
            [self.delegate textLabelWasTapped];
        }
    } else if(CGRectContainsPoint(self.followersLabel.frame, tapPoint)) {
        if([self.delegate respondsToSelector:@selector(followersLabelWasTapped)]) {
            [self.delegate followersLabelWasTapped];
        }
    } else if(CGRectContainsPoint(self.followingLabel.frame, tapPoint)) {
        if([self.delegate respondsToSelector:@selector(followingLabelWasTapped)]) {
            [self.delegate followingLabelWasTapped];
        }
    }
}


@end
