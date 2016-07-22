//
//  MOColorMenu.m
//  Instafollowers
//
//  Created by Michael Orcutt on 2/26/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "MOColorMenu.h"
#import "MOColorMenuCell.h"

// String constants
NSString *ColorMenuCellIdentifier = @"ColorMenuCellIdentifier";

@interface MOColorMenu () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) UIView *topSeparator;
@property (strong, nonatomic) UIView *bottomSeparator;

@property (nonatomic) BOOL scrollViewIsAnimating;

@end

@implementation MOColorMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Not translucent white by default
        self.backgroundColor = [UIColor whiteColor];
        
        // Collection view
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewLayout.scrollDirection             = UICollectionViewScrollDirectionHorizontal;
        collectionViewLayout.minimumLineSpacing          = 0.0;
        
        self.collectionView                                = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
        self.collectionView.backgroundColor                = [UIColor clearColor];
        self.collectionView.delegate                       = self;
        self.collectionView.dataSource                     = self;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.bounces                        = YES;
        self.collectionView.allowsMultipleSelection        = NO;
        self.collectionView.scrollsToTop                   = NO;
        
        [self.collectionView registerClass:[MOColorMenuCell class] forCellWithReuseIdentifier:ColorMenuCellIdentifier];
        
        [self addSubview:self.collectionView];
        
        // Borders
        self.topSeparator                 = [[UIView alloc] init];
        self.topSeparator.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:226.0/255.0 blue:229.0/255.0 alpha:1.0];
        
        [self addSubview:self.topSeparator];

        self.bottomSeparator                 = [[UIView alloc] init];
        self.bottomSeparator.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:226.0/255.0 blue:229.0/255.0 alpha:1.0];

        [self addSubview:self.bottomSeparator];
    
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Setup
    CGRect bounds = self.bounds;
    
    // Collection view
    self.collectionView.frame = bounds;
    
    // Separator
    CGRect separatorFrame      = bounds;
    separatorFrame.size.height = .50;
    
    self.topSeparator.frame = separatorFrame;
    
    separatorFrame.origin.y    = (bounds.size.height - separatorFrame.size.height);
    
    self.bottomSeparator.frame = separatorFrame;
}

#pragma mark - Reload

- (void)reloadMenu
{
    // Reload collection view
    [self.collectionView reloadData];
}

- (void)reloadMenuWithSelectedIndex:(NSInteger)selectedIndex
{
    // Reload
    [self.collectionView reloadData];
    
    // Select index
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0]
                                      animated:NO
                                scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

#pragma mark - Selected

- (void)setMenuItemSelectedAtIndex:(NSInteger)index animated:(BOOL)animated
{
    // Set the selected index
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                                      animated:animated
                                scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

- (NSInteger)selectedIndex
{
    return [[self.collectionView.indexPathsForSelectedItems lastObject] row];
}

#pragma mark - Collection view datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.delegate menuItemsInMenu];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MOColorMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ColorMenuCellIdentifier forIndexPath:indexPath];
    
    cell.color = [self.delegate menuItemColorAtIndex:[indexPath row]];
    
    cell.selected = [self.collectionView.indexPathsForSelectedItems containsObject:indexPath];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.delegate menuItemSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    // Setup
    CGFloat width = self.collectionView.bounds.size.width;
    
    // Inset
    CGFloat inset = floorf((width - [self.delegate menuItemSize].width)/2.0);
    
    // Return inset
    return UIEdgeInsetsMake(0.0, inset, 0.0, inset);
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Stop scroll view did scroll from handling
    self.scrollViewIsAnimating = YES;
    
    // Scroll to selected collection view cell
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:YES];
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // Only reset selection if scrollViewWillBeginDecelerating
    // is not going to be called
    if(decelerate == NO) {
        // Stop scroll view did scroll from handling
        self.scrollViewIsAnimating = YES;
        
        // Reset selection
        [self resetSelectedIndexPathAndScrollToPosition:YES];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    // Stop scroll view did scroll from handling
    self.scrollViewIsAnimating = YES;
    
    // Reset selection
    [self resetSelectedIndexPathAndScrollToPosition:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Handle selection changes if it is
    // not already being handled
    if(!self.scrollViewIsAnimating) {
        [self resetSelectedIndexPathAndScrollToPosition:NO];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // Scroll view is no longer animating
    self.scrollViewIsAnimating = NO;
    
    // Send delegate notifications
    if([self.delegate respondsToSelector:@selector(menuDidSelectItemAtIndex:)]) {
        
        NSIndexPath *selectedIndexPath = [self.collectionView.indexPathsForSelectedItems lastObject];
        
        [self.delegate menuDidSelectItemAtIndex:[selectedIndexPath row]];
        
    }
}

- (void)resetSelectedIndexPathAndScrollToPosition:(BOOL)scrollToPosition
{
    // Visible rect
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size   = self.collectionView.bounds.size;
    
    // Least distance index path and distance to calculate which
    // index path to land on
    __block NSIndexPath *leastDistanceIndexPath;
    __block CGFloat leastDistance = CGFLOAT_MAX;
    
    // Enumerate over visible cells to calculate the closest cell
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        // Index path of cell
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:obj];
        
        // Layout attributes of cell
        UICollectionViewLayoutAttributes *layoutAttributes
        = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[self.collectionView indexPathForCell:obj]];
        
        CGRect frame = layoutAttributes.frame;
        
        // If the cell is within the view, check it's distance
        if(CGRectIntersectsRect(frame, visibleRect)) {
            
            // If the cell is less than the previous cell, set
            // least distance and least distance index path
            CGFloat distanceFromCenter = ABS(CGRectGetMidX(visibleRect) - layoutAttributes.center.x);
            
            if(distanceFromCenter < leastDistance) {
                leastDistance = distanceFromCenter;
                leastDistanceIndexPath = indexPath;
            }
            
        }
        
    }];
    
    // Deselect any selected cells
    [self.collectionView.indexPathsForSelectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.collectionView deselectItemAtIndexPath:obj animated:NO];
    }];
    
    // Select cell and position based upon scrollToPosition value
    if(scrollToPosition == YES) {
        [self.collectionView selectItemAtIndexPath:leastDistanceIndexPath
                                          animated:YES
                                    scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    } else {
        [self.collectionView selectItemAtIndexPath:leastDistanceIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

@end
