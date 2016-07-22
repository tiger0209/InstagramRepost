//
//  AppDelegate.h
//  PictureApp
//
//  Created by Lion0324 on 10/19/15.
//  Copyright © 2015 Lion0324. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FeedCollectionViewController;
@class ARSegmentPageController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Tab bar view controllers
@property (strong, nonatomic) FeedCollectionViewController              *m_feedCollectionViewController;
@property (strong, nonatomic) ARSegmentPageController                   *m_ARSegmentPageController;

@property (assign, nonatomic) CGRect g_windowFrame;


////lgilgilgi
@property (strong, nonatomic) NSArray *favoritesIdentifierArray;


- (void)setViewControllers;
- (void)resetViewControllers;

- (void)showUserInfo;

@end

