//
//  User.h
//  Filtacular
//
//  Created by John Li on 6/2/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "BaseManagedModel.h"

@interface User : BaseManagedModel

@property (nonatomic, assign) int identifier;
@property (nonatomic, assign) int userId;
@property (nonatomic, strong) NSString* nickname;

+ (RKEntityMapping*)entityMappingWithStore:(RKManagedObjectStore*)store;
+ (NSArray*)pseudoUsers;

@end
