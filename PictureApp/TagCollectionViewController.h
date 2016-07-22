//
//  CollectionViewController.h
//  ARSegmentPager
//
//  Created by August on 15/3/28.
//  Copyright (c) 2015 August. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSegmentControllerDelegate.h"

@interface TagCollectionViewController : UICollectionViewController<ARSegmentControllerDelegate>

@property (strong, nonatomic) NSString *m_tagName;


- (void)refresh;

@end
