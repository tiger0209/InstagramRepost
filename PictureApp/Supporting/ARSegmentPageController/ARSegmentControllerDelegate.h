//
//  ARSegmentControllerDelegate.h
//  ARSegmentPager
//
//  Created by August on 15/3/29.
//  Copyright (c) 2015 August. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ARSegmentControllerDelegate <NSObject>

-(NSString *)segmentTitle;

///lgilgilgilgi
-(void) requestingRefresh;
-(void) requestingLoadMedia;

@optional
-(UIScrollView *)streachScrollView;

@end
