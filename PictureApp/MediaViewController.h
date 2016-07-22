//
//  MediaViewController.h
//  InstagramLikes
//
//  Created by Michael Orcutt on 2/10/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "UIKit/UIKit.h"

@interface MediaViewController : UIViewController<UIActionSheetDelegate>

- (id)initWithMediaIdentifier:(NSString *)mediaIdentifier;

@end
