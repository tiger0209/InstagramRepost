//
//  ARSegmentPageHeader.h
//  ARSegmentPager
//
//  Created by August on 15/3/28.
//  Copyright (c) 2015 August. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSegmentPageControllerHeaderProtocol.h"
#import "InstagramUser.h"

@interface ARSegmentPageHeader : UIView<ARSegmentPageControllerHeaderProtocol>

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) IBOutlet UILabel          *m_count_follower_Label;
@property (nonatomic, strong) IBOutlet UILabel          *m_count_followeing_Label;
@property (nonatomic, strong) IBOutlet UIView           *m_user_outletView;
@property (nonatomic, strong) IBOutlet UIImageView      *m_user_imageView;
@property (nonatomic, strong) IBOutlet UIButton         *m_user_Btn;
@property (nonatomic, strong) IBOutlet UIButton         *m_follower_Btn;
@property (nonatomic, strong) IBOutlet UIButton         *m_following_Btn;

@property (strong, nonatomic) InstagramUser *user;
@property (strong, nonatomic) UINavigationController *m_navigationController;


@end