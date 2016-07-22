//
//  MasterViewController.m
//  FHSegmentedViewControllerDemo
//
//  Created by Johnny iDay on 13-12-29.
//  Copyright (c) 2013 Johnny iDay. All rights reserved.
//

#import "SearchingViewController.h"
#import "SearchUsersViewController.h"
#import "SearchTagsViewController.h"

#import "DataManagement.h"


@interface SearchingViewController () {
    NSMutableArray *_objects;
    CGRect containerFrame;
}

@property(nonatomic, strong) SearchUsersViewController   *m_usersViewController;
@property(nonatomic, strong) SearchTagsViewController    *m_tagsViewController;
@end

@implementation SearchingViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.m_searchKey = @"";
    
    InstagramUser *user = [[DataManagement sharedClient] user];
    self.user = user;

    
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
    self.navigationItem.titleView = self.searchBar;
    
//    self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    self.segmentedControl.tintColor = [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0];
    
    [self.segmentedControl setFrame:CGRectMake(_segmentedControl.frame.origin.x,
                                               _segmentedControl.frame.origin.y,
                                               self.view.bounds.size.width / 2,
                                               _segmentedControl.frame.size.height)];
    self.segmentedControl.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0];
    
    [self.segmentedControl removeAllSegments];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlSelected:) forControlEvents:UIControlEventValueChanged];
    
    self.segmentView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0];

    
    self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.segmentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.segmentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.segmentView attribute:NSLayoutAttributeHeight multiplier:1 constant:-14]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.segmentView attribute:NSLayoutAttributeWidth multiplier:1 constant:-16]];


    self.m_usersViewController = [[SearchUsersViewController alloc] initWithSearchkey:self.m_searchKey user:self.user];
    self.m_usersViewController.title = @"People";
    
    self.m_tagsViewController = [[SearchTagsViewController alloc] initWithSearchkey:self.m_searchKey user:self.user];
    self.m_tagsViewController.title = @"Hashtags";
    
    [self setViewControllers:@[self.m_usersViewController,
                               self.m_tagsViewController]
    ];
    
    [self setSelectedViewControllerIndex:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%@", @"viewDidAppear here.");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshSubViewController:(id)sender
{
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    containerFrame = _viewContainer.frame;
    for (UIViewController *childViewController in self.childViewControllers) {
        childViewController.view.frame = (CGRect){0,0,containerFrame.size};
    }
}


- (void)setViewContainer:(UIView *)viewContainer
{
    _viewContainer = viewContainer;
    containerFrame = _viewContainer.frame;
}

- (void)setViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles
{
    if ([_segmentedControl numberOfSegments] > 0) {
        return;
    }
    for (int i = 0; i < [viewControllers count]; i++) {
        [self pushViewController:viewControllers[i] title:titles[i]];
    }
    [_segmentedControl setSelectedSegmentIndex:0];
    self.selectedViewControllerIndex = 0;
}

- (void)setViewControllers:(NSArray *)viewControllers imagesNamed:(NSArray *)imageNames {
    if ([_segmentedControl numberOfSegments] > 0) {
        return;
    }
    for (int i = 0; i < [viewControllers count]; i++) {
        [self pushViewController:viewControllers[i] imageNamed:imageNames[i]];
    }
    [_segmentedControl setSelectedSegmentIndex:0];
    self.selectedViewControllerIndex = 0;
}

- (void)setViewControllers:(NSArray *)viewControllers images:(NSArray *)images {
    if ([_segmentedControl numberOfSegments] > 0) {
        return;
    }
    for (int i = 0; i < [viewControllers count]; i++) {
        [self pushViewController:viewControllers[i] image:images[i]];
    }
    [_segmentedControl setSelectedSegmentIndex:0];
    self.selectedViewControllerIndex = 0;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
//    if ([_segmentedControl numberOfSegments] > 0) {
//        return;
//    }
    for (int i = 0; i < [viewControllers count]; i++) {
        [self pushViewController:viewControllers[i] title:[viewControllers[i] title]];
    }
    [_segmentedControl setSelectedSegmentIndex:0];
    self.selectedViewControllerIndex = 0;
}

- (void)pushViewController:(UIViewController *)viewController
{
    [self pushViewController:viewController title:viewController.title];
}
- (void)pushViewController:(UIViewController *)viewController title:(NSString *)title
{
    [_segmentedControl insertSegmentWithTitle:title atIndex:_segmentedControl.numberOfSegments animated:NO];
    [self addChildViewController:viewController];
    [_segmentedControl sizeToFit];
}

- (void)pushViewController:(UIViewController *)viewController imageNamed:(NSString *)imageName
{
    [_segmentedControl insertSegmentWithImage:[UIImage imageNamed:imageName] atIndex:_segmentedControl.numberOfSegments animated:NO];
    [self addChildViewController:viewController];
    [_segmentedControl sizeToFit];
}

- (void)pushViewController:(UIViewController *)viewController image:(UIImage *)image {
    [_segmentedControl insertSegmentWithImage:image atIndex:_segmentedControl.numberOfSegments animated:NO];
    [self addChildViewController:viewController];
    [_segmentedControl sizeToFit];
}

- (void)segmentedControlSelected:(id)sender
{
    self.selectedViewControllerIndex = _segmentedControl.selectedSegmentIndex;
}

- (void)selectViewController:(NSInteger)index
{
    _selectedViewController = self.childViewControllers[index];
    [_selectedViewController didMoveToParentViewController:self];
    if (_selectedViewController.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem = _selectedViewController.navigationItem.rightBarButtonItem;
    }
    if (_selectedViewController.navigationItem.leftBarButtonItem) {
        self.navigationItem.leftBarButtonItem = _selectedViewController.navigationItem.leftBarButtonItem;
    }
    _selectedViewControllerIndex = index;
}

- (void)setSelectedViewControllerIndex:(NSInteger)index
{
    if (!_selectedViewController) {
        [self selectViewController:index];
        [_viewContainer addSubview:[_selectedViewController view]];
    } else if (index != _selectedViewControllerIndex) {
        [self transitionFromViewController:_selectedViewController toViewController:self.childViewControllers[index] duration:0.0f options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
            [self selectViewController:index];
        }];
    }
    
    [_segmentedControl setSelectedSegmentIndex:index];
    
    /////
    if (_segmentedControl.selectedSegmentIndex == 0) {
        self.m_usersViewController.searchKey = self.m_searchKey;
        [self.m_usersViewController loadUsers:NO];
    }
    if (_segmentedControl.selectedSegmentIndex == 1) {
        self.m_tagsViewController.searchKey = self.m_searchKey;
        [self.m_tagsViewController loadTags:NO];
    }

}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    //NSLog(@"searchBar ... text.length: %d", text.length);
    
    if(text.length == 0)
    {
        [searchBar resignFirstResponder];
        self.m_searchKey = @"";
        
        if (_segmentedControl.selectedSegmentIndex == 0) {
            self.m_usersViewController.searchKey = @"";
            [self.m_usersViewController loadUsers:NO];
        }
        if (_segmentedControl.selectedSegmentIndex == 1) {
            self.m_tagsViewController.searchKey = @"";
            [self.m_tagsViewController loadTags:NO];
        }

    }
    else
    {
        self.m_searchKey = text;
        if (_segmentedControl.selectedSegmentIndex == 0) {
            self.m_usersViewController.searchKey = text;
            [self.m_usersViewController loadUsers:NO];
        }
        if (_segmentedControl.selectedSegmentIndex == 1) {
            self.m_tagsViewController.searchKey = text;
            [self.m_tagsViewController loadTags:NO];
        }
        
    }//end if-else
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //User hit Search button on Keyboard
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text=@"";
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    self.m_searchKey = @"";
    if (_segmentedControl.selectedSegmentIndex == 0) {
        self.m_usersViewController.searchKey = @"";
        [self.m_usersViewController loadUsers:NO];
    }
    if (_segmentedControl.selectedSegmentIndex == 1) {
        self.m_tagsViewController.searchKey = @"";
        [self.m_tagsViewController loadTags:NO];
    }

    
}


@end
