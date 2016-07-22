//
//  MOBlurButton.h
//  Instafollowers
//
//  Created by Michael Orcutt on 2/28/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ActionBlock)(void);

@interface MOBlurButton : UIButton

@property (nonatomic, copy) ActionBlock actionBlock;

@end
