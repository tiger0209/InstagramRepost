//
//  MOCancelButton.h
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/31/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CancelBlock)(void);
typedef void (^ActionBlock)(void);

@interface MOCancelButton : UIView

// Views
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *textLabel;

// Action blocks
@property (nonatomic, copy) CancelBlock cancelBlock;
@property (nonatomic, copy) ActionBlock actionBlock;

@end
