//
//  MOMenuNavigationViewController.m
//  Instafollowers
//
//  Created by Michael Orcutt on 2/22/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "MOMenuNavigationViewController.h"

#import "MOMenuViewController.h"

@interface MOMenuNavigationViewController ()

@end

@implementation MOMenuNavigationViewController

- (id)initWithRootViewControllers:(NSArray *)rootViewControllers
{
    MOMenuViewController *menuViewController = [[MOMenuViewController alloc] init];
    menuViewController.viewControllers       = rootViewControllers;
    
    self = [super initWithRootViewController:menuViewController];
    if (self) {
        
    }
    return self;
}

- (void)loadRootViewControllersTitles
{
    [(MOMenuViewController *)self.viewControllers[0] loadTitles];
}

- (void)resetNavigationController
{
    [self popToRootViewControllerAnimated:NO];
    
    [(MOMenuViewController *)self.viewControllers[0] setSelectedIndex:0];
}

@end
