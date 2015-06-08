//
//  BaseManagedModel.m
//  Filtacular
//
//  Created by Isaac Paul on 10/8/14.
//  Copyright (c) 2014 CloudSpace. All rights reserved.
//

#import "BaseManagedModel.h"
#import <Coredata.h>

@implementation BaseManagedModel

+ (RKEntityMapping*)entityMapping {
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] managedObjectStore];
    return [self entityMappingWithStore:objectStore];
}

+ (RKEntityMapping*)entityMappingWithStore:(RKManagedObjectStore*)store {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[self entityName] inManagedObjectStore:store];
    return mapping;
}

+ (instancetype)createEntity {
    NSAssert([NSThread currentThread] == [NSThread mainThread], @"Not thread safe!");
    id entity = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:[self mainContext]];
    
    return entity;
}

+ (NSManagedObjectContext*)mainContext {
    return [[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
}

+ (NSArray*)findAll {
    NSAssert([NSThread currentThread] == [NSThread mainThread], @"Not thread safe!");
    NSManagedObjectContext* context = [self mainContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[self entityName]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error != nil) {
        NSLog(@"Error: fetching users");
        return nil;
    }
    
    return results;
}

+ (NSString*)entityName {
    return NSStringFromClass(self);
}

- (NSString*)stringForPicker {
    return @"wth";
}

@end
