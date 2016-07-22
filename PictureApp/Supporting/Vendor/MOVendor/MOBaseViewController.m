//
//  MOBaseViewController.m
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/31/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "MOBaseViewController.h"

// Views
#import "MOMessageIconView.h"
#import "MOBlurButton.h"

// Categories
#import "UIColor+String.h"
#import "Constants.h"


@interface MOBaseViewController ()

// Message icon view to display messages
@property (strong, nonatomic) MOMessageIconView *messageIconView;

// Activity indicator to display when initially loading content
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

// viewControllerType
@property (nonatomic) MOBaseViewControllerType viewControllerType;

// Insets type

// Action button
@property (strong, nonatomic) MOBlurButton *actionButton;

@end

@implementation MOBaseViewController

#pragma mark - Init

- (id)initWithViewControllerType:(MOBaseViewControllerType)viewControllerType
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        // Set view controller type
        self.viewControllerType = viewControllerType;

        // Initialize views based on view controller type
        if(viewControllerType == MOBaseViewControllerTypeCollectionView) {
            
            UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
            
            self.collectionView                        = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
            self.collectionView.backgroundColor        = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0];
            self.collectionView.alwaysBounceVertical   = YES;
            
        } else if(viewControllerType == MOBaseViewControllerTypeTableViewPlain || viewControllerType == MOBaseViewControllerTypeTableViewGrouped) {
            
            UITableViewStyle tableViewStyle;
            if(viewControllerType == MOBaseViewControllerTypeTableViewPlain) {
                tableViewStyle = UITableViewStylePlain;
            } else {
                tableViewStyle = UITableViewStyleGrouped;
            }
            
            self.tableView                 = [[UITableView alloc] initWithFrame:CGRectZero style:tableViewStyle];
            self.tableView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0];
            self.tableView.separatorColor  = [UIColor colorWithRed:224.0/255.0 green:226.0/255.0 blue:229.0/255.0 alpha:1.0];

        }
    
    }
    return self;
}

- (id)initWithViewControllerType:(MOBaseViewControllerType)viewControllerType
                    contentInset:(UIEdgeInsets)contentInset
           scrollIndicatorInsets:(UIEdgeInsets)scrollIndicatorInsets
{
    self = [self initWithViewControllerType:viewControllerType];
    if (self) {
        
        if(viewControllerType == MOBaseViewControllerTypeCollectionView) {
            self.collectionView.contentInset          = contentInset;
            self.collectionView.scrollIndicatorInsets = scrollIndicatorInsets;
        } else {
            self.tableView.contentInset          = contentInset;
            self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
        }
        
    }
    return self;
}

- (id)initWithViewControllerType:(MOBaseViewControllerType)viewControllerType
  presentedAsModalViewController:(BOOL)presentedAsModalViewController
{
    self = [self initWithViewControllerType:viewControllerType];
    if (self) {
        
        // Set presented as modal view controller
        _presentedAsModalViewController = presentedAsModalViewController;
        
        // Edge insets based upon presentedAsModalViewController BOOL value
        UIEdgeInsets contentInset;
        UIEdgeInsets scrollIndicatorInsets;
        
        if(_presentedAsModalViewController) {
            contentInset          = UIEdgeInsetsZero;
            scrollIndicatorInsets = UIEdgeInsetsZero;
        } else {
            contentInset          = UIEdgeInsetsMake(0.0, 0.0, UITabBarHeight, 0.0);
            scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, UITabBarHeight, 0.0);
        }
        
        // Set content insets
        if(viewControllerType == MOBaseViewControllerTypeCollectionView) {
            self.collectionView.contentInset          = contentInset;
            self.collectionView.scrollIndicatorInsets = scrollIndicatorInsets;
        } else {
            self.tableView.contentInset          = contentInset;
            self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
        }
        
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    // Add table view or collection view subview
    if(self.viewControllerType == MOBaseViewControllerTypeCollectionView) {
        
        // Add collection view
        [self.view addSubview:self.collectionView];
        
    } else {
        
        // Add table view
        [self.view addSubview:self.tableView];

    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    // Setup
    NSDictionary *navigationBarTitleTextAttributes = @{ NSFontAttributeName            : [UIFont fontWithName:@"Ubuntu-Light" size:20.0],
                                                        NSForegroundColorAttributeName : [UIColor colorWithWhite:0.0 alpha:.95] };
    
    NSDictionary *barButtonItemTitleTextAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"Ubuntu" size:17.0] };
    
    // Background color
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0];
    
    // Navigation bar
//    self.navigationController.navigationBar.barTintColor                     = themeColor;
    self.navigationController.navigationBar.translucent                      = NO;
    self.navigationController.navigationBar.tintColor                        = [UIColor colorWithWhite:0.0 alpha:.90];
    self.navigationController.navigationBar.backIndicatorImage               = [UIImage imageNamed:@"BackArrow"];
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"BackArrow"];
    self.navigationController.navigationBar.titleTextAttributes              = navigationBarTitleTextAttributes;

    // Bar button items
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:barButtonItemTitleTextAttributes
                                                                                            forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    // Table view or collection view layout
    if(self.viewControllerType == MOBaseViewControllerTypeCollectionView) {
        self.collectionView.frame = bounds;
    } else {
        self.tableView.frame = bounds;
    }
}

#pragma mark - Message Icon View methods

- (void)addMessageIconViewToView:(UIView *)view
                           frame:(CGRect)frame
                            icon:(UIImage *)icon
                            text:(NSString *)text
                      detailText:(NSString *)detailText
                        animated:(BOOL)animated
{
    MOMessageIconViewLayout layout;
    if(detailText) {
        layout = MOMessageIconViewLayoutSubtitle;
    } else {
        layout = MOMessageIconViewLayoutDefault;
    }
    
    if(!self.messageIconView) {
        self.messageIconView       = [[MOMessageIconView alloc] initWithFrame:frame layout:layout];
        self.messageIconView.alpha = 0.0;
        
        [view addSubview:self.messageIconView];
    } else {
        self.messageIconView.layout = layout;
    }
    
    self.messageIconView.backgroundColor      = self.view.backgroundColor;
    self.messageIconView.textLabel.text       = text;
    self.messageIconView.detailTextLabel.text = detailText;
    self.messageIconView.imageView.image      = icon;
    
    if(animated) {
        [UIView animateWithDuration:.35 animations:^{
            self.messageIconView.alpha = 1.0;
        }];
    } else {
        self.messageIconView.alpha = 1.0;
    }
}

- (void)addMessageIconViewToView:(UIView *)view
                           frame:(CGRect)frame
                            icon:(UIImage *)icon
                            text:(NSString *)text
                      detailText:(NSString *)detailText
                        animated:(BOOL)animated
                          action:(void (^)(void))actionBlock
{
    // Add message icon view
    [self addMessageIconViewToView:view
                             frame:frame
                              icon:icon
                              text:text
                        detailText:detailText
                          animated:animated];
    
    // Add tap gesture
    self.messageIconView.tapEnabled = YES;
    
    // Use tap block to return action block
    self.messageIconView.tapBlock = ^{
        if(actionBlock) {
            actionBlock();
        }
    };
}

- (void)addMessageIconViewToView:(UIView *)view
                    belowSubview:(UIView *)subview
                           frame:(CGRect)frame
                            icon:(UIImage *)icon
                            text:(NSString *)text
                      detailText:(NSString *)detailText
                        animated:(BOOL)animated
{
    MOMessageIconViewLayout layout;
    if(detailText) {
        layout = MOMessageIconViewLayoutSubtitle;
    } else {
        layout = MOMessageIconViewLayoutDefault;
    }
    
    if(!self.messageIconView) {
        self.messageIconView       = [[MOMessageIconView alloc] initWithFrame:frame layout:layout];
        self.messageIconView.alpha = 0.0;
        
        [view insertSubview:self.messageIconView belowSubview:subview];
    } else {
        self.messageIconView.layout = layout;
    }
    
    self.messageIconView.backgroundColor      = self.view.backgroundColor;
    self.messageIconView.textLabel.text       = text;
    self.messageIconView.detailTextLabel.text = detailText;
    self.messageIconView.imageView.image      = icon;
    
    if(animated) {
        [UIView animateWithDuration:.35 animations:^{
            self.messageIconView.alpha = 1.0;
        }];
    } else {
        self.messageIconView.alpha = 1.0;
    }
}

- (void)removeMessageIconViewAnimated:(BOOL)animated
{
    if(!self.messageIconView) return;
    
    if(animated) {
        [UIView animateWithDuration:.35 animations:^{
            self.messageIconView.alpha = 0.0;
        }];
    } else {
        self.messageIconView.alpha = 0.0;
    }
}

#pragma mark - Activity Indicator View methods

- (void)addActivityIndicatorViewWithFrame:(CGRect)frame
                                 animated:(BOOL)animated
{
    // Create activity indicator
    if(!self.activityIndicator) {
        self.activityIndicator                 = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.color           = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.00];
        self.activityIndicator.backgroundColor = self.view.backgroundColor;
        self.activityIndicator.frame           = frame;
    }
    
    // If activity indicator is not
    // animating, start animating
    if(!self.activityIndicator.isAnimating) {
        [self.activityIndicator startAnimating];
    }
    
    // Fade in
    if(animated) {
        self.activityIndicator.alpha = 0.0;
        
        [self.view addSubview:self.activityIndicator];
        
        [UIView animateWithDuration:.35 animations:^{
            self.activityIndicator.alpha = 1.0;
        }];
    } else {
        [self.view addSubview:self.activityIndicator];
    }
}

- (void)removeActivityIndicatorViewAnimated:(BOOL)animated
{
    if(animated) {
        [UIView animateWithDuration:.35 animations:^{
            self.activityIndicator.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.activityIndicator removeFromSuperview];
            self.activityIndicator = nil;
        }];
    } else {
        [self.activityIndicator removeFromSuperview];
        //self.activityIndicator = nil;
    }
}

#pragma mark - Action button methods

- (void)addActionButtonWithTitle:(NSString *)title
                    belowSubview:(UIView *)belowSubview
                         yOffset:(CGFloat)yOffset
                         animted:(BOOL)animated
                          action:(void (^)(void))actionBlock
{
    if(self.actionButton && [[self.actionButton titleForState:UIControlStateNormal] isEqualToString:title]) {
        return;
    }
    
    // Action button
    if(!self.actionButton) {
        self.actionButton                     = [[MOBlurButton alloc] init];
        self.actionButton.layer.borderWidth   = 1.0;
        self.actionButton.layer.masksToBounds = YES;
        self.actionButton.titleLabel.font     = [UIFont fontWithName:@"Ubuntu-Light" size:15.0];
        
//        UIColor *themeColor = [UIColor colorFromColorString:[[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyThemeColor]];
//        
//        self.actionButton.layer.borderColor = themeColor.CGColor;
        
        [self.actionButton setContentEdgeInsets:UIEdgeInsetsMake(11.0, 14.0, 11.0, 14.0)];
        [self.actionButton setTitleColor:[UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0]
                                forState:UIControlStateNormal]; 
    }
    
    // Set title
    [self.actionButton setTitle:title forState:UIControlStateNormal];
    
    // Action button frame
    [self.actionButton sizeToFit];
    
    CGRect actionButtonFrame   = self.actionButton.frame;
    actionButtonFrame.origin.x = floorf((self.view.bounds.size.width - actionButtonFrame.size.width)/2.0);
    
    if(animated) {
        actionButtonFrame.origin.y = -actionButtonFrame.size.height;
    } else {
        actionButtonFrame.origin.y = (yOffset + VerticalSpacing / 2.0);
    }
    
    self.actionButton.frame = actionButtonFrame;
    
    // Corner radius from frame
    self.actionButton.layer.cornerRadius = ((actionButtonFrame.size.height / 2.0) - .01);
    
    // Add subview
    [self.view insertSubview:self.actionButton belowSubview:belowSubview];
    
    // If animated, animate to position
    if(animated) {
        
        actionButtonFrame.origin.y = (yOffset + VerticalSpacing / 2.0);
     
        [UIView animateWithDuration:.75
                              delay:0.0
             usingSpringWithDamping:.50
              initialSpringVelocity:.50
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.actionButton.frame = actionButtonFrame;
                            } completion:nil];

    }
    
    // Use tap block to return action block
    self.actionButton.actionBlock = ^{
        if(actionBlock) {
            actionBlock();
        }
    };
}

- (void)removeActionButtonAnimated:(BOOL)animated completion:(void (^)(void))completionBlock
{
    if(!self.actionButton) {
        return;
    }
    
    if(animated) {
        self.actionButton.userInteractionEnabled = NO;
        
        CGRect actionButtonFrame   = self.actionButton.frame;
        actionButtonFrame.origin.y = -actionButtonFrame.size.height;
        
        [UIView animateWithDuration:.30 animations:^{
            self.actionButton.frame = actionButtonFrame;
            self.actionButton.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.actionButton removeFromSuperview];
            _actionButton = nil;
            
            if(completionBlock) {
                completionBlock();
            }
        }];
    } else {
        [self.actionButton removeFromSuperview];
        _actionButton = nil;
        
        if(completionBlock) {
            completionBlock();
        }
    }
}

#pragma mark - Table view methods

- (void)fadeInTableViewAnimated:(BOOL)animated
{
    if(self.tableView && self.tableView.alpha == 0.0) {
        
        if(animated) {
            [UIView animateWithDuration:.35 animations:^{
                self.tableView.alpha = 1.0;
            }];
        } else {
            self.tableView.alpha = 1.0;
        }
        
    }
}

- (void)fadeOutTableViewAnimated:(BOOL)animated
{
    if(self.tableView && self.tableView.alpha == 1.0) {
        
        if(animated) {
            [UIView animateWithDuration:.35 animations:^{
                self.tableView.alpha = 0.0;
            }];
        } else {
            self.tableView.alpha = 0.0;
        }
        
    }
}

#pragma mark - Bar button methods

- (void)setLeftBarButtonItemAsDone
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(leftBarButtonItemWasTapped:)];
}

- (void)leftBarButtonItemWasTapped:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
