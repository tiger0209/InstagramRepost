//
//  UsersViewController.m
//  Instafollowers
//
//  Created by Michael Orcutt on 2/20/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "SearchUsersViewController.h"

// Data management
#import "DataManagement.h"

// Table
#import "UserCell.h"
#import "GroupedTableHeader.h"

// Networking
#import "InstagramClient.h"
//#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"

// Categories
#import "NSDate+TimeAgo.h"
#import "MOMessageIconView.h"

#import "ProfileViewController.h"

#import <QuartzCore/QuartzCore.h>



@interface SearchUsersViewController () <UITableViewDataSource, UITableViewDelegate>


// User required for certain selections
@property (strong, nonatomic) InstagramUser *user;

// Users
@property (strong, nonatomic) NSMutableArray *users;

// BOOL values
@property (nonatomic) BOOL requestsDone;
@property (nonatomic) BOOL requestsLoading;

// Cursor for pagination
@property (strong, nonatomic) NSString *cursor;

@property (strong, nonatomic) UITableView *tableView;

// Activity indicator to display when initially loading content
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

// Message icon view to display messages
@property (strong, nonatomic) MOMessageIconView *messageIconView;

@end

@implementation SearchUsersViewController

#pragma mark - Initialize

- (id)initWithSearchkey:(NSString*)searchKey
{
    self = [self init];
    if (self) {
        
        self.searchKey = searchKey;
        
        UITableViewStyle tableViewStyle;
        tableViewStyle = UITableViewStyleGrouped;
        self.tableView                 = [[UITableView alloc] initWithFrame:CGRectZero style:tableViewStyle];
        self.tableView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0];
        self.tableView.separatorColor  = [UIColor colorWithRed:224.0/255.0 green:226.0/255.0 blue:229.0/255.0 alpha:1.0];
        
        
        UIEdgeInsets contentInset;
        UIEdgeInsets scrollIndicatorInsets;
        
        contentInset          = UIEdgeInsetsMake(0.0, 0.0, UITabBarHeight, 0.0);
        scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, UITabBarHeight, 0.0);
        
        self.tableView.contentInset          = contentInset;
        self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
    }
    return self;
}

- (id)initWithSearchkey:(NSString*)searchKey user:(InstagramUser *)user
{
    self = [self init];
    if (self) {
        
        // Set user
        self.user = user;
        self.searchKey = searchKey;
        
        UITableViewStyle tableViewStyle;
        tableViewStyle = UITableViewStyleGrouped;
        self.tableView                 = [[UITableView alloc] initWithFrame:CGRectZero style:tableViewStyle];
        self.tableView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0];
        self.tableView.separatorColor  = [UIColor colorWithRed:224.0/255.0 green:226.0/255.0 blue:229.0/255.0 alpha:1.0];

        self.tableView.layer.masksToBounds = YES;
        self.tableView.layer.borderWidth = 1;
        self.tableView.layer.borderColor = [[UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0] CGColor];
        
        UIEdgeInsets contentInset;
        UIEdgeInsets scrollIndicatorInsets;
        
        contentInset          = UIEdgeInsetsMake(0.0, 0.0, UITabBarHeight, 0.0);
        scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, UITabBarHeight, 0.0);
        
        self.tableView.contentInset          = contentInset;
        self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];

    [self.view setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0]];

    // Set table view data source and delegate
    self.tableView.dataSource            = self;
    self.tableView.delegate              = self;
    self.tableView.alpha                 = 0.0;
    self.tableView.separatorInset        = UIEdgeInsetsMake(0.0, (TableViewCellInset + UserTableCellProfileImageSize + TextHorizontalSpacing), 0.0, 0.0);
    
    // Load the users
    //[self loadUsers];
    
}

- (void)loadView
{
    [super loadView];
    
    // Add table view
    [self.view addSubview:self.tableView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.tableView.frame = bounds;
}

- (void)loadUsers:(BOOL) forScroll
{
    // No more requests to
    // be made, return
    /////lgilgilgi
//   if(self.requestsDone || self.requestsLoading)
//       return;
    
   // Mark requests loading
   self.requestsLoading = YES;
        
   // If this is the first time
   // requesting users add
   // an activity indicator view
   if(self.users.count == 0) {
        CGRect activityIndicatorFrame       = self.view.bounds;
        activityIndicatorFrame.size.height -= (UITabBarHeight + UINavigationBarHeight);
            
        [self addActivityIndicatorViewWithFrame:activityIndicatorFrame animated:NO];
    }
        
    // Make request
    [[InstagramClient sharedClient] getUsersForSearching :self.searchKey
                                                      cursor:self.cursor
                                                  completion:^(BOOL success, NSArray *users, NSString *cursor)
        
    {

        // Add users to array
        
        ///lgilgilgi
//        if(!self.users) {
//            self.users = [NSMutableArray array];
//        }
//            
//        [self.users addObjectsFromArray:users];
        
        if(!self.users) {
            self.users = [NSMutableArray array];
        }
        if (!forScroll) {
            [self.users removeAllObjects];
        }
        
        [self.users addObjectsFromArray:users];

        
        // Cursor parsing
        if(cursor.length > 0) {
            self.cursor = cursor;
        } else {
            self.requestsDone = YES;
        }
            
        // Reload table
        [self.tableView reloadData];
            
        // Mark requests no longer loading
        self.requestsLoading = NO;
            
        // Ensure the activity indicator view
        // has been removed
        [self removeActivityIndicatorViewAnimated:YES];
        [self fadeInTableViewAnimated:YES];

    }];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 60)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Scroll view / pagination

- (void)scrollViewRequestsLoad
{
    // Initialize activity indicator
    UIActivityIndicatorView *activityIndicatorTableFooterView
    = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, UserTableCellProfileImageSize)];
    activityIndicatorTableFooterView.color
    = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0];
    [activityIndicatorTableFooterView startAnimating];
    
    // Set activity indicator as table footer view
    self.tableView.tableFooterView = activityIndicatorTableFooterView;
    
    // Load more users
    [self loadUsers:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if(self.requestsDone || self.requestsLoading)
        return;
    
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
    // Request load if within 100 pixels
    if ((maximumOffset - currentOffset) <= 100.0) {
        [self scrollViewRequestsLoad];
    }
        
}

- (void)setRequestsLoading:(BOOL)requestsLoading
{
    _requestsLoading = requestsLoading;
    
    if(_requestsLoading == NO) {
        
        // Remove the table footer
        self.tableView.tableFooterView = nil;
        
    }
}

#pragma mark - Table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        // There are no sections in other arrays
    return self.users.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    cell.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0];
    
    // Setup
    NSInteger row     = [indexPath row];
    
    // User based upon selection
    InstagramUser *user;
    user = self.users[row];
    
    // Text labels
    cell.textLabel.text       = user.username;
    cell.detailTextLabel.text = user.fullName;
    
    // Profile picture
    [cell.profilePictureContainerView.imageView sd_setImageWithURL:user.profilePictureURL];
    
    // User cell action
    
    ///lgilgilgi
    cell.profilePictureContainerView.actionBlock = ^(id sender){
        
        // Profile view controller
        ProfileViewController *profileViewController
        = [[ProfileViewController alloc] initWithUser:user];
        
        // Push view controller
        [self.navigationController pushViewController:profileViewController animated:YES];

    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (UserTableCellProfileImageSize + VerticalSpacing / 2.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return (VerticalSpacing / 4.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    return (VerticalSpacing / 4.0);
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Deselect
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Profile view controller
    InstagramUser *user;
    user = self.users[indexPath.row];
    ProfileViewController *profileViewController
    = [[ProfileViewController alloc] initWithUser:user];
    
    // Push view controller
    [self.navigationController pushViewController:profileViewController animated:YES];

    
}

#pragma mark - Activity Indicator View methods

- (void)addActivityIndicatorViewWithFrame:(CGRect)frame
                                 animated:(BOOL)animated
{
    // Create activity indicator
    if(!self.activityIndicator) {
        self.activityIndicator                 = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.color           = [UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.00];
        self.activityIndicator.backgroundColor = self.view.backgroundColor;
        self.activityIndicator.frame           = frame;
    }
    
    // If activity indicator is not
    // animating, start animating
    if(!self.activityIndicator.isAnimating) {
        [self.activityIndicator startAnimating];
    }
    
    // Fade in
    if(animated) {
        self.activityIndicator.alpha = 0.0;
        
        [self.view addSubview:self.activityIndicator];
        
        [UIView animateWithDuration:.35 animations:^{
            self.activityIndicator.alpha = 1.0;
        }];
    } else {
        [self.view addSubview:self.activityIndicator];
    }
}

- (void)removeActivityIndicatorViewAnimated:(BOOL)animated
{
    if(animated) {
        [UIView animateWithDuration:.35 animations:^{
            self.activityIndicator.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.activityIndicator removeFromSuperview];
            self.activityIndicator = nil;
        }];
    } else {
        [self.activityIndicator removeFromSuperview];
        //self.activityIndicator = nil;
    }
}

#pragma mark - Message Icon View methods

- (void)addMessageIconViewToView:(UIView *)view
                           frame:(CGRect)frame
                            icon:(UIImage *)icon
                            text:(NSString *)text
                      detailText:(NSString *)detailText
                        animated:(BOOL)animated
{
    MOMessageIconViewLayout layout;
    if(detailText) {
        layout = MOMessageIconViewLayoutSubtitle;
    } else {
        layout = MOMessageIconViewLayoutDefault;
    }
    
    if(!self.messageIconView) {
        self.messageIconView       = [[MOMessageIconView alloc] initWithFrame:frame layout:layout];
        self.messageIconView.alpha = 0.0;
        
        [view addSubview:self.messageIconView];
    } else {
        self.messageIconView.layout = layout;
    }
    
    self.messageIconView.backgroundColor      = self.view.backgroundColor;
    self.messageIconView.textLabel.text       = text;
    self.messageIconView.detailTextLabel.text = detailText;
    self.messageIconView.imageView.image      = icon;
    
    if(animated) {
        [UIView animateWithDuration:.35 animations:^{
            self.messageIconView.alpha = 1.0;
        }];
    } else {
        self.messageIconView.alpha = 1.0;
    }
}

- (void)addMessageIconViewToView:(UIView *)view
                           frame:(CGRect)frame
                            icon:(UIImage *)icon
                            text:(NSString *)text
                      detailText:(NSString *)detailText
                        animated:(BOOL)animated
                          action:(void (^)(void))actionBlock
{
    // Add message icon view
    [self addMessageIconViewToView:view
                             frame:frame
                              icon:icon
                              text:text
                        detailText:detailText
                          animated:animated];
    
    // Add tap gesture
    self.messageIconView.tapEnabled = YES;
    
    // Use tap block to return action block
    self.messageIconView.tapBlock = ^{
        if(actionBlock) {
            actionBlock();
        }
    };
}

- (void)addMessageIconViewToView:(UIView *)view
                    belowSubview:(UIView *)subview
                           frame:(CGRect)frame
                            icon:(UIImage *)icon
                            text:(NSString *)text
                      detailText:(NSString *)detailText
                        animated:(BOOL)animated
{
    MOMessageIconViewLayout layout;
    if(detailText) {
        layout = MOMessageIconViewLayoutSubtitle;
    } else {
        layout = MOMessageIconViewLayoutDefault;
    }
    
    if(!self.messageIconView) {
        self.messageIconView       = [[MOMessageIconView alloc] initWithFrame:frame layout:layout];
        self.messageIconView.alpha = 0.0;
        
        [view insertSubview:self.messageIconView belowSubview:subview];
    } else {
        self.messageIconView.layout = layout;
    }
    
    self.messageIconView.backgroundColor      = self.view.backgroundColor;
    self.messageIconView.textLabel.text       = text;
    self.messageIconView.detailTextLabel.text = detailText;
    self.messageIconView.imageView.image      = icon;
    
    if(animated) {
        [UIView animateWithDuration:.35 animations:^{
            self.messageIconView.alpha = 1.0;
        }];
    } else {
        self.messageIconView.alpha = 1.0;
    }
}

- (void)removeMessageIconViewAnimated:(BOOL)animated
{
    if(!self.messageIconView) return;
    
    if(animated) {
        [UIView animateWithDuration:.35 animations:^{
            self.messageIconView.alpha = 0.0;
        }];
    } else {
        self.messageIconView.alpha = 0.0;
    }
}

#pragma mark - Table view methods

- (void)fadeInTableViewAnimated:(BOOL)animated
{
    if(self.tableView && self.tableView.alpha == 0.0) {
        
        if(animated) {
            [UIView animateWithDuration:.35 animations:^{
                self.tableView.alpha = 1.0;
            }];
        } else {
            self.tableView.alpha = 1.0;
        }
        
    }
}

- (void)fadeOutTableViewAnimated:(BOOL)animated
{
    if(self.tableView && self.tableView.alpha == 1.0) {
        
        if(animated) {
            [UIView animateWithDuration:.35 animations:^{
                self.tableView.alpha = 0.0;
            }];
        } else {
            self.tableView.alpha = 0.0;
        }
        
    }
}

-(NSString *)segmentTitle
{
    return @"Feed";
}


@end
