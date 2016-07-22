//
//  MOMenuTitleView.h
//  Instafollowers
//
//  Created by Michael Orcutt on 2/21/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MOMenuTitleViewArrowDirectionUp,
    MOMenuTitleViewArrowDirectionDown
} MOMenuTitleViewArrowDirection;

@protocol MOMenuTitleViewDelegate <NSObject>

- (void)titleViewWasTapped;

@end

@interface MOMenuTitleView : UIView

// Titles for menu title view
@property (strong, nonatomic) NSArray *titles;

// Selected index and arrow direction
- (void)setSelectedIndex:(NSInteger)selectedIndex
          arrowDirection:(MOMenuTitleViewArrowDirection)arrowDirection
                animated:(BOOL)animated;

// Arrow direction
- (void)setArrowDirection:(MOMenuTitleViewArrowDirection)arrowDirection animated:(BOOL)animated;

// Delegate
@property (weak, nonatomic) id<MOMenuTitleViewDelegate> delegate;

@end
