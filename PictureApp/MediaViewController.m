//
//  MediaViewController.m
//  InstagramLikes
//
//  Created by Michael Orcutt on 2/10/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "MediaViewController.h"

// Model
#import "InstagramMedia.h"
#import "InstagramComment.h"

// Table
#import "PhotoCell.h"
#import "IconCell.h"
#import "CommentAndLikesCell.h"
#import "UserAndRepostCell.h"
#import "CommentsCell.h"
#import "AllCommentsCell.h"

// Networking
#import "InstagramClient.h"
//#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"

#import "MOMessageIconView.h"

#import "ProfileViewController.h"

#import "AppDelegate.h"

#import "TagCollectionViewController.h"

#import "DataManagement.h"


#define FONT_SIZE 15.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 5.0f



@interface MediaViewController () <UITableViewDataSource, UITableViewDelegate>

// Identifier
@property (strong, nonatomic) NSString *mediaIdentifier;

// Media item
@property (strong, nonatomic) InstagramMedia *mediaItem;

// Activity indicator to display when initially loading content
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

// Message icon view to display messages
@property (strong, nonatomic) MOMessageIconView *messageIconView;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIImage *mediaImage;


@end

@implementation MediaViewController

#pragma mark - Init

- (id)initWithMediaIdentifier:(NSString *)mediaIdentifier
{
    self = [super init];
    if (self) {
        
        UITableViewStyle tableViewStyle;
        tableViewStyle = UITableViewStylePlain;
        
        self.tableView                 = [[UITableView alloc] initWithFrame:CGRectZero style:tableViewStyle];
        self.tableView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0];
        self.tableView.separatorColor  = [UIColor colorWithRed:224.0/255.0 green:226.0/255.0 blue:229.0/255.0 alpha:1.0];
        
        // Set media identifier
        self.mediaIdentifier = mediaIdentifier;
        
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];

    
    [self.view setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0]];
    // Title
    self.title = @"Photo";
    
    // Table
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    
    ////lgilgi
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 22.0;
    
    // Load media
    [self loadMedia];
}

- (void)loadView
{
    [super loadView];
    // Add table view
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"Photo";
    
    //////lgilgilgi
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 60)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.tableView.frame = bounds;
}

#pragma mark - Load

- (void)loadMedia
{
    // If there is a media identifier proceed
    if(self.mediaIdentifier) {
        
        // Add activity indicator
        CGRect activityIndicatorFrame       = self.view.bounds;
        
        activityIndicatorFrame.size.height -= (UINavigationBarHeight/* + UITabBarHeight*/);
        
        [self addActivityIndicatorViewWithFrame:activityIndicatorFrame animated:NO];
        
        // Request media item
        [[InstagramClient sharedClient] getMediaItemForIdentifier:self.mediaIdentifier completion:^(BOOL success, InstagramMedia *mediaItem) {

            if(success) {
                
                // Set the object
                self.mediaItem = mediaItem;
                
                // Reload the table
                [self.tableView reloadData];
                
                // Add right bar button item, to open in instagram app
                UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Export"]
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:self
                                                                                      action:@selector(rightBarButtonItemTapped:)];
                rightBarButtonItem.tintColor = [UIColor darkGrayColor];
                
                [self.navigationItem setRightBarButtonItem:rightBarButtonItem animated:YES];
                
            } else {
                
                // Show message view with error
                CGRect messageIconViewFrame = self.view.bounds;
                
                
                [self addMessageIconViewToView:self.view
                                         frame:messageIconViewFrame
                                          icon:[UIImage imageNamed:@"XMessageIcon"]
                                          text:@"Error loading media"
                                    detailText:nil
                                      animated:YES];

            }
            
            // Remove the activity indicator
            [self removeActivityIndicatorViewAnimated:YES];

        }];
    
    } else {
        
        // If there is not a media item, hide the table
        [self fadeOutTableViewAnimated:NO];
        
        // Remove activity indicator
        [self removeActivityIndicatorViewAnimated:NO];
        
        // Show message view with error
        CGRect messageIconViewFrame = self.view.bounds;
        
        [self addMessageIconViewToView:self.view
                                 frame:messageIconViewFrame
                                  icon:[UIImage imageNamed:@"XMessageIcon"]
                                  text:@"Error loading media"
                            detailText:nil
                              animated:YES];
        
    }
}

#pragma mark - Bar button methods

- (void)leftBarButtonItemTapped:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightBarButtonItemTapped:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Repost" otherButtonTitles: @"View in Instagram", @"Add To Favorites", @"Report As Offensive", nil];
    actionSheet.destructiveButtonIndex = 3;
    [actionSheet showInView:self.view];
}

// the delegate method to receive notifications is exactly the same as the one for UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Button at index: %ld clicked\nIts title is '%@'", (long)buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
    
    ///////Repost
    if (buttonIndex == 0) {
        
        UIImageWriteToSavedPhotosAlbum(self.mediaImage, nil, nil, nil);
        
        NSLog(@"Click Repost Btn");
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://camera"]];
        
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
    ///////View in instagram
    if (buttonIndex == 1) {
        
        NSLog(@"Click Repost Btn");
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://media?id=%@", self.mediaIdentifier]];
        
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
    //////Favorite
    if (buttonIndex == 2) {
        
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        NSMutableArray *array = [delegate.favoritesIdentifierArray mutableCopy];
        
        for (NSString *identifier in delegate.favoritesIdentifierArray) {
            if ([identifier isEqualToString:self.mediaItem.identifier]) {
                //////
                
            }else{
                //////
            }
        }
        
        [array addObject:self.mediaItem.identifier];
        [[NSUserDefaults standardUserDefaults] setObject:array forKey:UserDefaultsKeyFavoritesIdentifierArray];

    }
    ///////
    
}

// optional delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Will dismiss with button index %ld", (long)buttonIndex);
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Dismissed with button index %ld", (long)buttonIndex);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int commentCount = self.mediaItem.commentCount;
    if (commentCount <= 8) {
        return 2;
    }else{
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int commentCount = self.mediaItem.commentCount;
    if (commentCount <= 8) {
        if(section == 0) {
            return 1;
        } else if(section == 1){
            NSArray *commentData = self.mediaItem.commentData;
            return [commentData count] + 3;
        }

    }else{
        if(section == 0) {
            return 1;
        } else if(section == 1){
            NSArray *commentData = self.mediaItem.commentData;
            return [commentData count] + 3;
        }else{
            return 1;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row     = indexPath.row;

    if(section == 0) {
        
        static NSString *PhotoCellIdentifier = @"PhotoCell";
        
        PhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:PhotoCellIdentifier];
        if (cell == nil) {
            cell = [[PhotoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PhotoCellIdentifier];
        }
        
        // Weak pointers
        __weak UIImageView *weakPhotoImageView = cell.photoImageView;
        
        [weakPhotoImageView sd_setImageWithURL:self.mediaItem.standardURL placeholderImage:[UIImage new] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            CGFloat progress = ((CGFloat)receivedSize / (CGFloat)expectedSize);
            [cell.progressView setProgress:progress animated:YES];
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //[weakPhotoImageView setImage:image];
            ////lgilgilgi
            self.mediaImage = image;
        }];
        
        return cell;
        
    }
    else if(section == 1)
    {
        if(row == 0)
        {
            static NSString *CellIdentifier = @"CellIdentifier1";
            UserAndRepostCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UserAndRepostCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }

            
            InstagramUser *user = self.mediaItem.user;
            
            // Profile picture
            [cell.userImageView sd_setImageWithURL:user.profilePictureURL size:CGSizeMake(cell.frame.size.height - 10.0f, cell.frame.size.height - 10.0f)];
            
            cell.userImageView.layer.masksToBounds = YES;
            cell.userImageView.layer.cornerRadius = (cell.frame.size.height - 10.0f) / 2.0f;
            cell.userNameLabel.text = user.username;
 
            [cell.userBtn addTarget:self action:@selector(onUserBtn:) forControlEvents:UIControlEventTouchUpInside];
            [cell.repostBtn addTarget:self action:@selector(onRepostBtn:) forControlEvents:UIControlEventTouchUpInside];
            [cell.likeBtn addTarget:self action:@selector(onLikeBtn:) forControlEvents:UIControlEventTouchUpInside];

            
            return cell;
            
        }
        else if(row == 1)
        {
            static NSString *CellIdentifier = @"CellIdentifier2";
            CommentAndLikesCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[CommentAndLikesCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }

            cell.likesImageView.image = [UIImage imageNamed:@"HeartGray"];
            
            NSInteger likeCount = self.mediaItem.likeCount;
            
            if(likeCount == 1) {
                cell.likesDescriptionLabel.text = @"1 like";
            } else {
                cell.likesDescriptionLabel.text = [NSString stringWithFormat:@"%li likes", (long)self.mediaItem.likeCount];
            }
            
            cell.commentImageView.image = [UIImage imageNamed:@"Comment"];
            
            NSInteger commentCount = self.mediaItem.commentCount;
            
            if(commentCount == 1) {
                cell.commentDescriptionLabel.text = @"1 comment";
            } else {
                cell.commentDescriptionLabel.text = [NSString stringWithFormat:@"%li comments", (long)self.mediaItem.commentCount];
            }
            
            return cell;
            
        }
        else if(row == 2)
        {
            static NSString *CellIdentifier = @"CellIdentifier3";
            CommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[CommentsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            
            NSString *caption = self.mediaItem.caption;
            InstagramUser *user = self.mediaItem.user;
            NSString *userName = user.username;
            
            
            NSString *prefix = @"@";
            UIColor *highlightColor = [UIColor whiteColor];
            UIFont *font = [UIFont boldSystemFontOfSize:FONT_SIZE];
            NSDictionary *highlightAttributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:highlightColor};
            NSMutableAttributedString *highlightedText = [[NSMutableAttributedString alloc] initWithString:prefix attributes:highlightAttributes];

            userName = [NSString stringWithFormat:@"%@ ", userName];
            
            highlightColor = [UIColor colorWithRed:16.0/255.0 green:98.0/255.0 blue:136.0/255.0 alpha:1.0];
            font = [UIFont boldSystemFontOfSize:FONT_SIZE];
            highlightAttributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:highlightColor};
            NSMutableAttributedString *highlightedText1 = [[NSMutableAttributedString alloc] initWithString:userName attributes:highlightAttributes];
            [highlightedText appendAttributedString:highlightedText1];
            
            caption = [NSString stringWithFormat:@"%@ ", caption];
            
            UIColor *normalColor = [UIColor grayColor];
            UIFont *font1 = [UIFont systemFontOfSize:FONT_SIZE];
            NSDictionary *normalAttributes = @{NSFontAttributeName:font1, NSForegroundColorAttributeName:normalColor};
            NSAttributedString *normalText = [[NSAttributedString alloc] initWithString:caption attributes:normalAttributes];
            [highlightedText appendAttributedString:normalText];
            
            
            cell.commentDescriptionLabel.attributedText = highlightedText;


            // Block to handle all our taps, we attach this to all the label's handlers
            KILinkTapHandler tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
                [self tappedLink:string cellForRowAtIndexPath:indexPath];
            };
            
            cell.commentDescriptionLabel.userHandleLinkTapHandler = tapHandler;
            cell.commentDescriptionLabel.urlLinkTapHandler = tapHandler;
            cell.commentDescriptionLabel.hashtagLinkTapHandler = tapHandler;
            
            return cell;

        }
        else
        {
            static NSString *CellIdentifier = @"CellIdentifier4";
            CommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[CommentsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            
            NSArray *commentData = self.mediaItem.commentData;
            InstagramComment *comment = [commentData objectAtIndex:indexPath.row - 3];
            NSString *commentText = [comment text];
            NSDictionary *from = [comment from];
            
            
            NSString *prefix = @"@";
            UIColor *highlightColor = [UIColor whiteColor];
            UIFont *font = [UIFont boldSystemFontOfSize:FONT_SIZE];
            NSDictionary *highlightAttributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:highlightColor};
            NSMutableAttributedString *highlightedText = [[NSMutableAttributedString alloc] initWithString:prefix attributes:highlightAttributes];

            
            NSString *name = [from valueForKey:@"username"];
            name = [NSString stringWithFormat:@"%@ ", name];
            
            highlightColor = [UIColor colorWithRed:16.0/255.0 green:98.0/255.0 blue:136.0/255.0 alpha:1.0];
            font = [UIFont boldSystemFontOfSize:FONT_SIZE];
            highlightAttributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:highlightColor};
            NSMutableAttributedString *highlightedText1 = [[NSMutableAttributedString alloc] initWithString:name attributes:highlightAttributes];
            [highlightedText appendAttributedString:highlightedText1];

            UIColor *normalColor = [UIColor grayColor];
            UIFont *font1 = [UIFont systemFontOfSize:FONT_SIZE];
            NSDictionary *normalAttributes = @{NSFontAttributeName:font1, NSForegroundColorAttributeName:normalColor};
            NSAttributedString *normalText = [[NSAttributedString alloc] initWithString:commentText attributes:normalAttributes];
            [highlightedText appendAttributedString:normalText];
            
            

            cell.commentDescriptionLabel.attributedText = highlightedText;
            
            
            // Block to handle all our taps, we attach this to all the label's handlers
            KILinkTapHandler tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
                [self tappedLink:string cellForRowAtIndexPath:indexPath];
            };
            
            cell.commentDescriptionLabel.userHandleLinkTapHandler = tapHandler;
            cell.commentDescriptionLabel.urlLinkTapHandler = tapHandler;
            cell.commentDescriptionLabel.hashtagLinkTapHandler = tapHandler;
            
            return cell;
        }
        return nil;
    }
    else
    {
        static NSString *CellIdentifier = @"CellIdentifier5";
        
        int commentCount = self.mediaItem.commentCount;
        
        AllCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[AllCommentsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
//        cell.allCommentViewLabel.text      = [NSString stringWithFormat:@"View all %d comments in instagram", commentCount];
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
//        cell.accessoryType = UITableViewCellAccessoryNone;
        
        [cell.allCommentBtn setTitle:[NSString stringWithFormat:@"View all %d comments in instagram", commentCount] forState:UIControlStateNormal];
        [cell.allCommentBtn addTarget:self action:@selector(ClickAllCommentBtn:) forControlEvents:UIControlEventTouchUpInside];

        return cell;

    }
}

- (void) ClickAllCommentBtn:(id) sender
{
    NSLog(@"--ClickAllCommentBtn--");
    NSString *identifier = self.mediaItem.identifier;
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://media?id=%@", identifier]];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row     = indexPath.row;
    if(indexPath.section == 0)
    {
        return 320.0;
    }
    else if(indexPath.section == 1)
    {
        //return 54.0;
        if (row == 0)
        {
            return 50.0;
        }
        else if(row == 1)
        {
            return 35.0;
        }
        else if(row == 2)
        {
            NSString *caption = self.mediaItem.caption;
            
            InstagramUser *user = self.mediaItem.user;
            NSString *userName = user.username;
            
            NSString *name_and_comment = [NSString stringWithFormat:@"%@ %@", userName, caption];
            
            NSString *text = name_and_comment;
            
            CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
            
            CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat height = MAX(size.height, 20.0f);
            
            return height + (CELL_CONTENT_MARGIN * 2);
        }
        else
        {
            NSArray *commentData = self.mediaItem.commentData;
            InstagramComment *comment = [commentData objectAtIndex:indexPath.row - 3];
            NSString *commentText = [comment text];
            NSDictionary *from = [comment from];
            
            NSString *name = [from valueForKey:@"username"];
            
            NSString *name_and_comment = [NSString stringWithFormat:@"%@ %@", name, commentText];
            
            NSString *text = name_and_comment;
            
            CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
            
            CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            
            
            CGFloat height = MAX(size.height, 20.0f);
            
            return height + (CELL_CONTENT_MARGIN * 2);

        }
    }
    else{
        return 50.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
    //return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //return TableViewCellInset;
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Deselect
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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

#pragma mark - Message Icon View methods

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


- (void)onUserBtn:(id)sender
{
    NSLog(@"Click User Btn");
    // Profile view controller
    ProfileViewController *profileViewController
    = [[ProfileViewController alloc] initWithUser:self.mediaItem.user];
    
    // Push view controller
    [self.navigationController pushViewController:profileViewController animated:YES];

}

- (void)onRepostBtn:(id)sender
{
    //////
    /////lgilgilgi 1024
 //   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum(self.mediaImage, nil, nil, nil);
        
        NSLog(@"Click Repost Btn");
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://camera"]];
        
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

//    });

}

- (void)onLikeBtn:(id)sender
{
    NSLog(@"Click Like Btn");
    if(self.mediaIdentifier) {
        
        // Add activity indicator
        CGRect activityIndicatorFrame       = self.view.bounds;
        
        activityIndicatorFrame.size.height -= (UINavigationBarHeight/* + UITabBarHeight*/);
        
        [self addActivityIndicatorViewWithFrame:activityIndicatorFrame animated:NO];

        NSString *accessToken = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKeyInstagramAccessToken]];

        // Request media item
        [[InstagramClient sharedClient] postLikeWithAccessToken:accessToken
                                                mediaIdentifier:self.mediaIdentifier
                                                     completion:^(BOOL success) {
        
        if(success) {
            
            
        } else {
            
            // Show message view with error
            CGRect messageIconViewFrame = self.view.bounds;
            
            
            [self addMessageIconViewToView:self.view
                                     frame:messageIconViewFrame
                                      icon:[UIImage imageNamed:@"XMessageIcon"]
                                      text:@"Error Posting"
                                detailText:nil
                                  animated:YES];
            
        }
        
        // Remove the activity indicator
        [self removeActivityIndicatorViewAnimated:YES];
        
        }];
    }
}


- (void)tappedLink:(NSString *)link cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *v_name = [link stringByReplacingOccurrencesOfString:@"@" withString:@""];
    v_name = [v_name stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    if ([link rangeOfString:@"@"].location != NSNotFound)
    {
        [[InstagramClient sharedClient] getUserForName:v_name completion:^(BOOL success, NSArray *users, NSString *cursor) {
            
            if(success) {
                
                NSArray *searchResults = users;
                if (searchResults != nil) {
                    InstagramUser *user;
                    user = searchResults[0];
                    
                    // Reset the user
                    ProfileViewController *profileViewController
                    = [[ProfileViewController alloc] initWithUser:user];
                    
                    // Push view controller
                    [self.navigationController pushViewController:profileViewController animated:YES];

                }
            }
            
        }];

    }
    else if ([link rangeOfString:@"#"].location != NSNotFound){
        
        // Reset the user
        TagCollectionViewController *collectionView = [[TagCollectionViewController alloc] initWithNibName:@"TagCollectionViewController" bundle:nil];
        collectionView.m_tagName = v_name;
        
        // Push view controller
        [self.navigationController pushViewController:collectionView animated:YES];
    }

    
//    NSString *title = [NSString stringWithFormat:@"Tapped %@", link];
//    NSString *message = [NSString stringWithFormat:@"You tapped %@ in section %@, row %@.",
//                         link,
//                         @(indexPath.section),
//                         @(indexPath.row)];
//    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
//                                                                   message:message
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil]];
//    
//    [self presentViewController:alert animated:YES completion:nil];
}


@end
