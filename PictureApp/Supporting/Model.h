//
//  Model.h
//  Unfriended
//
//  Created by Michael Orcutt on 12/15/12.
//  Copyright (c) 2012 Michael Orcutt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Model : NSObject

@property (strong, nonatomic) NSDictionary *dictionary;

+ (Model *)modelWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)modelsFromDictionaries:(NSArray *)dictionaries;

@end
