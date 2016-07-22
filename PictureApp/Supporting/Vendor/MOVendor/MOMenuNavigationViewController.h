//
//  MOMenuNavigationViewController.h
//  Instafollowers
//
//  Created by Michael Orcutt on 2/22/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOMenuNavigationViewController : UINavigationController

- (id)initWithRootViewControllers:(NSArray *)rootViewControllers;

- (void)loadRootViewControllersTitles;

- (void)resetNavigationController;

@end
