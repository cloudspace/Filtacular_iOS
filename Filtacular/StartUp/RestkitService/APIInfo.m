//
//  APIInfo.m
//  Filtacular
//
//  Created by Isaac Paul on 10/9/14.
//  Copyright (c) 2014 CloudSpace. All rights reserved.
//

#import "APIInfo.h"

@implementation APIInfo

+ (instancetype)buildFromPlist {
    APIInfo* api = [self new];
    NSDictionary* apiDic = [self apiDic];
    NSAssert(apiDic != nil, @"Could not retrieve API Plist");
    NSMutableString* test = [apiDic[@"ApiHost"] mutableCopy];
    api.hostPath    = test;
    api.basePath    = apiDic[@"ApiBasePath"];
    api.key         = apiDic[@"ApiKey"];
    api.secret      = apiDic[@"ApiSecret"];
    
    return api;
}

+ (NSDictionary*)apiDic {
    NSString* fileName = [NSString stringWithFormat:@"%@-API", [self productName]];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    return dict;
}

+ (NSString*)productName {
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSString* productName = info[(NSString*)kCFBundleNameKey];
    return productName;
}

@end
