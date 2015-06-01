//
//  RestkitService.m
//  Filtacular
//
//  Created by Isaac Paul on 10/9/14.
//  Copyright (c) 2014 CloudSpace. All rights reserved.
//

#import "RestkitService.h"

#import <RestKit/CoreData.h> //Import Order matters
#import <RestKit/RestKit.h>

#import "APIInfo.h"

@implementation RestkitService

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initialize RestKit
    APIInfo* apiInfo = [APIInfo buildFromPlist];
    NSURL *baseURL = [NSURL URLWithString:[apiInfo.hostPath stringByAppendingString:apiInfo.basePath]];
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseURL];
    
    //NOTE: Uncomment for better logs
    //RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    //Configure client
    //objectManager.HTTPClient.allowsInvalidSSLCertificate = true;
    //[objectManager.HTTPClient setDefaultHeader:@"X-applicationID" value:apiInfo.key];
    [RKObjectManager setSharedManager:objectManager];
    [objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Initialize managed object store
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    objectManager.managedObjectStore = managedObjectStore;
    
    [self addRoutesTo:objectManager];
    [self addRequestDescriptorsTo:objectManager];
    [self addResponseDescriptorsTo:objectManager];
    
    // Complete Core Data stack initialization
    [managedObjectStore createPersistentStoreCoordinator];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Filtacular.sqlite"];
    NSError *error;
    __unused NSPersistentStore* persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    
    // Reset the persistant store when the data model changes
    if (error) {
        
        [[NSFileManager defaultManager] removeItemAtPath:storePath error:nil];
        
        error = nil;
        NSPersistentStore __unused *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
        NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    }
    
    [managedObjectStore createManagedObjectContexts];
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
    return YES;
}

- (void)addRoutesTo:(RKObjectManager*)objectManager {
//    RKRouteSet* routeSet = objectManager.router.routeSet;
//    [routeSet addRoute:[RKRoute routeWithClass:[User class] pathPattern:@"user" method:RKRequestMethodAny]];
}

//Specifies mapping for data model -> request
- (void)addRequestDescriptorsTo:(RKObjectManager*)objectManager {
    
    //Standard Example of mappings:
    /*
    RKObjectMapping* mapping = [[User entityMapping] inverseMapping];
    mapping.assignsDefaultValueForMissingAttributes = NO;
    RKRequestDescriptor* requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:mapping objectClass:[User class] rootKeyPath:@"user" method:RKRequestMethodPOST];
    
    [objectManager addRequestDescriptor:requestDescriptor];
    
    mapping = [[AccessToken objectMapping] inverseMapping];
    mapping.assignsDefaultValueForMissingAttributes = NO;
    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:mapping objectClass:[AccessToken class] rootKeyPath:nil method:RKRequestMethodAny];
    
    [objectManager addRequestDescriptor:requestDescriptor];
     */
}

//Specifies mapping for request -> data models
- (void)addResponseDescriptorsTo:(RKObjectManager*)objectManager {

    //Standard Example of mappings:
    /*
     RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[AccessToken objectMapping] method:RKRequestMethodPOST pathPattern:@"oauth/token" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:responseDescriptor];

    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[InventoryEntry entityMapping] method:RKRequestMethodGET pathPattern:@"stations/:id/products" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:responseDescriptor];

    
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    
    RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"error_description" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    [objectManager addResponseDescriptor:errorDescriptor];
    
    errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"errors.message" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    [objectManager addResponseDescriptor:errorDescriptor];
    */
}

@end
