//
//  MORoundedImageContainerView.h
//  InstagramLikes
//
//  Created by Michael Orcutt on 1/28/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ActionBlock)(id sender);

@interface MORoundedImageContainerView : UIView

@property (strong, nonatomic) UIImageView *imageView;

@property (nonatomic) BOOL selected;

@property (strong, nonatomic) UIColor *borderColor;
@property (strong, nonatomic) UIColor *selectedBorderColor;

@property (nonatomic, copy) ActionBlock actionBlock;
@property (nonatomic) BOOL tappable;

@property double cornerRadiusRatio;

@end
