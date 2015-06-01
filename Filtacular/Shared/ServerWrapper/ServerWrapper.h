//
//  ServerWrapper.h
//  Filtacular
//
//  Created by Isaac Paul on 10/14/14.
//  Copyright (c) 2014 CloudSpace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

/*! See RKObjectManager for documentation on REST methods */
@interface ServerWrapper : NSObject

+ (ServerWrapper*)sharedInstance;

- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
                 success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                 failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;


- (void)getObjectsAtPathForRelationship:(NSString *)relationshipName
                               ofObject:(id)object
                             parameters:(NSDictionary *)parameters
                                success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                                failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void)getObjectsAtPathForRouteNamed:(NSString *)routeName
                               object:(id)object
                           parameters:(NSDictionary *)parameters
                              success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                              failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void)getObject:(id)object
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
          success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
          failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void)postObject:(id)object
              path:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
           failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;


- (void)putObject:(id)object
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
          success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
          failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void)patchObject:(id)object
               path:(NSString *)path
         parameters:(NSDictionary *)parameters
            success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
            failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;


- (void)deleteObject:(id)object
                path:(NSString *)path
          parameters:(NSDictionary *)parameters
             success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
             failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
