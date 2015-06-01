//
//  BaseUnmanagedModel.m
//  Filtacular
//
//  Created by Isaac Paul on 10/9/14.
//  Copyright (c) 2014 CloudSpace. All rights reserved.
//

#import "BaseUnmanagedModel.h"

@implementation BaseUnmanagedModel

+ (RKObjectMapping *)objectMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    return mapping;
}

@end
