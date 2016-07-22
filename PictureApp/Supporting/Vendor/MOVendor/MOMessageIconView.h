//
//  MOMessageIconView.h
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/30/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MOMessageIconViewLayoutDefault,
    MOMessageIconViewLayoutSubtitle
} MOMessageIconViewLayout;

typedef void (^TapBlock)(void);

@interface MOMessageIconView : UIView

- (id)initWithFrame:(CGRect)frame layout:(MOMessageIconViewLayout)layout;

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UILabel *detailTextLabel;

// Tap enabled
@property (nonatomic) BOOL tapEnabled;

// Action blocks
@property (nonatomic, copy) TapBlock tapBlock;

// Layout
@property (nonatomic) MOMessageIconViewLayout layout;

@end
