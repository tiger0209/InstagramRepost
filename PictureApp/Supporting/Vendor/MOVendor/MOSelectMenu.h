//
//  MOSelectMenu.h
//  Instafollowers
//
//  Created by Michael Orcutt on 2/16/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MOSelectMenuDelegate <NSObject>

- (NSInteger)menuItemsInMenu;

- (NSString *)menuItemTitleAtIndex:(NSInteger)index;

- (void)menuDidSelectItemAtIndex:(NSInteger)index;

@end

@interface MOSelectMenu : UITabBar

// Delegate
@property (weak, nonatomic) id<MOSelectMenuDelegate> selectMenuDelegate;

// Reload select menu
- (void)reloadMenu;
- (void)scrollToZero;

// Selection
- (void)setMenuItemSelectedAtIndex:(NSInteger)index animated:(BOOL)animated;
- (NSInteger)selectedIndex;

@end
