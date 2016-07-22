//
//  InstafollowersProduct.h
//  Instafollowers
//
//  Created by Michael Orcutt on 2/18/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "Model.h"

@interface InstafollowersProduct : Model

@property (readonly) NSString *title;
@property (readonly) NSInteger coins;
@property (readonly) NSInteger followers;

@end
