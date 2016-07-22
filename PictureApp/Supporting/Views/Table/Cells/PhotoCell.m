//
//  PhotoCell.m
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/17/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "PhotoCell.h"
#import "Constants.h"

@interface PhotoCell ()

// Failure properties
@property (strong, nonatomic) UIButton *failureButton;

@end

@implementation PhotoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        // Not selectable
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Progress view
        self.progressView                   = [[UIProgressView alloc] init];
        self.progressView.trackTintColor    = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0];
        self.progressView.progressTintColor = [UIColor colorWithRed:224.0/255.0 green:226.0/255.0 blue:229.0/255.0 alpha:1.0];
        
        [self.contentView addSubview:self.progressView];
        
        // Photo image view
        self.photoImageView = [[UIImageView alloc] init];
        
        [self.contentView addSubview:self.photoImageView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    // Photo image view frame
    self.photoImageView.frame = bounds;
    
    CGRect progressViewFrame;
    progressViewFrame.size   = CGSizeMake((bounds.size.width - TableViewCellInset*2.0), 4.0);
    progressViewFrame.origin = CGPointMake(TableViewCellInset, floor((bounds.size.height - 4.0)/2.0));
    
    self.progressView.frame = progressViewFrame;
}

- (void)setFailure:(BOOL)failure
{
    _failure = failure;
    
    if(_failure == YES) {
    
        if(!self.failureButton) {
            self.failureButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.failureButton setImage:[UIImage imageNamed:@"Refresh"] forState:UIControlStateNormal];
            [self.failureButton addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.contentView insertSubview:self.failureButton aboveSubview:self.progressView];
        }
        
    } else if(_failure == NO) {
        
    }
}

- (void)handleRefresh:(id)sender
{

}

@end
