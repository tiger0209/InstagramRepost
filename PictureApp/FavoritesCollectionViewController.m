//
//  CollectionViewController.m
//  ARSegmentPager
//
//  Created by August on 15/3/28.
//  Copyright (c) 2015 August. All rights reserved.
//

#import "FavoritesCollectionViewController.h"

// Data management
#import "DataManagement.h"

// Collection view
#import "ProfileHeaderView.h"
#import "ActivityIndicatorFooterView.h"
#import "MediaCell.h"

// Networking
#import "InstagramClient.h"
//#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "InstafollowersClient.h"

#import "MediaViewController.h"

// Collection cell constants
NSString *ProfileMediaCellIdentifier4 = @"ProfileMediaCellIdentifier4";
NSString *HeaderIdentifier4           = @"HeaderIdentifier4";
NSString *FooterIdentifier4           = @"FooterIdentifier4";

@interface FavoritesCollectionViewController ()

// User
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) InstagramUser *user;

// Media items arrays for the users items
// that are returned from Instagram API
@property (strong, nonatomic) NSMutableArray *mediaIdentifiers;


// Next max identifier is used to paginate
// through the users media items
@property (strong, nonatomic) NSString *nextMaxIdentifier;

// BOOL values used to decide when to
// make requests and when to not
@property (nonatomic) BOOL requestsDone;
@property (nonatomic) BOOL requestsLoading;

//// Collection view header property
//@property (strong, nonatomic) ProfileHeaderView *headerView;

// Relationship for follow button and relationship label
@property (nonatomic) Relationship outgoingRelationship;
@property (nonatomic) Relationship incomingRelationship;

@end

@implementation FavoritesCollectionViewController
{
    BOOL isRunning;
}

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    
    InstagramUser *user = [[DataManagement sharedClient] user];
    self.user = user;
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
    // Set collection view properties
    self.collectionView.delegate   = self;
    self.collectionView.dataSource = self;
    
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setMinimumInteritemSpacing:0.0];
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setMinimumLineSpacing:0.0];
    
    // Register collection views
    [self.collectionView registerClass:[ProfileHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:HeaderIdentifier4];
    [self.collectionView registerClass:[ActivityIndicatorFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:FooterIdentifier4];
    [self.collectionView registerClass:[MediaCell class]
            forCellWithReuseIdentifier:ProfileMediaCellIdentifier4];
    
    [self.view addSubview:self.collectionView];
    
    // Ensure the header view has been intialized by reloading the collection view
    [self.collectionView reloadData];
    
    // Initialize media items object and load media
    self.mediaIdentifiers = [[NSMutableArray alloc] init];
    
    //[self loadFavorites];
    
}

- (void) loadFavorites
{
    self.mediaIdentifiers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyFavoritesIdentifierArray]];
    
    [self.collectionView reloadData];
}

- (void)refresh
{
    self.mediaIdentifiers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyFavoritesIdentifierArray]];
    
    [self.collectionView reloadData];
}


- (void)dealloc
{
    ////
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data management


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // If there has been a previous failure, do not attempt load
    if(self.requestsDone || self.requestsLoading)
        return;
    
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    // Request load if within 5 table view cell heights
    if ((maximumOffset - currentOffset) <= TableViewCellInset * 5.0) {
        //[self refresh];
    }
}


#pragma mark - BOOL setters

- (void)setRequestsLoading:(BOOL)requestsLoading
{
    _requestsLoading = requestsLoading;
    
    [self.collectionView reloadData];
}

-(NSString *)segmentTitle
{
    return @"Favorites";
}

-(void)requestingRefresh
{
    [self refresh];
}

-(void)requestingLoadMedia
{
//    self.requestsDone = NO;
//
//    [self refresh];
}


-(UIScrollView *)streachScrollView
{
    return self.collectionView;
}



#pragma mark - Collection view datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.mediaIdentifiers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ProfileMediaCellIdentifier4 forIndexPath:indexPath];
    
    // Media setup
    NSString *identifier = self.mediaIdentifiers[indexPath.row];
    
    // Request media item
    [[InstagramClient sharedClient] getMediaItemForIdentifier:identifier completion:^(BOOL success, InstagramMedia *mediaItem) {
        
        if(success) {
            // Media image
            [cell.imageView sd_setImageWithURL:mediaItem.thumbnailURL placeholderImage:[UIImage new]];
        }else{
            ///////
            
        }
    }];
    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize collectionViewHeaderSize = CGSizeMake(0, 0);
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
    CGSize boundsSize = self.view.bounds.size;
    
    CGFloat itemSizeWidthHeight = floorf(boundsSize.width/3.0);
    
    return CGSizeMake(itemSizeWidthHeight, itemSizeWidthHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Media
    NSString *identifier = self.mediaIdentifiers[indexPath.row];
    // View Controller
    MediaViewController *viewController = [[MediaViewController alloc] initWithMediaIdentifier:identifier
                                           ];
    // Push View Controller
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
