//
//  MOBaseViewController.h
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/31/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MOBaseViewControllerTypeCollectionView,
    MOBaseViewControllerTypeTableViewPlain,
    MOBaseViewControllerTypeTableViewGrouped
} MOBaseViewControllerType;

@interface MOBaseViewController : UIViewController

// Init method to initialize the view controller
// with a table view or collection view
- (id)initWithViewControllerType:(MOBaseViewControllerType)viewControllerType;
- (id)initWithViewControllerType:(MOBaseViewControllerType)viewControllerType
                    contentInset:(UIEdgeInsets)contentInset
           scrollIndicatorInsets:(UIEdgeInsets)scrollIndicatorInsets;
- (id)initWithViewControllerType:(MOBaseViewControllerType)viewControllerType
  presentedAsModalViewController:(BOOL)presentedAsModalViewController;

// Table view property, not intiliazed in this
// base view controller but used for fade in and
// fade out methods, if initialized
@property (strong, nonatomic) UITableView *tableView;

// Collection view property, not intiliazed in this
// base view controller but used for fade in and
// fade out methods, if initialized
@property (strong, nonatomic) UICollectionView *collectionView;

// Table view fade in and fade out methods
- (void)fadeInTableViewAnimated:(BOOL)animated;
- (void)fadeOutTableViewAnimated:(BOOL)animated;

// Message icon view add/remove methods
- (void)addMessageIconViewToView:(UIView *)view
                           frame:(CGRect)frame
                            icon:(UIImage *)icon
                            text:(NSString *)text
                      detailText:(NSString *)detailText
                        animated:(BOOL)animated;
- (void)addMessageIconViewToView:(UIView *)view
                           frame:(CGRect)frame
                            icon:(UIImage *)icon
                            text:(NSString *)text
                      detailText:(NSString *)detailText
                        animated:(BOOL)animated
                          action:(void (^)(void))actionBlock;
- (void)addMessageIconViewToView:(UIView *)view
                    belowSubview:(UIView *)belowSubview
                           frame:(CGRect)frame
                            icon:(UIImage *)icon
                            text:(NSString *)text
                      detailText:(NSString *)detailText
                        animated:(BOOL)animated;
- (void)removeMessageIconViewAnimated:(BOOL)animated;

// Action button
- (void)addActionButtonWithTitle:(NSString *)title
                    belowSubview:(UIView *)subview
                         yOffset:(CGFloat)yOffset
                         animted:(BOOL)animated
                          action:(void (^)(void))actionBlock;
- (void)removeActionButtonAnimated:(BOOL)animated
                        completion:(void (^)(void))completionBlock;

// Activity indicator add/remove methods
- (void)addActivityIndicatorViewWithFrame:(CGRect)frame
                                 animated:(BOOL)animated;
- (void)removeActivityIndicatorViewAnimated:(BOOL)animated;

// Left bar button item as done
- (void)setLeftBarButtonItemAsDone;

// Modal view controller
@property (nonatomic) BOOL presentedAsModalViewController;

@end
