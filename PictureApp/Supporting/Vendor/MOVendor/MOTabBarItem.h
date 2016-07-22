//
//  MOTabBarItem.h
//  InstagramLikes
//
//  Created by Michael Orcutt on 1/23/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TapBlock)(void);

////lgilgi
@interface MOTabBarItem : UIImageView

///------------------------------------------------
/// @name Highlighted
///------------------------------------------------

/**
 Indicator image used to indicate this button is highlighted.
 
 @note by default this view is hidden.
 */
@property (strong, nonatomic) UIImageView *highlightedIndicatorImageView;

///------------------------------------------------
/// @name Blocks
///------------------------------------------------

/**
 'tapBlock' is a block used to handle tap gestures in this view.
 */
@property (copy, nonatomic) TapBlock tapBlock;


/////lgilgilgi
@property (strong, nonatomic) UILabel *textLabel;

@end
