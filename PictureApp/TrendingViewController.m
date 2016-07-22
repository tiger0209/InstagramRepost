//
//  MasterViewController.m
//  FHSegmentedViewControllerDemo
//
//  Created by Johnny iDay on 13-12-29.
//  Copyright (c) 2013 Johnny iDay. All rights reserved.
//

#import "TrendingViewController.h"
#import "FeedCollectionViewController.h"
#import "MediaCollectionViewController.h"


@interface TrendingViewController () {
    NSMutableArray *_objects;
}
@end

@implementation TrendingViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.navigationController.navigationBar setTintColor:[UIColor grayColor]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshSubViewController:)];

    FeedCollectionViewController *collectionView1 = [[FeedCollectionViewController alloc] initWithNibName:@"FeedCollectionViewController" bundle:nil];
    collectionView1.title = @"Repost";
    MediaCollectionViewController *collectionView2 = [[MediaCollectionViewController alloc] initWithNibName:@"MediaCollectionViewController" bundle:nil];
    collectionView2.title = @"Users";
    
    [self setViewControllers:@[collectionView1,
                               collectionView2]
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

@end
