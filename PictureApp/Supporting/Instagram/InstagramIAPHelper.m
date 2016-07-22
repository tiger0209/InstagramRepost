//
//  InstagramIAPHelper.m
//  InstagramFollowers
//
//  Created by Michael Orcutt on 11/1/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "InstagramIAPHelper.h"

@implementation InstagramIAPHelper

#pragma mark - Initialization

+ (InstagramIAPHelper *)sharedInstance
{
    static dispatch_once_t once;
    static InstagramIAPHelper *sharedInstance;
    dispatch_once(&once, ^{
        
        NSSet *productIdentifiers;
        
        #ifdef PRO_VERSION
        productIdentifiers = [NSSet setWithObjects:@"com.appdistillery.instafollowpro.onehundred",
                                                   @"com.appdistillery.instafollowpro.fivehundred",
                                                   @"com.appdistillery.instafollowpro.onethousand",
                                                   @"com.appdistillery.instafollowpro.twentyfivehundred",
                                                   @"com.appdistillery.instafollowpro.fivethousand", nil];
        #else
            productIdentifiers = [NSSet setWithObjects:@"com.appdistillery.instafollow.onehundred",
                                                       @"com.appdistillery.instafollow.fivehundred",
                                                       @"com.appdistillery.instafollow.onethousand",
                                                       @"com.appdistillery.instafollow.twentyfivehundred",
                                                       @"com.appdistillery.instafollow.fivethousand", nil];
        #endif
        
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
        
    });
    return sharedInstance;
}

@end
