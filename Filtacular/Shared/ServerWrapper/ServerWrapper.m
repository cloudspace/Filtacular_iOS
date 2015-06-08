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

static dispatch_queue_t sRequestQueue;

@interface ServerWrapper ()

@property (strong, nonatomic) RKObjectManager* objectManager;
@property (copy, nonatomic) void (^failureBlockWithAccesRefresh) (RKObjectRequestOperation *operation, NSError *error);

@end

@implementation ServerWrapper

+ (void)load {
    sRequestQueue = dispatch_queue_create("sRequestQueue", 0);
}

+ (dispatch_queue_t)requestQueue {
    return sRequestQueue;
}

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

- (void)cancelAllRequestOperationsWithMethod:(RKRequestMethod)method matchingPathPattern:(NSString *)pathPattern {
    [_objectManager cancelAllObjectRequestOperationsWithMethod:method matchingPathPattern:pathPattern];
}

- (void)performRequest:(RestkitRequest*)request {
    [request performRequestWithObjectManager:_objectManager];
}

- (RestkitRequestReponse*)performSyncRequest:(RestkitRequest*)request {
    RestkitRequestReponse* response = [RestkitRequestReponse new];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    request.failure = [self hookFailureBlock:request.failure withBlock:^(RKObjectRequestOperation *operation, NSError *error) {
        //RKErrorMessage *errorMessage = [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
        response.successful = false;
        response.error = error;
        dispatch_semaphore_signal(semaphore);
    }];
    request.success = [self hookSuccessBlock:request.success withBlock:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        response.successful = true;
        response.mappingResult = mappingResult;
        dispatch_semaphore_signal(semaphore);
    }];
    [request performRequestWithObjectManager:_objectManager];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return response;
}

- (RestkitRequestReponse*)performSyncGet:(NSString*)path {
    RestkitRequest* request = [RestkitRequest new];
    request.requestMethod = RKRequestMethodGET;
    request.path = path;
    
    return [self performSyncRequest:request];
}

#pragma mark -
- (RestkitFailureBlock)hookFailureBlock:(RestkitFailureBlock)failure withBlock:(RestkitFailureBlock)hook {
    
    RestkitFailureBlock attachedFailureBlock = ^void (RKObjectRequestOperation *operation, NSError *error) {
        //Add any default code here (example: kick user on 401)
        if (failure)
            failure(operation, error);
        hook(operation, error);
    };
    
    return attachedFailureBlock;
}

- (RestkitSuccessBlock)hookSuccessBlock:(RestkitSuccessBlock)success withBlock:(RestkitSuccessBlock)hook{
    
    RestkitSuccessBlock attachedSuccessBlock = ^void (RKObjectRequestOperation *operation,  RKMappingResult *mappingResult) {
        if (success)
            success(operation, mappingResult);
        hook(operation, mappingResult);
    };
    
    return attachedSuccessBlock;
}

@end

