//
//  Model.m
//  Unfriended
//
//  Created by Michael Orcutt on 12/15/12.
//  Copyright (c) 2012 Michael Orcutt. All rights reserved.
//

#import "Model.h"

@implementation Model

+ (Model *)modelWithDictionary:(NSDictionary *)dictionary
{
    Model *model     = [[[self class] alloc] init];
    model.dictionary = dictionary;
    
    return model;
}

+ (NSArray *)modelsFromDictionaries:(NSArray *)dictionaries
{
    NSMutableArray* users = [NSMutableArray arrayWithCapacity:[dictionaries count]];
    
    for (NSDictionary* userDict in dictionaries) {
        [users addObject:[self modelWithDictionary:userDict]];
    }
    
    return users;
}

@end
