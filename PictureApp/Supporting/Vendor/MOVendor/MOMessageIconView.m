//
//  MOMessageIconView.m
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/30/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "MOMessageIconView.h"
#import "Constants.h"

@interface MOMessageIconView ()

@property (strong, nonatomic) UIButton *refreshButton;

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@end

@implementation MOMessageIconView

- (id)initWithFrame:(CGRect)frame layout:(MOMessageIconViewLayout)layout
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Layout
        self.layout = layout;

        // Subviews
        self.imageView = [[UIImageView alloc] init];

        [self addSubview:self.imageView];
        
        self.textLabel               = [[UILabel alloc] init];
        self.textLabel.font          = [UIFont fontWithName:@"Ubuntu-Light" size:16.0];
        self.textLabel.textColor     = [UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0];
        self.textLabel.numberOfLines = 0;
        self.textLabel.textAlignment = NSTextAlignmentCenter;

        [self addSubview:self.textLabel];
        
        // Add detail text label if subtitle layout
        if(self.layout == MOMessageIconViewLayoutSubtitle) {
            
            self.detailTextLabel               = [[UILabel alloc] init];
            self.detailTextLabel.font          = [UIFont fontWithName:@"Ubuntu-Light" size:16.0];
            self.detailTextLabel.textColor     = [UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:.85];
            self.detailTextLabel.numberOfLines = 0;
            self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
            
            [self addSubview:self.detailTextLabel];
            
        }
                
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGRect imageViewFrame;
    imageViewFrame.size = self.imageView.image.size;
    
    CGRect textLabelFrame;
    textLabelFrame.size = [self.textLabel.text boundingRectWithSize:CGSizeMake((bounds.size.width - TableViewCellInset * 4.0), MAXFLOAT)
                                                            options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                         attributes:@{ NSFontAttributeName : self.textLabel.font }
                                                            context:nil].size;
    
    if(self.layout == MOMessageIconViewLayoutDefault) {
        imageViewFrame.origin
        = CGPointMake(floorf((bounds.size.width - imageViewFrame.size.width)/2.0), floorf((bounds.size.height - imageViewFrame.size.height - textLabelFrame.size.height - TableViewCellInset)/2.0));
        textLabelFrame.origin
        = CGPointMake(floorf((bounds.size.width - textLabelFrame.size.width)/2.0), (imageViewFrame.origin.y + imageViewFrame.size.height + TableViewCellInset));
    } else {
        CGRect detailTextLabelFrame;
        detailTextLabelFrame.size
        = [self.detailTextLabel.text boundingRectWithSize:CGSizeMake((bounds.size.width - TableViewCellInset * 4.0), MAXFLOAT)
                                                  options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                               attributes:@{ NSFontAttributeName : self.detailTextLabel.font }
                                                  context:nil].size;
        imageViewFrame.origin
        = CGPointMake(floorf((bounds.size.width - imageViewFrame.size.width)/2.0),
                      floorf((bounds.size.height - imageViewFrame.size.height - textLabelFrame.size.height - detailTextLabelFrame.size.height - TableViewCellInset - TableViewCellInset/4.0)/2.0));
        textLabelFrame.origin
        = CGPointMake(floorf((bounds.size.width - textLabelFrame.size.width)/2.0), (imageViewFrame.origin.y + imageViewFrame.size.height + TableViewCellInset));
        detailTextLabelFrame.origin
        = CGPointMake(floorf((bounds.size.width - detailTextLabelFrame.size.width)/2.0), (textLabelFrame.origin.y + textLabelFrame.size.height + floorf(TableViewCellInset/4.0)));

        self.detailTextLabel.frame = detailTextLabelFrame;
    }
        
    self.imageView.frame = imageViewFrame;
    self.textLabel.frame = textLabelFrame;
}

#pragma mark - Tap gesture

- (void)setTapEnabled:(BOOL)tapEnabled
{
    _tapEnabled = tapEnabled;

    if(_tapEnabled == YES) {
        
        // Initialize gesture recognizer
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        
        // Add gesture recognizer
        [self addGestureRecognizer:self.tapGesture];
        
    } else if(_tapEnabled == NO && _tapGesture) {
        
        // Remove gesture recogonizer
        [self removeGestureRecognizer:_tapGesture];
        _tapGesture = nil;
        
    }
}

- (void)handleTap:(id)sender
{
    if(self.tapBlock) {
        self.tapBlock();
    } 
}

#pragma mark - Layout setter

- (void)setLayout:(MOMessageIconViewLayout)layout
{
    _layout = layout;
    
    // Add detail text label if subtitle layout
    if(self.layout == MOMessageIconViewLayoutSubtitle && self.detailTextLabel == nil) {
        
        self.detailTextLabel               = [[UILabel alloc] init];
        self.detailTextLabel.font          = [UIFont fontWithName:@"Ubuntu-Light" size:16.0];
        self.detailTextLabel.textColor     = [UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:.85];
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.detailTextLabel];
        
    } else if(self.layout != MOMessageIconViewLayoutSubtitle && self.detailTextLabel) {
        
        // Remove detail text label
        [self.detailTextLabel removeFromSuperview];
        self.detailTextLabel = nil;
        
    }
}

@end
