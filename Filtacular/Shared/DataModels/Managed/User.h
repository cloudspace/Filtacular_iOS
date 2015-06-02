//
//  User.h
//  Filtacular
//
//  Created by John Li on 6/2/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "BaseManagedModel.h"

@interface User : BaseManagedModel

@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* nickname;

+ (RKEntityMapping*)entityMappingWithStore:(RKManagedObjectStore*)store;

@end
