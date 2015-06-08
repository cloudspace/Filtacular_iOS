//
//  User.m
//  Filtacular
//
//  Created by John Li on 6/2/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "User.h"


@implementation User

@dynamic identifier;
@dynamic userId;
@dynamic nickname;

+ (RKEntityMapping*)entityMappingWithStore:(RKManagedObjectStore*)store {
    RKEntityMapping *mapping = [super entityMappingWithStore:store];
    mapping.identificationAttributes = @[@"identifier"];
    [mapping addAttributeMappingsFromArray:@[@"nickname"]];
    [mapping addAttributeMappingsFromDictionary:@{@"user-id": @"userId", @"id": @"identifier"}];

    
    return mapping;
}

+ (NSArray*)pseudoUsers {
    NSArray* users = [self findAll];
    if (users.count > 0)
        return users;
    
    User* user1 = [User createEntity];
    user1.nickname = @"Jessie";
    
    User* user2 = [User createEntity];
    user2.nickname = @"James";
    
    User* user3 = [User createEntity];
    user3.nickname = @"Meowth";
    
    NSError* error;
    [[self mainContext] save:&error];
    
    return @[user1, user2, user3];
}

@end
