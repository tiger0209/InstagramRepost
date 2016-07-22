//
//  ARSegmentPageHeader.m
//  ARSegmentPager
//
//  Created by August on 15/3/28.
//  Copyright (c) 2015 August. All rights reserved.
//

#import "ARSegmentPageHeader.h"
#import "UIAlertView+NSCookbook.h"
#import "UsersViewController.h"


#import "AppDelegate.h"

#import "InstafollowersClient.h"
#import "DataManagement.h"
#import "MOTabBarViewController.h"

@interface ARSegmentPageHeader ()

@property (nonatomic, strong) NSLayoutConstraint *imageTopConstraint;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation ARSegmentPageHeader

-(instancetype)init
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    self = [[nib instantiateWithOwner:self options:nil] firstObject];

//    self = [super init];
    if (self) {
        
        self.layer.borderWidth = 5.0f;
        self.layer.borderColor = [[UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0] CGColor];
        
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        CGRect v_windowRect = delegate.g_windowFrame;
        float v_window_w = v_windowRect.size.width;
        float v_widthRate = 320.0f / v_window_w;
        
        CGRect v_outletFrame = self.m_user_outletView.frame;
        CGRect v_imageFrame = self.m_user_imageView.frame;
        
        CGSize v_newOutletSize = v_outletFrame.size;
        CGSize v_newimageSize = v_imageFrame.size;
        
        v_newOutletSize = CGSizeMake(v_outletFrame.size.height*v_widthRate, v_outletFrame.size.height);
        v_newimageSize = CGSizeMake(v_imageFrame.size.height*v_widthRate, v_imageFrame.size.height);
        
        [self.m_user_outletView setFrame:CGRectMake(self.m_user_outletView.frame.origin.x + v_outletFrame.size.height*(1 - v_widthRate)/2,
                                                   self.m_user_outletView.frame.origin.y + v_outletFrame.size.height*(1 - v_widthRate)/2,
                                                   v_newOutletSize.width,
                                                   v_newOutletSize.height)];
        
       [self.m_user_imageView setFrame:CGRectMake(self.m_user_imageView.frame.origin.x + v_outletFrame.size.height*(1 - v_widthRate)/2,
                                                  self.m_user_imageView.frame.origin.y + v_outletFrame.size.height*(1 - v_widthRate)/2,
                                                  v_newimageSize.width,
                                                   v_newimageSize.height)];
        
        self.m_user_outletView.layer.masksToBounds = YES;
        self.m_user_outletView.layer.cornerRadius = self.m_user_outletView.frame.size.height/2.0f;
        
        self.m_user_imageView.layer.masksToBounds = YES;
        self.m_user_imageView.layer.cornerRadius = self.m_user_imageView.frame.size.height/2.0f;
        
        self.m_user_Btn.layer.masksToBounds = YES;
        self.m_user_Btn.layer.cornerRadius = self.m_user_Btn.frame.size.height/2.0f;
    }
    return self;
}


-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return nil;
    }
    return view;
}

-(IBAction)onFollowersBtn:(id)sender
{
    NSLog(@"Clicking Followers");
    UsersViewController *viewController = [[UsersViewController alloc] initWithSelection:SelectionFollowers
                                                                                    user:self.user];
    
    // Push view controller
    [self.m_navigationController pushViewController:viewController animated:YES];

}

-(IBAction)onFollowingBtn:(id)sender
{
    NSLog(@"Clicking Following");
    UsersViewController *viewController = [[UsersViewController alloc] initWithSelection:SelectionFollowing
                                                                                    user:self.user];
    
    // Push view controller
    [self.m_navigationController pushViewController:viewController animated:YES];

}

-(IBAction)onUserBtn:(id)sender
{
    NSLog(@"Clicking USER");
    
    //Show rate alert
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log Out?"
                                                        message:@"Are you sure you want to log out? Logging out to switch accounts? Upgrade to PRO for fast account switching!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Log Out", @"Unlock PRO",
                                                                nil];
    
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        switch (buttonIndex) {
            case 0:
                NSLog(@"Cancel");
                break;
            case 1:
                NSLog(@"Log Out");
                [self logOutUser];
                break;
            case 2:
                NSLog(@"Unlock Pro");
                break;
        }
    }];

}

-(void) logOutUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:UserDefaultsKeyDeviceToken]) {
        
        // Show activity indicator
        CGRect activityIndicatorFrame       = self.bounds;
        activityIndicatorFrame.size.height -= UITabBarHeight;
        
        [self addActivityIndicatorViewWithFrame:activityIndicatorFrame animated:YES];
        
        // Make deactivate request
        [[InstafollowersClient sharedClient] putDeactivateDeviceWithDeviceToken:[defaults objectForKey:UserDefaultsKeyDeviceToken]
                                                                     completion:^(BOOL success)
         {
             // Logout user
             [[DataManagement sharedClient] logoutUser];
             
             // Show login view controller since user is logged out
             [(MOTabBarViewController *)self.m_navigationController.parentViewController displayLoginViewControllerWithCompletion:^{
                 
                 // Remove activity indicator
                 [self removeActivityIndicatorViewAnimated:YES];
                 
             }];
             
         }];
        
    } else {
        
        // Logout user
        [[DataManagement sharedClient] logoutUser];
        
        // Show login view controller since user is logged out
        [(MOTabBarViewController *)self.m_navigationController.parentViewController displayLoginViewControllerWithCompletion:nil];
        
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
        self.activityIndicator.backgroundColor = self.backgroundColor;
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
        
        [self addSubview:self.activityIndicator];
        
        [UIView animateWithDuration:.35 animations:^{
            self.activityIndicator.alpha = 1.0;
        }];
    } else {
        [self addSubview:self.activityIndicator];
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
