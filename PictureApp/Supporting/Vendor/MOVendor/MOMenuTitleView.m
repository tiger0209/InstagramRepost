//
//  MOMenuTitleView.m
//  Instafollowers
//
//  Created by Michael Orcutt on 2/21/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "MOMenuTitleView.h"

@interface MOMenuTitleView ()

// Views
@property (strong, nonatomic) UILabel     *textLabel;
@property (strong, nonatomic) UIImageView *arrowImageView;

// Arrow view direction
@property (nonatomic) MOMenuTitleViewArrowDirection arrowDirection;

@end

@implementation MOMenuTitleView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor clearColor];
        
        self.textLabel           = [[UILabel alloc] init];
        self.textLabel.font      = [UIFont fontWithName:@"Ubuntu-Light" size:20.0];
        self.textLabel.textColor = [UIColor whiteColor];
        
        [self addSubview:self.textLabel];
        
        self.arrowImageView                 = [[UIImageView alloc] init];
        self.arrowImageView.backgroundColor = [UIColor clearColor];
        self.arrowImageView.image           = [UIImage imageNamed:@"ArrowDownWhite"];
        self.arrowImageView.contentMode     = UIViewContentModeCenter;
        
        [self addSubview:self.arrowImageView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTitleViewTap:)];
        
        [self addGestureRecognizer:tapGesture];

    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat horizontalSpacing = 5.0;
    
    CGRect textLabelFrame;
    textLabelFrame.size = [self.textLabel.text boundingRectWithSize:CGSizeMake(150.0, MAXFLOAT)
                                                            options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                         attributes:@{ NSFontAttributeName : self.textLabel.font }
                                                            context:nil].size;
    textLabelFrame.size.height = bounds.size.height;
    
    CGRect arrowImageViewFrame;
    arrowImageViewFrame.size        = CGSizeMake(self.arrowImageView.image.size.width, textLabelFrame.size.height);
    arrowImageViewFrame.size.height = bounds.size.height;

    CGFloat xOffset = floorf((bounds.size.width - textLabelFrame.size.width - arrowImageViewFrame.size.width - horizontalSpacing)/2.0);

    textLabelFrame.origin = CGPointMake(xOffset, 0.0);
    
    xOffset += (textLabelFrame.size.width + horizontalSpacing);
    
    arrowImageViewFrame.origin = CGPointMake(xOffset, 1.0);
    
    self.textLabel.frame      = textLabelFrame;
    self.arrowImageView.frame = arrowImageViewFrame;
}

- (void)sizeToFit
{
    [super sizeToFit];
    
    CGFloat horizontalSpacing = 5.0;
    
    __block CGSize textLabelSize = CGSizeZero;
    
    [self.titles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        CGSize titleSize = [obj boundingRectWithSize:CGSizeMake(150.0, MAXFLOAT)
                                             options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                          attributes:@{ NSFontAttributeName : self.textLabel.font }
                                             context:nil].size;
        
        if(titleSize.height > textLabelSize.height) {
            textLabelSize.height = titleSize.height;
        }
        
        if(titleSize.width > textLabelSize.width) {
            textLabelSize.width = titleSize.width;
        }
        
    }];

    CGSize arrowImageViewSize = CGSizeMake(self.arrowImageView.image.size.width, textLabelSize.height);

    self.bounds
    = CGRectMake(0.0,
                 0.0,
                 (textLabelSize.width + arrowImageViewSize.width + horizontalSpacing),
                 MAX(textLabelSize.height, arrowImageViewSize.height)
                 );
}

#pragma mark - Tap gesture

- (void)handleTitleViewTap:(id)sender
{
    if([self.delegate respondsToSelector:@selector(titleViewWasTapped)]) {
        [self.delegate titleViewWasTapped];
    }
}

#pragma mark - Text and arrow direction

- (void)setArrowDirection:(MOMenuTitleViewArrowDirection)arrowDirection
{
    [self setArrowDirection:arrowDirection animated:NO];
}

- (void)setArrowDirection:(MOMenuTitleViewArrowDirection)arrowDirection animated:(BOOL)animated
{
    // Set arrow direction property
    _arrowDirection = arrowDirection;
    
    // Set arrow image view direction/transform
    // based on arrow direction property
    CGAffineTransform transform;
    
    if(arrowDirection == MOMenuTitleViewArrowDirectionDown) {
        transform = CGAffineTransformMakeRotation(M_PI);
    } else if(arrowDirection == MOMenuTitleViewArrowDirectionUp) {
        transform = CGAffineTransformIdentity;
    }
    
    // Make change based upon
    // animated property
    if(animated) {
        [UIView animateWithDuration:.25 animations:^{
            self.arrowImageView.transform = transform;
        }];
    } else {
        self.arrowImageView.transform = transform;
    }
}


- (void)setSelectedIndex:(NSInteger)selectedIndex
          arrowDirection:(MOMenuTitleViewArrowDirection)arrowDirection
                animated:(BOOL)animated
{
    // Set arrow direction based on method properties
    [self setArrowDirection:arrowDirection animated:animated];
    
    // Set title
    self.textLabel.text = self.titles[selectedIndex];
    
    // Relayout
    [self layoutSubviews];
}

@end
