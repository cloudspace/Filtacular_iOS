//
//  APIInfo.h
//  Filtacular
//
//  Created by Isaac Paul on 10/9/14.
//  Copyright (c) 2014 CloudSpace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIInfo : NSObject

@property (strong, nonatomic) const NSString* hostPath;
@property (strong, nonatomic) NSString* basePath;
@property (strong, nonatomic) NSString* key;
@property (strong, nonatomic) NSString* secret;

+ (instancetype)buildFromPlist;

@end
