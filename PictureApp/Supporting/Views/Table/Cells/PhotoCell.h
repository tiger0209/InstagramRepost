//
//  PhotoCell.h
//  InstagramLikes
//
//  Created by Michael Orcutt on 12/17/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoCellDelegate <NSObject>

- (void)handleFailure:(id)sender;

@end

@interface PhotoCell : UITableViewCell

@property (strong, nonatomic) __block UIImageView *photoImageView;

@property (strong, nonatomic) UIProgressView *progressView;

@property (nonatomic) BOOL failure;

@end
