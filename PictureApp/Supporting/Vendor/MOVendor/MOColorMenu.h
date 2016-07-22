//
//  MOColorMenu.h
//  Instafollowers
//
//  Created by Michael Orcutt on 2/26/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MOColorMenuDelegate <NSObject>

- (NSInteger)menuItemsInMenu;

- (UIColor *)menuItemColorAtIndex:(NSInteger)index;

- (CGSize)menuItemSize;

- (void)menuDidSelectItemAtIndex:(NSInteger)index;

@end

@interface MOColorMenu : UIView

// Delegate
@property (weak, nonatomic) id<MOColorMenuDelegate> delegate;

// Reload select menu
- (void)reloadMenu;
- (void)reloadMenuWithSelectedIndex:(NSInteger)selectedIndex;

// Selected
- (void)setMenuItemSelectedAtIndex:(NSInteger)index animated:(BOOL)animated;
- (NSInteger)selectedIndex;

@end
