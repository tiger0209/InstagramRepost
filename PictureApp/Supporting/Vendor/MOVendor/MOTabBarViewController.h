//
//  MOTabBarViewController.h
//  InstagramLikes
//
//  Created by Michael Orcutt on 1/23/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOTabBarViewController : UIViewController

///------------------------------------------------
/// @name Child view controllers
///------------------------------------------------

/**
 'viewControllers' are the tab bar child view controllers
 */
@property (nonatomic, copy) NSArray *viewControllers;

/**
 'selectedViewController' is the currently selected tab child view controller
 */
@property (nonatomic, readonly) UIViewController *selectedViewController;

/**
 'selectedIndex' is the currently selected tab index
 */
@property (nonatomic, assign) NSUInteger selectedIndex;

@property (strong, nonatomic) UITabBar *tabBar;
@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) NSMutableArray *highlightedIndexes;

///------------------------------------------------
/// @name Highlight
///------------------------------------------------

/**
 - isIndexHighlighted: returns YES or NO for the supplied index
 */
- (BOOL)isIndexHighlighted:(NSInteger)index;

/**
 - setIndexHighlighted highlights the provided index and animates this change if set
 */
- (void)setIndexHighlighted:(BOOL)highlighted index:(NSInteger)index;

///------------------------------------------------
/// @name Select view controllers
///------------------------------------------------

/**
 - setSelectedIndex selects a tab based upon index
 */
- (void)setSelectedIndex:(NSUInteger)index;

///------------------------------------------------
/// @name Login
///------------------------------------------------

/**
 - displayLoginViewControllerWithCompletion: shows LoginViewController
 */

- (void)displayLoginViewControllerWithCompletion:(void(^)(void))completionBlock;

@end
