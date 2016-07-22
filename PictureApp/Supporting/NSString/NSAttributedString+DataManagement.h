//
//  NSAttributedString+DataManagement.h
//  Instafollowers
//
//  Created by Michael Orcutt on 2/24/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (DataManagement)

+ (NSAttributedString *)distanceAttributedStringWithDistance:(float)distance
                                                        unit:(NSString *)unit
                                                    username:(NSString *)username;

+ (NSAttributedString *)commentsAttributedStringWithCommentCount:(NSNumber *)commentCount
                                                        username:(NSString *)username;

+ (NSAttributedString *)likesAttributedStringWithLikeCount:(NSNumber *)likeCount
                                                  username:(NSString *)username;

+ (NSAttributedString *)likesAndCommentsAttributedStringWithLikeCount:(NSNumber *)likeCount
                                                         commentCount:(NSNumber *)commentCount
                                                             username:(NSString *)username;

+ (NSAttributedString *)youLikedAttributedStringWithLikeCount:(NSNumber *)likeCount
                                                     username:(NSString *)username;

+ (NSAttributedString *)userAttributedStringWithNumberString:(NSString *)numberString
                                                    username:(NSString *)username;

@end
