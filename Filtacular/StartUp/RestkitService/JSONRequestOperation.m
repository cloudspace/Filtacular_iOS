//
//  JSONRequestOperation.m
//  Filtacular
//
//  Created by Isaac Paul on 6/5/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "JSONRequestOperation.h"

@implementation JSONRequestOperation

+ (NSSet *)acceptableContentTypes {
    return [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"application/vnd.api+json", nil];
}

@end
