//
//  User.m
//  Filtacular
//
//  Created by John Li on 6/2/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "User.h"


@implementation User

@dynamic userId;
@dynamic nickname;

+ (RKEntityMapping*)entityMappingWithStore:(RKManagedObjectStore*)store {
    RKEntityMapping *mapping = [super entityMappingWithStore:store];
    mapping.identificationAttributes = @[@"userId"];
    [mapping addAttributeMappingsFromArray:@[@"nickname"]];
    [mapping addAttributeMappingsFromDictionary:@{@"userid": @"userId"}];
    
    return mapping;
}

@end
