//
//  MOTabBarViewController.m
//  InstagramLikes
//
//  Created by Michael Orcutt on 1/23/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "MOTabBarViewController.h"
#import "MOBaseViewController.h"
#import "MOTabBarItem.h"

#import "UIColor+String.h"
#import "UIImage+Color.h"

#import "LoginViewController.h"
#import "MOMenuNavigationViewController.h"

#import "Constants.h"

NSInteger const TabBarItemTagOffset = 2105;

@interface MOTabBarViewController ()

@end

@implementation MOTabBarViewController

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
    self.tabBar              = [[UITabBar alloc] init];
    self.tabBar.backgroundColor = [UIColor blackColor];
    self.tabBar.barTintColor = [UIColor blackColor];//[UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0];
    self.tabBar.translucent  = NO;
    
    [self.view addSubview:self.tabBar];
    
    self.container = [[UIView alloc] init];
    
    [self.view insertSubview:self.container belowSubview:self.tabBar];
    
    [self reloadTabBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.container = nil;
    self.tabBar    = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]) {
        // Reset selected index
        self.tabBarController.selectedIndex = 0;
        
        // Display login view controller
        [self displayLoginViewControllerWithCompletion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
}

#pragma mark - Theme

#pragma mark - Layout

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Layout setup
    CGRect viewBounds = self.view.bounds;
    
    // 'container' frame as 'viewBounds'
    self.container.frame = viewBounds;
    
    // 'tabBar' frame setup
    CGRect tabBarFrame;
    tabBarFrame.size   = CGSizeMake(viewBounds.size.width, UITabBarHeight);
    tabBarFrame.origin = CGPointMake(0.0, viewBounds.size.height - tabBarFrame.size.height);
    
    // Set 'tabBar' frame as 'tabBarFrame'
    self.tabBar.frame = tabBarFrame;
    
    // Tab bar items setup
    __block CGRect tabBarItemFrame = CGRectMake(1, 1, 0, 0);
    tabBarItemFrame.size = CGSizeMake(floorf(tabBarFrame.size.width / self.viewControllers.count), tabBarFrame.size.height - 1);
    
    // Iterate over tab bar subviews
    [self.tabBar.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        // If the tab bar subview matches MOTabBarItem class, layout using 'tabBarItemFrame'
        if([obj isKindOfClass:[MOTabBarItem class]]) {
            // Set MOTabBarItem frame from 'tabBarItemFrame'
            
            [obj setFrame:tabBarItemFrame];
            
            // Offset x origin
            tabBarItemFrame.origin.x += tabBarItemFrame.size.width + 1;
            if (tabBarItemFrame.origin.x > viewBounds.size.width / 2) {
                tabBarItemFrame.size.width = viewBounds.size.width - tabBarItemFrame.origin.x - 1;
            }
            
        }
        
    }];
    
}

#pragma mark - Tab Bar Layout

- (void)layoutTabButtons
{
    NSUInteger index = 0;
	NSUInteger count = [self.viewControllers count];
    
    CGFloat width = floorf(self.view.bounds.size.width/count);
    
    CGRect rect = CGRectMake(0.0, 0.0, width, UITabBarHeight);
    
    for(UIButton *button in [self.tabBar subviews]) {
        if([button isKindOfClass:[UIButton class]]) {
            if (index == count - 1)
                rect.size.width = self.view.bounds.size.width - rect.origin.x;
            
            button.frame = rect;
            rect.origin.x += (rect.size.width + 1.0);
            
            ++index;
        }
    }
}

#pragma mark - Tab bar

- (void)reloadTabBar
{
    // Remove any current MOTabBarItem
    [self.tabBar.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if([obj isKindOfClass:[MOTabBarItem class]]) {
            [obj removeFromSuperview];
        }
        
    }];
    
    // Add tab bar items
    [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        // Initialize and set 'tabBarItem' properties based on 'viewControllers'
        MOTabBarItem *tabBarItem    = [[MOTabBarItem alloc] init];
        tabBarItem.image            = [[obj tabBarItem] image];
        tabBarItem.highlightedImage = [[obj tabBarItem] selectedImage];

        tabBarItem.tag              = (TabBarItemTagOffset + idx);
        
        /////lgilgilgi
        tabBarItem.textLabel.text = [[obj tabBarItem] title];
        
        if(self.selectedIndex == idx) {
            tabBarItem.highlighted = YES;
        } else {
            tabBarItem.highlighted = NO;
        }
        
        // 'tabBarItem' block that will select the according view controller
        tabBarItem.tapBlock = ^{
            [self setSelectedIndex:idx];
        };
        
//        tabBarItem.layer.borderWidth = 1.0f;
//        tabBarItem.layer.borderColor = [[UIColor blackColor] CGColor];
        
        
        
        // Add 'tabBarItem' to 'tabBar'
        [self.tabBar addSubview:tabBarItem];
        
    }];
    
    // Force redraw of the previously active 'tabBarItem'
	NSUInteger lastIndex = _selectedIndex;
	_selectedIndex = NSNotFound;
	self.selectedIndex = lastIndex;
}

#pragma mark - View controllers

- (void)setViewControllers:(NSArray *)newViewControllers
{
	UIViewController *oldSelectedViewController = self.selectedViewController;
    
	// Remove the old child view controllers.
    [_viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[obj willMoveToParentViewController:nil];
		[obj removeFromParentViewController];
    }];
    
	_viewControllers = [newViewControllers copy];
    
	// This follows the same rules as UITabBarController for trying to
	// re-select the previously selected view controller.
	NSUInteger newIndex = [_viewControllers indexOfObject:oldSelectedViewController];
	if(newIndex != NSNotFound) {
        _selectedIndex = newIndex;
    } else if(newIndex < [_viewControllers count]) {
        _selectedIndex = newIndex;
    } else {
        _selectedIndex = 0;
    }
    
	// Add the new child view controllers
    [_viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[self addChildViewController:obj];
		[obj didMoveToParentViewController:self];
    }];
    
    // Reload the 'tabBar'
	if ([self isViewLoaded])
		[self reloadTabBar];
}

#pragma mark - Tab bar selection methods

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    // If the selected index is out of range, return
    if(selectedIndex > (self.viewControllers.count - 1)) {
        return;
    }
    
	if (![self isViewLoaded]) {
        
        // If the view is not loaded yet, set 'selectedIndex'
		_selectedIndex = selectedIndex;
        
	} else if (_selectedIndex != selectedIndex) {
        
        // Setup for setting 'selectedIndex'
		UIViewController *fromViewController;
		UIViewController *toViewController;
        
		if(_selectedIndex != NSNotFound) {
            
            // Deselect previously selected 'selectedIndex'
			MOTabBarItem *tabBarItem = (MOTabBarItem *)[self.tabBar viewWithTag:(TabBarItemTagOffset + _selectedIndex)];
            tabBarItem.highlighted   = NO;

            /////lgilgilgi
            [tabBarItem setBackgroundColor:[UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0]];
            tabBarItem.textLabel.textColor = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0];
//            /////lgilgilgi
//            tabBarItem.textLabel.textColor = [UIColor colorWithRed:168.0/255.0 green:171.0/255.0 blue:176.0/255.0 alpha:1.0];

            // set 'fromViewController' from previously selected 'selectedViewController'
			fromViewController = self.selectedViewController;
            
		}
        
        // Set selected index
		_selectedIndex = selectedIndex;
        
		if (_selectedIndex != NSNotFound) {
			MOTabBarItem *tabBarItem = (MOTabBarItem *)[self.tabBar viewWithTag:(TabBarItemTagOffset + _selectedIndex)];
            tabBarItem.highlighted   = YES;
            
//            /////lgilgilgi
//            tabBarItem.textLabel.textColor = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0];
            /////lgilgilgi
            [tabBarItem setBackgroundColor:[UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:1.0]];
            tabBarItem.textLabel.textColor = [UIColor colorWithRed:168.0/255.0 green:171.0/255.0 blue:176.0/255.0 alpha:1.0];

			toViewController = self.selectedViewController;
		}
        
        if(toViewController == nil) {
            
            // Remove 'fromViewController'
            [fromViewController willMoveToParentViewController:nil];
            [fromViewController.view removeFromSuperview];
            [fromViewController removeFromParentViewController];
            
		} else if(fromViewController == nil) {
            
            // 'toViewController' frame
            toViewController.view.frame = self.view.bounds;
            
            // Add 'toViewController'
            [self.view insertSubview:toViewController.view belowSubview:self.tabBar];
            [self addChildViewController:toViewController];
            [toViewController didMoveToParentViewController:self];
            
        } else {
            
            // Remove 'fromViewController'
            [fromViewController willMoveToParentViewController:nil];
            [fromViewController.view removeFromSuperview];
            [fromViewController removeFromParentViewController];
            
            // 'toViewController' frame
            toViewController.view.frame = self.view.bounds;
            
            // Add 'toViewController'
            [self.view insertSubview:toViewController.view belowSubview:self.tabBar];
            [self addChildViewController:toViewController];
            [toViewController didMoveToParentViewController:self];
            
        }
        
	}
}

#pragma mark - Selected view controller methods

- (UIViewController *)selectedViewController
{
	if (self.selectedIndex != NSNotFound)
		return [self.viewControllers objectAtIndex:self.selectedIndex];
	else
		return nil;
}

#pragma mark - Index highlighted

- (BOOL)isIndexHighlighted:(NSInteger)index
{
    // Tab bar item for this index
    MOTabBarItem *tabBarItem = (MOTabBarItem *)[self.tabBar viewWithTag:(TabBarItemTagOffset + index)];
    
    // Use 'tabBarItem' 'highlightedIndicatorImageView' hidden property
    // to tell if the index is highlighted
    return tabBarItem.highlightedIndicatorImageView.hidden;
}

- (void)setIndexHighlighted:(BOOL)highlighted index:(NSInteger)index
{
    MOTabBarItem *tabBarItem = (MOTabBarItem *)[self.tabBar viewWithTag:(TabBarItemTagOffset + index)];
    
    if(highlighted) {
        tabBarItem.highlightedIndicatorImageView.hidden = NO;
    } else {
        tabBarItem.highlightedIndicatorImageView.hidden = YES;
    }
}

#pragma mark - Display login view controller

- (void)displayLoginViewControllerWithCompletion:(void (^)(void))completionBlock
{
//    LogInViewController *loginViewController = [[LogInViewController alloc] init];
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"LogInViewController"];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:navigationController animated:YES completion:^{
        
        if(completionBlock) {
            completionBlock();
        }
        
    }];
}

@end
