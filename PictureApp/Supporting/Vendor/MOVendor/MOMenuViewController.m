//
//  MOMenuViewController.m
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/24/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "MOMenuViewController.h"

#import "MOMenuCell.h"
#import "MOMenuTitleView.h"

@interface MOMenuViewController () <UITableViewDataSource, UITableViewDelegate, MOMenuTitleViewDelegate>

// Menu position
@property (nonatomic) MOMenuViewControllerMenuPosition menuPosition;

// Table view properties used to navigate between view controllers
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIToolbar   *tableViewContainer;

// Title View
@property (strong, nonatomic) MOMenuTitleView *titleView;

@end

@implementation MOMenuViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Background color
    self.view.backgroundColor
    = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:239.0/255.0 alpha:1.0];
    
    // Table view for selection
    self.tableView                 = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor  = [UIColor colorWithRed:224.0/255.0 green:226.0/255.0 blue:229.0/255.0 alpha:1.0];
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.scrollEnabled   = NO;
    
    // Table view container
    self.tableViewContainer              = [[UIToolbar alloc] init];
    self.tableViewContainer.barTintColor = [UIColor whiteColor];
    self.tableViewContainer.translucent  = NO;
    
    [self.tableViewContainer addSubview:self.tableView];
    
    [self.view addSubview:self.tableViewContainer];

    // Force redraw of the previously active tab.
    NSUInteger lastIndex = _selectedIndex;
    _selectedIndex = NSNotFound;
    self.selectedIndex = lastIndex;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Reset the title view
    [self loadTitles];
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.tableView          = nil;
    self.tableViewContainer = nil;
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Relayout menu
    [self relayoutMenu];
}

- (void)relayoutMenu
{
    // Layout setup
    CGRect bounds = self.view.bounds;
    
    // Table height
    CGFloat tableViewHeight = (self.viewControllers.count * 46.0);
    
    // Table view container
    CGRect tableViewContainerFrame = bounds;

    if(self.menuPosition == MOMenuViewControllerMenuPositionUp) {
        tableViewContainerFrame.origin.y = -tableViewContainerFrame.size.height;
    } else if(self.menuPosition == MOMenuViewControllerMenuPositionDown) {
        tableViewContainerFrame.origin.y = -bounds.size.height + tableViewHeight;
    }
    
    self.tableViewContainer.frame = tableViewContainerFrame;

    // Table view
    CGRect tableViewFrame      = self.view.bounds;
    tableViewFrame.size.height = tableViewHeight;
    tableViewFrame.origin.y    = (tableViewContainerFrame.size.height - tableViewHeight);
    
    self.tableView.frame = tableViewFrame;
}

#pragma mark - Child view controller methods

- (void)setViewControllers:(NSArray *)newViewControllers
{
    UIViewController *oldSelectedViewController = self.selectedViewController;
    
    // Remove the old child view controllers
    [_viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj willMoveToParentViewController:nil];
        [obj removeFromParentViewController];
    }];
    
    _viewControllers = [newViewControllers copy];
    
    // This follows the same rules as UITabBarController for trying to
    // re-select the previously selected view controller
    NSUInteger newIndex = [_viewControllers indexOfObject:oldSelectedViewController];
    
    if (newIndex != NSNotFound) {
        _selectedIndex = newIndex;
    } else if(newIndex < [_viewControllers count]) {
        _selectedIndex = newIndex;
    } else {
        _selectedIndex = 0;
    }
    
    // Add the new child view controllers and reset the title view
    [_viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addChildViewController:obj];
        [obj didMoveToParentViewController:self];
    }];
    
    // Load the title view with changes
    [self loadTitles];
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex
{
    // Reset selected index and view controller
    // associated with that index
    if (![self isViewLoaded]) {
        _selectedIndex = newSelectedIndex;
    } else if (_selectedIndex != newSelectedIndex) {
        
        UIViewController *fromViewController;
        UIViewController *toViewController;
        
        if (_selectedIndex != NSNotFound) {
            fromViewController = self.selectedViewController;
        }
        
        _selectedIndex = newSelectedIndex;
        
        if (_selectedIndex != NSNotFound) {
            toViewController = self.selectedViewController;
        }
        
        if(toViewController == nil) {
            [fromViewController.view removeFromSuperview];
        } else if(fromViewController == nil) {
            toViewController.view.frame = self.view.bounds;
            [self.view insertSubview:toViewController.view belowSubview:self.tableViewContainer];
        } else {
            [fromViewController.view removeFromSuperview];
            
            toViewController.view.frame = self.view.bounds;
            [self.view insertSubview:toViewController.view belowSubview:self.tableViewContainer];
        }
        
        self.navigationItem.leftBarButtonItem  = toViewController.navigationItem.leftBarButtonItem;
        self.navigationItem.rightBarButtonItem = toViewController.navigationItem.rightBarButtonItem;
    }
    
    // Reset the title
    [self.titleView setSelectedIndex:_selectedIndex
                      arrowDirection:MOMenuTitleViewArrowDirectionUp
                            animated:YES];
    
    // Hide the menu
    [self setMenuPosition:MOMenuViewControllerMenuPositionUp animated:YES];
    
    // Select the table view cell
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
    
}

- (UIViewController *)selectedViewController
{
    if (self.selectedIndex != NSNotFound)
        return (self.viewControllers)[self.selectedIndex];
    else
        return nil;
}

- (void)setSelectedViewController:(UIViewController *)newSelectedViewController
{
    NSUInteger index = [self.viewControllers indexOfObject:newSelectedViewController];
    if (index != NSNotFound)
        [self setSelectedIndex:index];
}

#pragma mark - Title view and MOMenuTitleViewDelegate

- (void)loadTitles
{
    // Initialize the title view and
    // set the delegate property
    // if it is not already set
    if(!self.titleView) {
        self.titleView          = [[MOMenuTitleView alloc] init];
        self.titleView.delegate = self;
    }
    
    // Enumerate over view controllers to get titles
    NSMutableArray *titles = [NSMutableArray array];
    
    [_viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *title = [[obj navigationItem] title];
        
        if(title.length == 0) {
            title = @"";
        }
        
        [titles addObject:title];
    }];
    
    // Set titles
    self.titleView.titles = titles;
    
    // Set title selected index
    [self.titleView setSelectedIndex:_selectedIndex arrowDirection:MOMenuTitleViewArrowDirectionUp animated:NO];
    
    // Relayout title view
    [self.titleView sizeToFit];
    
    // Set as title view
    self.navigationItem.titleView = self.titleView;
    
    // Reload table view
    [self.tableView reloadData];
    
    // Reset selected index
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
}

- (void)titleViewWasTapped
{
    if(self.menuPosition == MOMenuViewControllerMenuPositionUp) {
        [self setMenuPosition:MOMenuViewControllerMenuPositionDown animated:YES];
        [self.titleView setArrowDirection:MOMenuTitleViewArrowDirectionDown animated:YES];
    } else if(self.menuPosition == MOMenuViewControllerMenuPositionDown) {
        [self setMenuPosition:MOMenuViewControllerMenuPositionUp animated:YES];
        [self.titleView setArrowDirection:MOMenuTitleViewArrowDirectionUp animated:YES];
    }
}

#pragma mark - Menu position

- (void)setMenuPosition:(MOMenuViewControllerMenuPosition)menuPosition
{
    [self setMenuPosition:menuPosition animated:NO];
}

- (void)setMenuPosition:(MOMenuViewControllerMenuPosition)menuPosition animated:(BOOL)animated
{
    // Set property
    _menuPosition = menuPosition;
    
    // Ensure menu is on top
    [self.view bringSubviewToFront:self.tableViewContainer];
    
    // View changes based upon animated property
    if(animated) {
        
        if(_menuPosition == MOMenuViewControllerMenuPositionDown) {
            
            // Downward animation
            // bounces to position
            [UIView animateWithDuration:.75
                                  delay:0.0
                 usingSpringWithDamping:.50
                  initialSpringVelocity:.50
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 
                                 // Relayout the menu
                                 [self relayoutMenu];
                                 
                             }
                             completion:^(BOOL finished) {
                                 
                                 // Reset interaction
                                 self.view.window.userInteractionEnabled = YES;
                                 
                             }];

        } else {
            
            
            [UIView animateWithDuration:.25 animations:^{
                
                // Relayout menu
                [self relayoutMenu];
                
            } completion:^(BOOL finished) {

                // Reset interaction
                self.view.window.userInteractionEnabled = YES;

            }];
            
        }
        
    } else {
        
        // No animation, relayout
        [self relayoutMenu];
        
    }
}

#pragma mark - Table view data source for navigation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewControllers.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    MOMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MOMenuCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [(UIViewController *)self.viewControllers[indexPath.row] navigationItem].title;
    
    if(self.selectedIndex == indexPath.row) {
        cell.selected = YES;
    } else {
        cell.selected = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setSelectedIndex:indexPath.row];
}

@end
