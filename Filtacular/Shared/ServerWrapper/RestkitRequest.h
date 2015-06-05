//
//  RestkitRequest.h
//  Filtacular
//
//  Created by Isaac Paul on 10/16/14.
//  Copyright (c) 2014 CloudSpace. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <RestKit/RestKit.h>

typedef void (^RestkitFailureBlock)(RKObjectRequestOperation *operation, NSError *error);
typedef void (^RestkitSuccessBlock)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult);

@interface RestkitRequest : NSObject

@property (assign, nonatomic) RKRequestMethod requestMethod;
@property (assign, nonatomic) bool noMappingRequired;
@property (strong, nonatomic) NSObject* object;
@property (strong, nonatomic) NSString* path;
@property (strong, nonatomic) NSDictionary* parameters;
@property (copy, nonatomic) RestkitSuccessBlock success;
@property (copy, nonatomic) RestkitFailureBlock failure;

- (bool)isValid;

- (void)performRequestWithObjectManager:(RKObjectManager*)objectManager;

@end
