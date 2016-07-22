//
//  InstagramComment.h
//  InstagramFollowers
//
//  Created by Michael Orcutt on 11/26/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "Model.h"

@interface InstagramComment : Model

@property (readonly) NSDictionary *from;

@property (readonly) NSString *userIdentifier;


- (NSString *)userIdentifier;
- (NSDictionary *)from;
- (NSString *)text;

@end
