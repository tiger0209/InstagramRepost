//
//  ARSegmentPageController.m
//  ARSegmentPager
//
//  Created by August on 15/3/28.
//  Copyright (c) 2015 August. All rights reserved.
//

#import "ARSegmentPageController.h"
#import "ARSegmentView.h"

// Networking
#import "InstagramClient.h"
#import "DataManagement.h"
#import "UIImageView+WebCache.h"

#import "InstafollowersClient.h"

#import "MOTabBarViewController.h"


const void* _ARSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWOFFSET = &_ARSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWOFFSET;

@interface ARSegmentPageController ()

@property (nonatomic, strong) UIView<ARSegmentPageControllerHeaderProtocol> *headerView;
@property (nonatomic, strong) ARSegmentView *segmentView;
@property (nonatomic, strong) NSMutableArray *controllers;
@property (nonatomic, assign) CGFloat segmentToInset;
@property (nonatomic, weak) UIViewController<ARSegmentControllerDelegate> *currentDisplayController;

@property (nonatomic, strong) NSLayoutConstraint *headerHeightConstraint;

@property (nonatomic, assign) BOOL mb_temp_refresh;
@property (nonatomic, assign) BOOL mb_refresh;

/////lgilgilgi
// Activity indicator to display when initially loading content
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;


// User
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) InstagramUser *user;

// Media items arrays for the users items
// that are returned from Instagram API
@property (strong, nonatomic) NSMutableArray *mediaItems;

// Next max identifier is used to paginate
// through the users media items
@property (strong, nonatomic) NSString *nextMaxIdentifier;

// BOOL values used to decide when to
// make requests and when to not
@property (nonatomic) BOOL requestsDone;
@property (nonatomic) BOOL requestsLoading;

// Relationship for follow button and relationship label
@property (nonatomic) Relationship outgoingRelationship;
@property (nonatomic) Relationship incomingRelationship;

// BOOL private value
@property (nonatomic) BOOL private;

// Chatting Button
@property (strong, nonatomic) UIButton *chatButton;


@end

@implementation ARSegmentPageController

#pragma mark - life cycle methods

-(instancetype)initWithControllers:(UIViewController<ARSegmentControllerDelegate> *)controller, ...
{
    self = [super init];
    if (self) {
        NSAssert(controller != nil, @"the first controller must not be nil!");
        [self _setUp];
        UIViewController<ARSegmentControllerDelegate> *eachController;
        va_list argumentList;
        if (controller)
        {
            [self.controllers addObject: controller];
            va_start(argumentList, controller);
            while ((eachController = va_arg(argumentList, id)))
            {
                [self.controllers addObject:eachController];
            }
            va_end(argumentList);
        }
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setUp];
    }
    return self;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setUp];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    ////lgilgilgi
    self.mb_refresh = YES;
    self.mb_temp_refresh = YES;
//    [self.navigationController setNavigationBarHidden:YES];
    
    // Title
    self.title = self.user.username;;
    
    [self.navigationController.navigationBar setTintColor:[UIColor grayColor]];
    
    
    UIButton *unlockProBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [unlockProBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [unlockProBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [unlockProBtn setTitle:@"Unlock Pro" forState:UIControlStateNormal];
    
    [unlockProBtn setBackgroundColor:[UIColor colorWithRed:51.0/255.0 green:177.0/255.0 blue:233.0/255.0 alpha:1.0]];
    [unlockProBtn addTarget:self action:@selector(leftBarButtonItemTapped:) forControlEvents:UIControlEventTouchUpInside];
    unlockProBtn.frame = CGRectMake(0, 0, 100, 30);
    unlockProBtn.layer.cornerRadius = 15.0f;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:unlockProBtn] ;
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    
    // Add right bar button item, to open in instagram app
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TabBarUser"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(rightBarButtonItemTapped:)];
    
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem animated:YES];
    
    
    
    [self _baseConfigs];
    [self _baseLayout];
    
    [self loadUser];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.topItem.title = self.user.username;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)loadUser
{
    InstagramUser *user = [[DataManagement sharedClient] user];
    self.user = user;
    // Reload user, the user model could be missing information
    [[InstagramClient sharedClient] getUserForIdentifier:self.user.identifier completion:^(BOOL success, InstagramUser *user) {
        
        if(success) {
            // Reset the user
            self.user = user;
            // Set text label as username
            ARSegmentPageHeader* v_headerView = (ARSegmentPageHeader*)self.headerView;
            
            // = self.user.username;
            
            // Profile picture
            [v_headerView.m_user_imageView sd_setImageWithURL:self.user.profilePictureURL];
            [v_headerView.m_count_follower_Label setText:self.user.followersCount];
            [v_headerView.m_count_followeing_Label setText:self.user.followsCount];
            
            self.tabBarItem.title = self.user.username;
            self.title = self.user.username;
            // Reset the user view
            //self.headerView.userView.user = self.user;
            v_headerView.user = self.user;
            
        }
        
    }];
    
    // Relationship statuses for the header follow button and relationship label
    if([[[DataManagement sharedClient] user].identifier isEqualToString:self.user.identifier]) {
        
        // This user is the logged in user
        self.incomingRelationship = RelationshipSelf;
        self.outgoingRelationship = RelationshipSelf;
        
    } else {
        
        [[InstagramClient sharedClient] getRelationshipForUserIdentifier:self.user.identifier
                                                              completion:^(BOOL success,
                                                                           Relationship outgoingRelationship,
                                                                           Relationship incomingRelationship,
                                                                           BOOL private)
         {
             
             if(success) {
                 // Set relationships
                 self.incomingRelationship = incomingRelationship;
                 self.outgoingRelationship = outgoingRelationship;
                 
                 // If private and not following, add to view
                 if(private && outgoingRelationship == RelationshipNotFollowingPrivate) {
                     
                     // Set private
                     self.private = YES;
                     
//                     [self.collectionView reloadData];
                     
                 }
                 
             } else {
                 // Set relationship status to unknown
                 self.outgoingRelationship = RelationshipUnknown;
                 self.incomingRelationship = RelationshipUnknown;
             }
             
             // Set on header view
//             self.headerView.outgoingRelationship = outgoingRelationship;
//             self.headerView.incomingRelationship = incomingRelationship;
             
             
         }];
        
    }
}
- (void)leftBarButtonItemTapped:(id)sender
{
    //    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@", self.user.username]];
    //
    //    if([[UIApplication sharedApplication] canOpenURL:URL]) {
    //        [[UIApplication sharedApplication] openURL:URL];
    //    } else {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instagram"
    //                                                        message:@"Could not open profile in Instagram. Make sure you have the Instagram app installed."
    //                                                       delegate:nil
    //                                              cancelButtonTitle:@"OK"
    //                                              otherButtonTitles:nil];
    //        [alert show];
    //    }
}

- (void)rightBarButtonItemTapped:(id)sender
{
//    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@", self.user.username]];
//    
//    if([[UIApplication sharedApplication] canOpenURL:URL]) {
//        [[UIApplication sharedApplication] openURL:URL];
//    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instagram"
//                                                        message:@"Could not open profile in Instagram. Make sure you have the Instagram app installed."
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Log Out", @"Send Feedback", @"Restore Purchases", nil];
    [actionSheet showInView:self.view];

}


#pragma mark - public methods

-(void)setViewControllers:(NSArray *)viewControllers
{
    [self.controllers removeAllObjects];
    [self.controllers addObjectsFromArray:viewControllers];
}

#pragma mark - override methods

-(UIView<ARSegmentPageControllerHeaderProtocol> *)customHeaderView
{
    ARSegmentPageHeader *headerView = [[ARSegmentPageHeader alloc] init];
    headerView.m_navigationController = self.navigationController;
    return headerView;
}

#pragma mark - private methdos

-(void)_setUp
{
    self.headerHeight = 200;
    self.segmentHeight = 44;
    self.segmentToInset = 200;
    self.segmentMiniTopInset = 0;
    self.controllers = [NSMutableArray array];
}

-(void)_baseConfigs
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([self.view respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.view.preservesSuperviewLayoutMargins = YES;   
    }
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.headerView = [self customHeaderView];
    self.headerView.clipsToBounds = YES;
    
    self.headerView.layer.borderWidth = 1;
    self.headerView.layer.borderColor = [[UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0] CGColor];

    
    [self.view addSubview:self.headerView];
    
    
    self.segmentView = [[ARSegmentView alloc] init];
    [self.segmentView.segmentControl addTarget:self action:@selector(segmentControlDidChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentView];
    
    //all segment title and controllers
    [self.controllers enumerateObjectsUsingBlock:^(UIViewController<ARSegmentControllerDelegate> *controller, NSUInteger idx, BOOL *stop) {
        //////lgilgilgi
        NSString *title = [controller segmentTitle];
        
        [self.segmentView.segmentControl insertSegmentWithTitle:title
                                                        atIndex:idx
                                                       animated:NO];
    }];
    
    //defaut at index 0
    self.segmentView.segmentControl.selectedSegmentIndex = 0;
    UIViewController<ARSegmentControllerDelegate> *controller = self.controllers[0];
    [controller willMoveToParentViewController:self];

    //lgilgilgi
    [self.view insertSubview:controller.view atIndex:0];
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    
    [self _layoutControllerWithController:controller];
    [self addObserverForPageController:controller];
    
    self.currentDisplayController = self.controllers[0];
    
}

-(void)_baseLayout
{
    //header
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.headerHeightConstraint = [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:self.headerHeight];
    [self.headerView addConstraint:self.headerHeightConstraint];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    //segment
    self.segmentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];

    ///lgilgilgi
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];

//    self.segmentHeightConstraint = [NSLayoutConstraint constraintWithItem:self.segmentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:self.segmentToInset];
//    
//    [self.view addConstraint:self.segmentHeightConstraint];
    
    
    

    [self.segmentView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:self.segmentHeight]];
}

-(void)_layoutControllerWithController:(UIViewController<ARSegmentControllerDelegate> *)pageController
{
    
    UIView *pageView = pageController.view;
    if ([pageView respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        pageView.preservesSuperviewLayoutMargins = YES;
    }
    pageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    UIScrollView *scrollView = [self scrollViewInPageController:pageController];
    if (scrollView) {
        scrollView.alwaysBounceVertical = YES;
        CGFloat topInset = self.headerHeight+self.segmentHeight;
        //fixed bootom tabbar inset
        CGFloat bottomInset = 0;
        if (self.tabBarController.tabBar.hidden == NO) {
            ///lgilgilgi
            //bottomInset = CGRectGetHeight(self.tabBarController.tabBar.bounds);
            bottomInset = 60;
        }
        
        [scrollView setContentInset:UIEdgeInsetsMake(topInset, 0, bottomInset, 0)];
        //fixed first time don't show header view
        
        ///lgilgilgi
        [scrollView setContentOffset:CGPointMake(0, -self.headerHeight-self.segmentHeight)];
        //[scrollView setContentOffset:CGPointMake(0, 0)];
        
        ///lgilgilgi
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
//        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:self.headerHeight+self.segmentHeight constant:0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    }else{
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.segmentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:-self.segmentHeight]];
    }
    
}

-(UIScrollView *)scrollViewInPageController:(UIViewController <ARSegmentControllerDelegate> *)controller
{
    if ([controller respondsToSelector:@selector(streachScrollView)]) {
        return [controller streachScrollView];
    }else if ([controller.view isKindOfClass:[UIScrollView class]]){
        return (UIScrollView *)controller.view;
    }else{
        return nil;
    }
}

#pragma mark - add / remove obsever for page scrollView

-(void)addObserverForPageController:(UIViewController <ARSegmentControllerDelegate> *)controller
{
    UIScrollView *scrollView = [self scrollViewInPageController:controller];
    if (scrollView != nil) {
        [scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew context:&_ARSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWOFFSET];
    }
}

-(void)removeObseverForPageController:(UIViewController <ARSegmentControllerDelegate> *)controller
{
    UIScrollView *scrollView = [self scrollViewInPageController:controller];
    if (scrollView != nil) {
        @try {
        [scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
        }
        @catch (NSException *exception) {
            NSLog(@"exception is %@",exception);
        }
        @finally {
                
        }
    }
}

#pragma mark - obsever delegate methods

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == _ARSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWOFFSET) {
        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
        CGFloat offsetY = offset.y + self.segmentHeight;
        
        NSLog(@"----%f-----", offsetY);
        
        ///lgilgilgi
        if (offsetY < -self.headerHeight && !self.mb_refresh) {
            [self.currentDisplayController requestingLoadMedia];
            self.mb_refresh = YES;
            
        }
        if (offsetY == -self.headerHeight ) {
            self.mb_temp_refresh = NO;
        }
        if (offsetY < -self.headerHeight && !self.mb_temp_refresh) {
            self.mb_refresh = NO;
            self.mb_temp_refresh = YES;
        }

        /////////////////
        
        if (offsetY < -self.segmentMiniTopInset) {
            self.headerHeightConstraint.constant = -offsetY;
            if (self.freezenHeaderWhenReachMaxHeaderHeight &&
                offsetY < -self.headerHeight) {
                self.headerHeightConstraint.constant = self.headerHeight;
            }
            self.segmentToInset = -offsetY;
            
            ////lgilgilgi
            //self.segmentHeightConstraint.constant = -offsetY;
            
        }else{
            self.headerHeightConstraint.constant = self.segmentMiniTopInset;
            
            ////lgilgilgi
            //self.segmentHeightConstraint.constant = self.segmentMiniTopInset;

            self.segmentToInset = self.segmentMiniTopInset;
        }
    }
}

#pragma mark - event methods

-(void)segmentControlDidChangedValue:(UISegmentedControl *)sender
{
    //remove obsever
    [self removeObseverForPageController:self.currentDisplayController];
    
    //add new controller
    NSUInteger index = [sender selectedSegmentIndex];
    UIViewController<ARSegmentControllerDelegate> *controller = self.controllers[index];
    
    [self.currentDisplayController willMoveToParentViewController:nil];
    [self.currentDisplayController.view removeFromSuperview];
    [self.currentDisplayController removeFromParentViewController];
    [self.currentDisplayController didMoveToParentViewController:nil];
    
    [controller willMoveToParentViewController:self];
    [self.view insertSubview:controller.view atIndex:0];
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    
    // reset current controller
    self.currentDisplayController = controller;
    //layout new controller
    [self _layoutControllerWithController:controller];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    //add obsever
    [self addObserverForPageController:self.currentDisplayController];
    
    //trigger to fixed header constraint
    UIScrollView *scrollView = [self scrollViewInPageController:controller];
    if (self.headerHeightConstraint.constant < 1 &&
        scrollView.contentOffset.y >= 1) {//zero
        [scrollView setContentOffset:scrollView.contentOffset];
    }else{
        [scrollView setContentOffset:CGPointMake(0, -self.headerHeightConstraint.constant-self.segmentHeight)];
    }

    /////lgilgilgi
    ////lgilgilgi
    [self.controllers enumerateObjectsUsingBlock:^(UIViewController<ARSegmentControllerDelegate> *controller, NSUInteger idx, BOOL *stop) {
        //////lgilgilgi
        if (idx == index)
            [controller requestingRefresh];
    }];

}

#pragma mark - IBActionSheet/UIActionSheet Delegate Method

// the delegate method to receive notifications is exactly the same as the one for UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Button at index: %ld clicked\nIts title is '%@'", (long)buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
    if (buttonIndex == 0) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if([defaults objectForKey:UserDefaultsKeyDeviceToken]) {
            
            // Show activity indicator
            CGRect activityIndicatorFrame       = self.view.bounds;
            activityIndicatorFrame.size.height -= UITabBarHeight;
            
            [self addActivityIndicatorViewWithFrame:activityIndicatorFrame animated:YES];
            
            // Make deactivate request
            [[InstafollowersClient sharedClient] putDeactivateDeviceWithDeviceToken:[defaults objectForKey:UserDefaultsKeyDeviceToken]
                                                                         completion:^(BOOL success)
             {
                 // Logout user
                 [[DataManagement sharedClient] logoutUser];
                 
                 // Show login view controller since user is logged out
                 [(MOTabBarViewController *)self.parentViewController.parentViewController displayLoginViewControllerWithCompletion:^{
                     
                     // Remove activity indicator
                     [self removeActivityIndicatorViewAnimated:YES];
                     
                 }];
                 
             }];
            
        } else {
            
            // Logout user
            [[DataManagement sharedClient] logoutUser];
            
            // Show login view controller since user is logged out
            [(MOTabBarViewController *)self.parentViewController.parentViewController displayLoginViewControllerWithCompletion:nil];
            
        }

    }
}

// optional delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Will dismiss with button index %ld", (long)buttonIndex);
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Dismissed with button index %ld", (long)buttonIndex);
}

#pragma mark - manage memory methods

-(void)dealloc
{
    [self removeObseverForPageController:self.currentDisplayController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

@end
