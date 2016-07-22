//
//  MOMenuViewController.h
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/24/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MOMenuViewControllerMenuPositionUp,
    MOMenuViewControllerMenuPositionDown
} MOMenuViewControllerMenuPosition;

@interface MOMenuViewController : UIViewController

// View controller properties
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, weak) UIViewController *selectedViewController;
@property (nonatomic, assign) NSUInteger selectedIndex;

// Menu properties and methods
- (void)setMenuPosition:(MOMenuViewControllerMenuPosition)menuPosition animated:(BOOL)animated;

// Method to reset title view for current
// child view controller titles
- (void)loadTitles;

@end
