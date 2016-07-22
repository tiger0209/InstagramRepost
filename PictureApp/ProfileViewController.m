//
//  ProfileViewController.m
//  Instafollowers
//
//  Created by Michael Orcutt on 2/26/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "ProfileViewController.h"

// View Controllers
#import "MediaViewController.h"
#import "UsersViewController.h"
//#import "ChattingVC.h"
//#import "ChattingListVC.h"

// Collection view
#import "ProfileHeaderView.h"
#import "ActivityIndicatorFooterView.h"
#import "MediaCell.h"
#import "PrivateCell.h"

// Data management
#import "DataManagement.h"

// Networking
#import "InstagramClient.h"
//#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "InstafollowersClient.h"

// Categories
#import "UIColor+String.h"

//#import "InAppPurchaseManager.h"

#import "InstafollowersClient.h"
#import "InstafollowersSession.h"


// Collection cell constants
NSString *ProfileMediaCellIdentifier = @"ProfileMediaCellIdentifier";
NSString *PrivateCellIdentifier      = @"PrivateCellIdentifier";
NSString *HeaderIdentifier           = @"HeaderIdentifier";
NSString *FooterIdentifier           = @"FooterIdentifier";

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UserViewDelegate>

// User
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) InstagramUser *user;

// Media items arrays for the users items
// that are returned from Instagram API
@property (strong, nonatomic) NSMutableArray *mediaItems;

// Next max identifier is used to paginate
// through the users media items
@property (strong, nonatomic) NSString *nextMaxIdentifier;

// BOOL values used to decide when to
// make requests and when to not
@property (nonatomic) BOOL requestsDone;
@property (nonatomic) BOOL requestsLoading;

// Collection view header property
@property (strong, nonatomic) ProfileHeaderView *headerView;

// Relationship for follow button and relationship label
@property (nonatomic) Relationship outgoingRelationship;
@property (nonatomic) Relationship incomingRelationship;

// BOOL private value
@property (nonatomic) BOOL private;

//// Chatting Button
//@property (strong, nonatomic) UIButton *chatButton;

@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation ProfileViewController
{
    BOOL isRunning;
}

#pragma mark - Initialize

- (id)initWithUser:(InstagramUser *)user
{
    self = [super init];
    if (self) {
        
        // Set user
        self.user = user;
        
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        
        self.collectionView                        = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
        self.collectionView.backgroundColor        = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0];
        self.collectionView.alwaysBounceVertical   = YES;

        
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Title
    self.title = self.user.username;

    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];

    // Add right bar button item, to open in instagram app
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Export"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(rightBarButtonItemTapped:)];
    
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem animated:YES];

    // Set collection view properties
    self.collectionView.delegate   = self;
    self.collectionView.dataSource = self;
    
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setMinimumInteritemSpacing:0.0];
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setMinimumLineSpacing:0.0];
    
    // Register collection views
    [self.collectionView registerClass:[ProfileHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:HeaderIdentifier];
    [self.collectionView registerClass:[ActivityIndicatorFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:FooterIdentifier];
    [self.collectionView registerClass:[MediaCell class]
            forCellWithReuseIdentifier:ProfileMediaCellIdentifier];
    [self.collectionView registerClass:[PrivateCell class]
            forCellWithReuseIdentifier:PrivateCellIdentifier];
    
    [self.view addSubview:self.collectionView];
    
    // Ensure the header view has been intialized by reloading the collection view
    [self.collectionView reloadData];
    
    // Initialize media items object and load media
    self.mediaItems = [[NSMutableArray alloc] init];
    
    [self loadMedia];
    [self loadUser];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(newMessageArrived:)
//                                                 name:kNewMessageArrivedNotification
//                                               object:nil];
}

- (void)loadView
{
    [super loadView];
    
    // Add table view
    [self.view addSubview:self.collectionView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.collectionView.frame = bounds;
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewMessageArrivedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.topItem.title = self.user.username;
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data management

- (void)loadMedia
{
    // If all requests are done or a request
    // is currently loading, return
    if(self.requestsDone || self.requestsLoading)
        return;
    
    // Set requests loading to yes
    self.requestsLoading = YES;
    
    [[InstagramClient sharedClient] getUserMediaForIdentifier:self.user.identifier
                                                maxIdentifier:self.nextMaxIdentifier
                                                   completion:^(BOOL success, NSArray *mediaItems, NSString *nextMaxIdentifier)
    {
        if(success) {
            
            // Add media items to media
            // items array
            
            ////lgilgilgi
            [self.mediaItems removeAllObjects];
            //////

            [self.mediaItems addObjectsFromArray:mediaItems];
            
            // If there is no next max identifier
            // mark requests as done
            if(nextMaxIdentifier.length == 0) {
                // Set the requests as done
                self.requestsDone = YES;
            } else {
                // Set next max identifier
                self.nextMaxIdentifier = nextMaxIdentifier;
            }
            
            // Mark requests no longer loading
            self.requestsLoading = NO;

        } else {
         
            // Mark request failure
            self.requestsDone = YES;
            
            // Mark requests no longer loading
            self.requestsLoading = NO;
            [self.collectionView reloadData];

        }

    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // If there has been a previous failure, do not attempt load
    if(self.requestsDone || self.requestsLoading)
        return;
    
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    // Request load if within 5 table view cell heights
    if ((maximumOffset - currentOffset) <= TableViewCellInset * 5.0) {
        [self loadMedia];
    }
}

- (void)loadUser
{
    // Reload user, the user model could be missing information
    [[InstagramClient sharedClient] getUserForIdentifier:self.user.identifier completion:^(BOOL success, InstagramUser *user) {

        if(success) {
            // Reset the user
            self.user = user;
            
            // Reset the user view
            self.headerView.userView.user = self.user;
            
        }
        
    }];
    
    // Relationship statuses for the header follow button and relationship label
    if([[[DataManagement sharedClient] user].identifier isEqualToString:self.user.identifier]) {
        
        // This user is the logged in user
        self.incomingRelationship = RelationshipSelf;
        self.outgoingRelationship = RelationshipSelf;
        
    } else {
        
        [[InstagramClient sharedClient] getRelationshipForUserIdentifier:self.user.identifier
                                                              completion:^(BOOL success,
                                                                           Relationship outgoingRelationship,
                                                                           Relationship incomingRelationship,
                                                                           BOOL private)
        {
            
            if(success) {
                // Set relationships
                self.incomingRelationship = incomingRelationship;
                self.outgoingRelationship = outgoingRelationship;
                
                // If private and not following, add to view
                if(private && outgoingRelationship == RelationshipNotFollowingPrivate) {

                    // Set private
                    self.private = YES;

                    [self.collectionView reloadData]; 
                    
                }
                
            } else {
                // Set relationship status to unknown
                self.outgoingRelationship = RelationshipUnknown;
                self.incomingRelationship = RelationshipUnknown;
            }
            
            // Set on header view
            self.headerView.outgoingRelationship = outgoingRelationship;
            self.headerView.incomingRelationship = incomingRelationship;

            
        }];
        
    }
}

#pragma mark - BOOL setters

- (void)setRequestsLoading:(BOOL)requestsLoading
{
    _requestsLoading = requestsLoading;
    
    [self.collectionView reloadData];
}

#pragma mark - Collection view datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.private == NO) {
        return self.mediaItems.count;
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.private == NO) {
        MediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ProfileMediaCellIdentifier forIndexPath:indexPath];
        
        // Media setup
        InstagramMedia *media = self.mediaItems[indexPath.row];
        
        // Media image
        //[cell.imageView setImageWithURL:media.thumbnailURL placeholderImage:[UIImage new]];
        [cell.imageView sd_setImageWithURL:media.thumbnailURL placeholderImage:[UIImage new]];
        
        return cell;
    } else {
        PrivateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PrivateCellIdentifier forIndexPath:indexPath];
        
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if(kind == UICollectionElementKindSectionHeader) {
        
        self.headerView
        = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                             withReuseIdentifier:HeaderIdentifier
                                                    forIndexPath:indexPath];
        
        // Weak self for block
        __unsafe_unretained typeof(self) weakSelf = self;
        
        // Follow button block
        self.headerView.followButtonTapBlock = ^{
            
            // Stop interaction on button
            weakSelf.headerView.followButton.alpha                  = .50;
            weakSelf.headerView.followButton.userInteractionEnabled = NO;
            
            // Return if not followable or unfollowable
            if(weakSelf.outgoingRelationship == RelationshipSelf
            || weakSelf.outgoingRelationship == RelationshipNotLoaded
            || weakSelf.outgoingRelationship == RelationshipUnknown) {
                return;
            }
            
            // Action for relationship change
            NSString *action;
            if(weakSelf.outgoingRelationship == RelationshipFollowing || weakSelf.outgoingRelationship == RelationshipRequested) {
                action = @"unfollow";
            } else if(weakSelf.outgoingRelationship == RelationshipNotFollowing || weakSelf.outgoingRelationship == RelationshipNotFollowingPrivate) {
                action = @"follow";
            }
            
            // Make request
            [[InstafollowersClient sharedClient] postRelationshipChangeForUserIdentifier:weakSelf.user.identifier
                                                                                  action:action
                                                                              completion:^(BOOL success, Relationship outgoingRelationship, NSString *errorMessage)
             {
                 
                 // If success, update view
                 if(success) {
                     weakSelf.outgoingRelationship            = outgoingRelationship;
                     weakSelf.headerView.outgoingRelationship = outgoingRelationship;
                 }
                 
                 // If there is an error, show the messsage in an alert view
                 if(errorMessage) {
                     UIAlertView *alertView
                     = [[UIAlertView alloc] initWithTitle:@"Error"
                                                  message:errorMessage
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
                     [alertView show];
                 }
                 
                 // Reset interaction on button
                 weakSelf.headerView.followButton.userInteractionEnabled = YES;
                 weakSelf.headerView.followButton.alpha                  = 1.0;
                 
             }];
        };
        
        // Set header view properties
        self.headerView.userView.delegate    = self;
        self.headerView.userView.user        = self.user;
        self.headerView.outgoingRelationship = self.outgoingRelationship;
        self.headerView.incomingRelationship = self.incomingRelationship;
        
        return self.headerView;
        
    } else {
        
        // Footer view with activity indicator
        ActivityIndicatorFooterView *footerView
        = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                             withReuseIdentifier:FooterIdentifier
                                                    forIndexPath:indexPath];
        
        [footerView.activityIndicator startAnimating];
        
        return footerView;
        
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    // Size setup
    CGSize boundsSize = self.view.bounds.size;
    
    CGSize collectionViewHeaderSize;
    collectionViewHeaderSize.width = self.view.bounds.size.width;
    
    // Add profile picture height and offset height
    collectionViewHeaderSize.height += UserProfileImageSize;
    collectionViewHeaderSize.height += VerticalSpacing;
    
    // Add text label text plus vertical spacing between
    // profile picture and text label
    collectionViewHeaderSize.height += (VerticalSpacing / 2.0);
    collectionViewHeaderSize.height += [self.user.username sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Ubuntu-Light" size:17.0] }].height;
    
    // Add height detail text label
    CGSize detailTextLabelMaxSize = CGSizeMake((boundsSize.width - TableViewCellInset * 2.0), CGFLOAT_MAX);
    
    collectionViewHeaderSize.height
    += [self.user.bio boundingRectWithSize:detailTextLabelMaxSize
                                   options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Ubuntu-Light" size:16.0] }
                                   context:nil].size.height;

    if(![[[DataManagement sharedClient] user].identifier isEqualToString:self.user.identifier]) {
        
        // Follow button
        collectionViewHeaderSize.height += RoundedButtonHeight;
        collectionViewHeaderSize.height += (VerticalSpacing / 2.0);
        collectionViewHeaderSize.height += VerticalSpacing;
        
        // Relationship label
        collectionViewHeaderSize.height += (VerticalSpacing / 2.0);
        collectionViewHeaderSize.height +=
        [@"Follows you" sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Ubuntu-Light" size:16.0] }].height;

    } else {
     
        collectionViewHeaderSize.height += VerticalSpacing;

    }
    
    return collectionViewHeaderSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGFloat height;
    
    if(self.requestsLoading) {
        height = 100.0;
    } else {
        height = 0.0;
    }
    
    return CGSizeMake(self.view.bounds.size.width, height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.private == NO) {
        CGSize boundsSize = self.view.bounds.size;
        
        CGFloat itemSizeWidthHeight = floorf(boundsSize.width/3.0);
        
        return CGSizeMake(itemSizeWidthHeight, itemSizeWidthHeight);
    } else {
        return CGSizeMake(self.view.bounds.size.width, 180.0);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.private == YES) {
        return;
    }
    
    // Media
    InstagramMedia *media = self.mediaItems[indexPath.row];
    
    // View Controller
    MediaViewController *viewController = [[MediaViewController alloc] initWithMediaIdentifier:media.identifier
                                           ];

    // Push View Controller
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - User view delegate

- (void)followersLabelWasTapped
{
    // View controller
    UsersViewController *viewController = [[UsersViewController alloc] initWithSelection:SelectionFollowers
                                                                                    user:self.user];
    
    // Push view controller
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)followingLabelWasTapped
{ 
    // View controller
    UsersViewController *viewController = [[UsersViewController alloc] initWithSelection:SelectionFollowing
                                                                                    user:self.user];
    
    // Push view controller
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Bar button methods

- (void)rightBarButtonItemTapped:(id)sender
{
    ///lgilgilgi
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@", self.user.username]];
//    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://camera"]];
    
    if([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instagram"
                                                        message:@"Could not open profile in Instagram. Make sure you have the Instagram app installed."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


@end
