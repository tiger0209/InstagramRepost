//
//  AppDelegate.m
//  PictureApp
//
//  Created by Lion0324 on 10/19/15.
//  Copyright © 2015 Lion0324. All rights reserved.
//

#import "AppDelegate.h"

// Categories
#import "NSString+Color.h"

#import "Constants.h"

// View controllers
#import "MOTabBarViewController.h"



#import "CollectionViewController.h"
#import "FeedCollectionViewController.h"
#import "MediaCollectionViewController.h"
#import "LikesCollectionViewController.h"
#import "FavoritesCollectionViewController.h"
#import "ARSegmentPageController.h"

#import "TrendingViewController.h"
#import "SearchingViewController.h"


// Data management
#import "DataManagement.h"

#import "UIImageView+WebCache.h"

@interface AppDelegate ()

// Tab bar
@property (strong, nonatomic) MOTabBarViewController *tabBarViewController;

@end



@implementation AppDelegate

@synthesize favoritesIdentifierArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Customize
    [self customizeAppearance];
    
    // Set view controllers
    /////lgilgilgi
    [self setViewControllers];
    
    ////lgilgilgi
    self.favoritesIdentifierArray  = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyFavoritesIdentifierArray]];

    
    [self.window makeKeyAndVisible];

    self.g_windowFrame = self.window.frame;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self performSelector:@selector(runApplicationDidBecomeActiveMethods) withObject:nil afterDelay:1.0];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)customizeAppearance
{
    // Status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)runApplicationDidBecomeActiveMethods
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]) {
        
        // Refresh if needed
        [self updateLoggedInUser];
        
    }
}

- (void)updateLoggedInUser
{
    // Date comparison setup
    NSString *userIdentifier = [[DataManagement sharedClient] user].identifier;
    
    NSDate *lastUpdatedDate
    = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:UserDefaultsKeyLastUpdatedStringFormat, userIdentifier]];
    NSDate *date
    = [NSDate date];
    
    NSTimeInterval timeIntervalSinceLastUpdated = [date timeIntervalSinceDate:lastUpdatedDate];
    
    // Make changes based on comparison
    if(timeIntervalSinceLastUpdated >= 600 || lastUpdatedDate == nil)
    {
        // If there has not been an update for 10 minutes (600 seconds), update
        [self.m_feedCollectionViewController refresh];
    }
}

- (void)setViewControllers
{
    // Tab Bar Controller
    self.tabBarViewController = [[MOTabBarViewController alloc] init];
    
    self.m_feedCollectionViewController = [[FeedCollectionViewController alloc] initWithNibName:@"FeedCollectionViewController" bundle:nil];
    MediaCollectionViewController *collectionView2 = [[MediaCollectionViewController alloc] initWithNibName:@"MediaCollectionViewController" bundle:nil];
    LikesCollectionViewController *collectionView3 = [[LikesCollectionViewController alloc] initWithNibName:@"LikesCollectionViewController" bundle:nil];
    FavoritesCollectionViewController *collectionView4 = [[FavoritesCollectionViewController alloc] initWithNibName:@"FavoritesCollectionViewController" bundle:nil];
    
    self.m_ARSegmentPageController = [[ARSegmentPageController alloc] init];
    [self.m_ARSegmentPageController setViewControllers:@[self.m_feedCollectionViewController, collectionView2, collectionView3, collectionView4]];
    self.m_ARSegmentPageController.segmentMiniTopInset = 64;
    
    self.m_ARSegmentPageController.tabBarItem.image         = [UIImage imageNamed:@"TabBarUserSelected"];
    self.m_ARSegmentPageController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarUser"];
    
//    //////lgilgilgi
    self.m_ARSegmentPageController.tabBarItem.title = @"User";

    UINavigationController *userNavigationController1 = [[UINavigationController alloc] initWithRootViewController:self.m_ARSegmentPageController];


    //////////////Tab 2
    TrendingViewController *collectionView11 = [[TrendingViewController alloc] initWithNibName:@"TrendingViewController" bundle:nil];

    
    collectionView11.tabBarItem.image         = [UIImage imageNamed:@"TabBarUserSelected"];
    collectionView11.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarUser"];
    
//    //////lgilgilgi
    collectionView11.tabBarItem.title = @"Trending";
    
    UINavigationController *userNavigationController2 = [[UINavigationController alloc] initWithRootViewController:collectionView11];

    
    /////////////Tab 3
    SearchingViewController *collectionView22 = [[SearchingViewController alloc] initWithNibName:@"SearchingViewController" bundle:nil];
    
    
    collectionView22.tabBarItem.image         = [UIImage imageNamed:@"TabBarUserSelected"];
    collectionView22.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarUser"];
    
    //    //////lgilgilgi
    collectionView22.tabBarItem.title = @"Searching";
    
    UINavigationController *userNavigationController3 = [[UINavigationController alloc] initWithRootViewController:collectionView22];
    


    // Set tab bar view controllers
    self.tabBarViewController.viewControllers
    = @[ userNavigationController1,
         userNavigationController2,
         userNavigationController3];
    
    // Set window root view controller
    self.window.rootViewController = self.tabBarViewController;
}

- (void)resetViewControllers
{
    // Reset tab bar and menu navigation controllers
    [self.tabBarViewController setSelectedIndex:0];
    
    // Reset view controllers
}

- (void)showUserInfo
{
    InstagramUser *user = [[DataManagement sharedClient] user];
    ARSegmentPageHeader* v_headerView = (ARSegmentPageHeader*)self.m_ARSegmentPageController.headerView;
    // = self.user.username;
    
    // Profile picture
    [v_headerView.m_user_imageView sd_setImageWithURL:user.profilePictureURL];
    [v_headerView.m_count_follower_Label setText:user.followersCount];
    [v_headerView.m_count_followeing_Label setText:user.followsCount];
    
    
    UINavigationController *userNavigationController = [self.tabBarViewController.viewControllers objectAtIndex:0] ;
    [userNavigationController setTitle:user.username];

}


@end
