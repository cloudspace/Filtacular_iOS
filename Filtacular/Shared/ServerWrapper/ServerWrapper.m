//
//  ServerWrapper.m
//  Filtacular
//
//  Created by Isaac Paul on 10/14/14.
//  Copyright (c) 2014 CloudSpace. All rights reserved.
//

#import "ServerWrapper.h"
#import "APIInfo.h"
#import <RestKit/RestKit.h>
#import "RestkitRequest.h"

@interface ServerWrapper ()

@property (strong, nonatomic) RKObjectManager* objectManager;
@property (copy, nonatomic) void (^failureBlockWithAccesRefresh) (RKObjectRequestOperation *operation, NSError *error);

@end

@implementation ServerWrapper

+ (id)sharedInstance {
    static ServerWrapper* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self buildWithObjectManager:[RKObjectManager sharedManager]];
    });
    return sharedInstance;
}

+ (instancetype)buildWithObjectManager:(RKObjectManager*)objectManager {
    ServerWrapper* serverWrapper = [self new];
    serverWrapper.objectManager = objectManager;
    
    return serverWrapper;
}


- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
                 success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                 failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    
    //failure = [self hookFailureBlock:failure];
    NSAssert(false, @"Not implemented");
    [_objectManager getObjectsAtPath:path parameters:parameters success:success failure:failure];
}


- (void)getObjectsAtPathForRelationship:(NSString *)relationshipName
                               ofObject:(id)object
                             parameters:(NSDictionary *)parameters
                                success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                                failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    
    //failure = [self hookFailureBlock:failure];
    NSAssert(false, @"Not implemented");
    [_objectManager getObjectsAtPathForRelationship:relationshipName ofObject:object parameters:parameters success:success failure:failure];
}

- (void)getObjectsAtPathForRouteNamed:(NSString *)routeName
                               object:(id)object
                           parameters:(NSDictionary *)parameters
                              success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                              failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    
    //failure = [self hookFailureBlock:failure];
    NSAssert(false, @"Not implemented");
    [_objectManager getObjectsAtPathForRouteNamed:routeName object:object parameters:parameters success:success failure:failure];
}

- (void)getObject:(id)object
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
          success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
          failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    
    RestkitRequest* request = [RestkitRequest new];
    failure = [self hookFailureBlock:failure withRequest:request];
    
    request.requestMethod = RKRequestMethodGET;
    request.object = object;
    request.path = path;
    request.parameters = parameters;
    request.success = success;
    request.failure = failure;
    
    [request performRequestWithObjectManager:_objectManager];
}

- (void)postObject:(id)object
              path:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
           failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    
    RestkitRequest* request = [RestkitRequest new];
    failure = [self hookFailureBlock:failure withRequest:request];
    
    request.requestMethod = RKRequestMethodPOST;
    request.object = object;
    request.path = path;
    request.parameters = parameters;
    request.success = success;
    request.failure = failure;
    
    [request performRequestWithObjectManager:_objectManager];
}


- (void)putObject:(id)object
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
          success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
          failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    
    RestkitRequest* request = [RestkitRequest new];
    failure = [self hookFailureBlock:failure withRequest:request];
    
    request.requestMethod = RKRequestMethodPUT;
    request.object = object;
    request.path = path;
    request.parameters = parameters;
    request.success = success;
    request.failure = failure;
    
    [request performRequestWithObjectManager:_objectManager];
}

- (void)patchObject:(id)object
               path:(NSString *)path
         parameters:(NSDictionary *)parameters
            success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
            failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    
    RestkitRequest* request = [RestkitRequest new];
    failure = [self hookFailureBlock:failure withRequest:request];
    
    request.requestMethod = RKRequestMethodPATCH;
    request.object = object;
    request.path = path;
    request.parameters = parameters;
    request.success = success;
    request.failure = failure;
    
    [request performRequestWithObjectManager:_objectManager];
}

- (void)deleteObject:(id)object
                path:(NSString *)path
          parameters:(NSDictionary *)parameters
             success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
             failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    
    RestkitRequest* request = [RestkitRequest new];
    failure = [self hookFailureBlock:failure withRequest:request];
    
    request.requestMethod = RKRequestMethodDELETE;
    request.object = object;
    request.path = path;
    request.parameters = parameters;
    request.success = success;
    request.failure = failure;
    
    [request performRequestWithObjectManager:_objectManager];
}

#pragma mark -
- (RestkitFailureBlock)hookFailureBlock:(RestkitFailureBlock)failure withRequest:(RestkitRequest*)request {
    
    RestkitFailureBlock attachedFailureBlock = ^void (RKObjectRequestOperation *operation, NSError *error)
    {
        //Add any default code here (example: kick user on 401)
        failure(operation, error);
        
    };
    
    return attachedFailureBlock;
}

@end

