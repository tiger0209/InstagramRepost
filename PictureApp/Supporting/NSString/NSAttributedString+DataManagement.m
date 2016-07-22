//
//  NSAttributedString+DataManagement.m
//  Instafollowers
//
//  Created by Michael Orcutt on 2/24/14.
//  Copyright (c) 2014 Michael Orcutt. All rights reserved.
//

#import "NSAttributedString+DataManagement.h"
#import <UIKit/UIKit.h>

@implementation NSAttributedString (DataManagement)

+ (NSAttributedString *)distanceAttributedStringWithDistance:(CGFloat)distance
                                                        unit:(NSString *)unit
                                                    username:(NSString *)username
{
    // Create attributed string from information provided
    NSString *posted = @"posted";
    NSString *away   = @"away";
    NSString *distanceString
    = [NSString stringWithFormat:@"%@ %@", [NSString localizedStringWithFormat:@"%.2f", distance], unit];
    
    // Alloc mutable attributed string that will be styled
    NSMutableAttributedString *attributedString
    = [[NSMutableAttributedString alloc] initWithString:
       [NSString stringWithFormat:@"%@ %@ %@ %@", username, posted, distanceString, away]];
    
    // Style entire string
    NSRange attributedStringRange = NSMakeRange(0, attributedString.length);
    
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0]
                             range:attributedStringRange];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:@"Ubuntu-Light" size:16.0]
                             range:attributedStringRange];

    // Style away and posted strings
    NSRange awayRange   = NSMakeRange((attributedString.length - away.length), away.length);
    NSRange postedRange = NSMakeRange((username.length + 1), posted.length);
    
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0]
                             range:awayRange];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0]
                             range:postedRange];

    return attributedString;
}

+ (NSAttributedString *)commentsAttributedStringWithCommentCount:(NSNumber *)commentCount
                                                        username:(NSString *)username
{
    NSString *has         = @"has";
    NSString *commented   = @"commented";
    NSString *onYourPosts = @"on your posts";
    NSString *times;
    
    if(commentCount == [NSNumber numberWithInteger:1] ) {
        times = @"time";
    } else {
        times = @"times";
    }
    
    // Alloc mutable attributed string that will be styled
    NSMutableAttributedString *attributedString
    = [[NSMutableAttributedString alloc] initWithString:
       [NSString stringWithFormat:
        @"%@ %@ %@ %@ %@ %@", username, has, commented, onYourPosts, commentCount, times]
       ];
    
    // Style entire string
    NSRange attributedStringRange = NSMakeRange(0, attributedString.length);
    
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0]
                             range:attributedStringRange];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:@"Ubuntu-Light" size:16.0]
                             range:attributedStringRange];
    
    // Refactor styling
    NSRange hasRange         = NSMakeRange((username.length + 1), has.length);
    NSRange onYourPostsRange = NSMakeRange((username.length + 3 + has.length + commented.length), onYourPosts.length);
    
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0]
                             range:hasRange];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0]
                             range:onYourPostsRange];

    return attributedString;
}

+ (NSAttributedString *)likesAttributedStringWithLikeCount:(NSNumber *)likeCount
                                                  username:(NSString *)username
{
    NSString *has       = @"has";
    NSString *liked     = @"liked";
    NSString *yourPosts = @"your posts";
    NSString *times;
    
    if(likeCount == [NSNumber numberWithInteger:1] ) {
        times = NSLocalizedString(@"time", nil);
    } else {
        times = NSLocalizedString(@"times", nil);
    }
    
    // Alloc mutable attributed string that will be styled
    NSMutableAttributedString *attributedString
    = [[NSMutableAttributedString alloc] initWithString:
       [NSString stringWithFormat:
        @"%@ %@ %@ %@ %@ %@", username, has, liked, yourPosts, likeCount, times]
       ];
    
    // Style entire string
    NSRange attributedStringRange = NSMakeRange(0, attributedString.length);
    
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0]
                             range:attributedStringRange];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:@"Ubuntu-Light" size:16.0]
                             range:attributedStringRange];
    
    // Refactor styling
    NSRange hasRange       = NSMakeRange((username.length + 1), has.length);
    NSRange yourPostsRange = NSMakeRange((username.length + 3 + has.length + liked.length), yourPosts.length);
    
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0]
                             range:hasRange];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0]
                             range:yourPostsRange];
    
    return attributedString;
}

+ (NSAttributedString *)likesAndCommentsAttributedStringWithLikeCount:(NSNumber *)likeCount
                                                         commentCount:(NSNumber *)commentCount
                                                             username:(NSString *)username
{
    // **username** has **liked 3 posts** and **commented 3 times**.
    NSString *has       = @"has";
    NSString *liked     = @"liked";
    NSString *and       = @"and";
    NSString *commented = @"commented";
    
    NSString *posts;
    NSString *times;

    if(likeCount == [NSNumber numberWithInteger:1] ) {
        posts = NSLocalizedString(@"post", nil);
    } else {
        posts = NSLocalizedString(@"posts", nil);
    }
    
    if(commentCount == [NSNumber numberWithInteger:1] ) {
        times = NSLocalizedString(@"time", nil);
    } else {
        times = NSLocalizedString(@"times", nil);
    }

    // Alloc mutable attributed string that will be styled
    NSString *string
    = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@", username, has, liked, likeCount, posts, and, commented, commentCount, times];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    // Style entire string
    NSRange attributedStringRange = NSMakeRange(0, attributedString.length);
    
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0]
                             range:attributedStringRange];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:@"Ubuntu-Light" size:16.0]
                             range:attributedStringRange];
    
    // Refactor style
    NSRange hasRange
    = NSMakeRange((username.length + 1), has.length);
    NSRange andRange
    = NSMakeRange(attributedString.length - times.length - commentCount.stringValue.length - commented.length - 3 - and.length, and.length);

    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0]
                             range:hasRange];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0]
                             range:andRange];
    
    return attributedString;
}

+ (NSAttributedString *)youLikedAttributedStringWithLikeCount:(NSNumber *)likeCount username:(NSString *)username
{
    NSString *you   = NSLocalizedString(@"you", nil);
    NSString *liked = NSLocalizedString(@"liked", nil); // bold
    NSString *posts = NSLocalizedString(@"posts", nil);
    NSString *times;
    
    if(likeCount == [NSNumber numberWithInteger:1] ) {
        times = NSLocalizedString(@"time", nil);
    } else {
        times = NSLocalizedString(@"times", nil);
    }
    
    // Alloc mutable attributed string that will be styled
    NSMutableAttributedString *attributedString
    = [[NSMutableAttributedString alloc] initWithString:
       [NSString stringWithFormat:
        @"%@ %@ %@ %@ %@ %@", you, liked, username, posts, likeCount, times]
       ];
    
    // Style entire string
    NSRange attributedStringRange = NSMakeRange(0, attributedString.length);
    
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0]
                             range:attributedStringRange];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:@"Ubuntu-Light" size:16.0]
                             range:attributedStringRange];
    
    // Style on string
    NSRange youRange
    = NSMakeRange(0.0, you.length);
    NSRange postsRange
    = NSMakeRange((you.length + liked.length + username.length + 3), posts.length);
    
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0]
                             range:youRange];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0]
                             range:postsRange];
    
    return attributedString;
}

+ (NSAttributedString *)userAttributedStringWithNumberString:(NSString *)numberString
                                                    username:(NSString *)username
{
    NSString *is            = @"is";
    NSString *instagramUser = @"Instagram user";
    
    // Alloc mutable attributed string that will be styled
    NSString *string = [NSString stringWithFormat:@"%@ %@ %@ %@", username, is, instagramUser, numberString];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    // Style entire string
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:91.0/255.0 green:94.0/255.0 blue:98.0/255.0 alpha:1.0]
                             range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:@"Ubuntu-Light" size:16.0]
                             range:NSMakeRange(0, attributedString.length)];
    
    // Style refactoring
    NSRange isRange = NSMakeRange((username.length + 1), is.length);
    
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0]
                             range:isRange];

    return attributedString;
}

@end
