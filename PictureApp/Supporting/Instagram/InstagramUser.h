//
//  InstagramUser.h
//  InstagramFollowers
//
//  Created by Michael Orcutt on 10/20/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "Model.h"

@interface InstagramUser : Model

@property (readonly) NSString *identifier;
@property (readonly) NSNumber *identifierNumber;
@property (readonly) NSString *fullName;
@property (readonly) NSString *username;
@property (readonly) NSString *bio;
@property (readonly) NSString *website;
@property (readonly) NSString *profilePictureURLString;
@property (readonly) NSURL    *profilePictureURL;
@property (readonly) NSString *followersCount;
@property (readonly) NSString *followsCount;
@property (readonly) NSString *mediaCount;

@property (readonly) BOOL followersSet;
@property (readonly) BOOL followsSet;

@property (strong, nonatomic) NSAttributedString *associatedAttributedString;
@property (strong, nonatomic) NSNumber *associatedNumber;

@end
