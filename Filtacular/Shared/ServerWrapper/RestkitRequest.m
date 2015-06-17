//
//  RestkitRequest.m
//  Filtacular
//
//  Created by Isaac Paul on 10/16/14.
//  Copyright (c) 2014 CloudSpace. All rights reserved.
//

#import "RestkitRequest.h"

@implementation RestkitRequest

- (bool)isValid {
    return true;
}

- (void)performSimpleRequestWithObjectManager:(RKObjectManager *)objectManager {
    switch (_requestMethod) {
        case RKRequestMethodGET:
            [self performSimpleGETRequest:objectManager];
            break;
        case RKRequestMethodPOST:
        case RKRequestMethodPUT:
        case RKRequestMethodDELETE:
        case RKRequestMethodPATCH:
            @throw @"Not Implemented";
        default:
            break;
    }
}

- (void)performRequestWithObjectManager:(RKObjectManager *)objectManager {
    if (_noMappingRequired) {
        [self performSimpleRequestWithObjectManager:objectManager];
        return;
    }
    switch (_requestMethod) {
        case RKRequestMethodGET:
            [self performGETRequest:objectManager];
            break;
        case RKRequestMethodPOST:
            [self performPOSTRequest:objectManager];
            break;
        case RKRequestMethodPUT:
            [self performPUTRequest:objectManager];
            break;
        case RKRequestMethodDELETE:
            [self performDELETERequest:objectManager];
            break;
        case RKRequestMethodPATCH:
            [self performPATCHRequest:objectManager];
            break;
        default:
            break;
    }
}

- (void)performGETRequest:(RKObjectManager*)objectManager {
    [objectManager getObject:_object path:_path parameters:_parameters success:_success failure:_failure];
}

- (void)performSimpleGETRequest:(RKObjectManager*)objectManager {
    AFHTTPClient * client = objectManager.HTTPClient;
    [client getPath:_path parameters:_parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* simpleResponse = @{};
        if (responseObject)
            simpleResponse = @{@"simpleResponse":responseObject};
        RKMappingResult* result = [[RKMappingResult alloc] initWithDictionary:simpleResponse];
        if (_success)
            _success(nil, result);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (_failure)
            _failure(nil, error);
    }];
}

- (void)performPOSTRequest:(RKObjectManager*)objectManager {
    [objectManager postObject:_object path:_path parameters:_parameters success:_success failure:_failure];
}

- (void)performPUTRequest:(RKObjectManager*)objectManager {
    [objectManager putObject:_object path:_path parameters:_parameters success:_success failure:_failure];
}

- (void)performDELETERequest:(RKObjectManager*)objectManager {
    [objectManager deleteObject:_object path:_path parameters:_parameters success:_success failure:_failure];
}

- (void)performPATCHRequest:(RKObjectManager*)objectManager {
    [objectManager patchObject:_object path:_path parameters:_parameters success:_success failure:_failure];
}

@end
