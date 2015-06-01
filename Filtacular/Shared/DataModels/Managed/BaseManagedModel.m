//
//  BaseManagedModel.m
//  Filtacular
//
//  Created by Isaac Paul on 10/8/14.
//  Copyright (c) 2014 CloudSpace. All rights reserved.
//

#import "BaseManagedModel.h"

@implementation BaseManagedModel

+ (RKEntityMapping*)entityMapping {
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] managedObjectStore];
    return [self entityMappingWithStore:objectStore];
}

+ (RKEntityMapping*)entityMappingWithStore:(RKManagedObjectStore*)store {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    return mapping;
}

+ (instancetype)createEntity {
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] managedObjectStore];
    id entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:objectStore.mainQueueManagedObjectContext];
    
    return entity;
}

+ (NSManagedObjectContext*)mainContext {
    return [[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
}

@end
