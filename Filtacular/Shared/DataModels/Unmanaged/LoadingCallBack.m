//
//  LoadingCallBack.m
//  Filtacular
//
//  Created by Isaac Paul on 6/19/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "LoadingCallBack.h"

@implementation LoadingCallBack

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:self.class])
        return true;
    
    return false;
}

- (NSUInteger)hash {
    return 1;
}

@end
