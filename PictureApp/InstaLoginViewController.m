//
//  LoginViewController.m
//  InstagramFollowers
//
//  Created by Michael Orcutt on 10/19/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "InstaLoginViewController.h"

// Networking
#import "InstafollowersClient.h"
#import "InstagramClient.h"

// Data management
#import "DataManagement.h"

// App Delegate
#import "AppDelegate.h"

// String constants for authentication

///lgilgilgi
NSString* const InstagramClientIdentifier           = @"1223f799bc2542b8a559d5d7dba2beb8";//@"51fd356043ee4987ad84fd2c11f54955";
NSString* const InstagramAuthenticationRedirectURL  = @"http://example.com";
//NSString* const InstagramAuthenticationURLFormat    = @"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token&scope=likes+comments+relationships";

NSString* const InstagramAuthenticationURLFormat    = @"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token&scope=basic+likes+comments+relationships";



@interface InstaLoginViewController () <UIWebViewDelegate>


// Last reload
@property (strong, nonatomic) NSDate *lastUpdatedDate;

@end

@implementation InstaLoginViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Hide navigation bar
//    [self.navigationController setNavigationBarHidden:YES];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    // Web view
//    self.webView                 = [[UIWebView alloc] init];
//    self.webView.delegate        = self;
//    self.webView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0];
//    
//    // Add subview
//    [self.view addSubview:self.webView];
    
    
    [self.webView sizeToFit];
    self.webView.scrollView.scrollEnabled = NO;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(backBtnPressed)];

    
    // Load web view
    [self loadAuthenticationURL];
}

- (void) backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.title = @"Log in";

    // Hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    // Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Show status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidBecomeActive
{
    NSTimeInterval timeIntervalSinceLastUpdated = [[NSDate date] timeIntervalSinceDate:self.lastUpdatedDate];
    
    // Make changes based on comparison (if the date is over two minutes, reload)
    if(timeIntervalSinceLastUpdated >= 120 || self.lastUpdatedDate == nil) {
        [self loadAuthenticationURL];
    }
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Bounds
    CGRect bounds = self.view.bounds;

    // Web view
    self.webView.frame = bounds;
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    self.webView = nil;
}

#pragma mark - Web view methods

- (void)loadAuthenticationURL
{
    // Return if already loading
    if(self.webView.isLoading) {
        return;
    }
    
    // Set last updated date
    self.lastUpdatedDate = [NSDate date];
    
    // Ensure web view is showing
    self.webView.hidden = NO;
    
    // Remove any error messages
//    [self removeMessageIconViewAnimated:NO];
    
    // URL string setup
    NSString *urlString   = [NSString stringWithFormat:InstagramAuthenticationURLFormat, InstagramClientIdentifier, InstagramAuthenticationRedirectURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    // Load url request
    [self.webView loadRequest:request];
}

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString rangeOfString:@"#"].location != NSNotFound)
    {
        if ([request.URL.absoluteString rangeOfString:InstagramAuthenticationRedirectURL].location != NSNotFound)
        {
            // Search for access token
            NSString *parameters = [[request.URL.absoluteString componentsSeparatedByString:@"#"] objectAtIndex:1];
            NSString *token      = [parameters stringByReplacingOccurrencesOfString:@"access_token=" withString:@""];
            if (token) {
                
                //[self addActivityIndicatorViewWithFrame:self.view.bounds animated:YES];
                
                // Register the user with application
                [[InstafollowersClient sharedClient] loginUserWithAccessToken:token
                                                                   completion:^(BOOL success, InstagramUser *user, NSNumber *coins, NSString *failureMessage, BOOL promoting)
                 {
                     if (success) {
                         
                         [InstafollowersClient sharedClient].igUser = user;
                         
                         // Set the user defaults for the user
                         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                         
                         [defaults setObject:token                               forKey:UserDefaultsKeyInstagramAccessToken];
                         [defaults setObject:user.dictionary                     forKey:UserDefaultsKeyInstagramUserDictionary];
                         [defaults setObject:coins                               forKey:UserDefaultsKeyCoins];
                         [defaults setObject:[NSNumber numberWithBool:promoting] forKey:UserDefaultsKeyPromoting];
                         
                         // If this user has enabled push notifications, has a device
                         // token, and a preferred language set, sync this user
                         // and device with our database
                         
                         UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
                         
                         if(types != UIRemoteNotificationTypeNone && [defaults objectForKey:UserDefaultsKeyDeviceToken] && [defaults objectForKey:UserDefaultsKeyDevicePreferredLanguage]) {
                             [[InstafollowersClient sharedClient] postDeviceWithDeviceToken:[defaults objectForKey:UserDefaultsKeyDeviceToken]
                                                                         preferredLanguaged:[defaults objectForKey:UserDefaultsKeyDevicePreferredLanguage]
                                                                                 completion:nil];
                         }
                         
                         // Reset all view controllers
                         AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
                         [delegate setViewControllers];
                         [delegate resetViewControllers];
                         
                         // Start updating for new user
                         [[DataManagement sharedClient] startUpdating];
                         
//                         // Push theme view controller if prompted to do so
//                         if([[defaults objectForKey:UserDefaultsKeyPromptSetTheme] boolValue] == YES) {
//                             
//                             ThemeViewController *viewController = [[ThemeViewController alloc] init];
//                             
//                             [self.navigationController pushViewController:viewController animated:YES];
//                             
//                             // Do not prompt again when logging in
//                             [defaults setObject:[NSNumber numberWithBool:NO] forKey:UserDefaultsKeyPromptSetTheme];
//                             
//                         } else {
//                             
//                             // Dismiss the view controller
//                             [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//                             
//                         }
                         
                     } else {
                         
                         if(failureMessage) {
                             
                             // Use this for block action
                             __unsafe_unretained typeof(self) weakSelf = self;
                             
                             // Add message icon view with block
                             [self addMessageIconViewToView:self.view
                                                      frame:self.view.bounds
                                                       icon:[UIImage imageNamed:@"XMessageIcon"]
                                                       text:failureMessage
                                                 detailText:@"Tap to refresh"
                                                   animated:YES
                                                     action:^{
                                                         [weakSelf loadAuthenticationURL];
                                                     }];
                             
                         } else {
                             
                             // Use this for block action
                             __unsafe_unretained typeof(self) weakSelf = self;
                             
                             // Add message icon view with block
                             [self addMessageIconViewToView:self.view
                                                      frame:self.view.bounds
                                                       icon:[UIImage imageNamed:@"XMessageIcon"]
                                                       text:@"There was an issue logging in"
                                                 detailText:@"Tap to refresh"
                                                   animated:YES
                                                     action:^{
                                                         [weakSelf loadAuthenticationURL];
                                                     }];
                             
                         }
                         
                         // Logout user
                         [[DataManagement sharedClient] logoutUser];
                         
                     }
                     
                     [self removeActivityIndicatorViewAnimated:YES];
                     
                 }];
                
            }
            
            // Hide the webview, otherwise the callback url will appear
            self.webView.hidden = YES;
        }
    }
    
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self addActivityIndicatorViewWithFrame:self.view.bounds animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self removeActivityIndicatorViewAnimated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // Use this for block action
    __unsafe_unretained typeof(self) weakSelf = self;
    
    // Add message icon view with block
    [self addMessageIconViewToView:self.view
                             frame:self.view.bounds
                              icon:[UIImage imageNamed:@"XMessageIcon"]
                              text:@"Error loading"
                        detailText:@"Tap to refresh"
                          animated:YES
                            action:^{
                                [weakSelf loadAuthenticationURL];
                            }];
    
    // Remove activity indicator view
    [self removeActivityIndicatorViewAnimated:YES];
}

@end
