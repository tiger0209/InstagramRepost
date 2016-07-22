//
//  InstafollowersAd.h
//  Instafollowers
//
//  Created by Michael Orcutt on 3/11/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "Model.h"

@interface InstafollowersAd : Model

@property (readonly) NSURL *imageURL;
@property (readonly) NSString *identifier;

@property (strong, nonatomic) UIImage *image;

@end
