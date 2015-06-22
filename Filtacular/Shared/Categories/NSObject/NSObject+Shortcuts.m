//
//  NSObject+Shortcuts.m
//  IsaacsIOSLibrary
//
//  Created by Isaac Paul on 5/16/14.
//  Copyright (c) 2014 Isaac Paul. All rights reserved.
//

#import "NSObject+Shortcuts.h"

@implementation NSObject (Shortcuts)

- (NSError*)errorWithCode:(NSInteger)code andLocalizedDescription:(NSString*)desc {
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:code userInfo:@{NSLocalizedDescriptionKey:desc}];
}

+ (NSError*)errorWithCode:(NSInteger)code description:(NSString*)errorDesc {
    return [NSError errorWithDomain:NSStringFromClass(self) code:code userInfo:@{NSLocalizedDescriptionKey:errorDesc}];
}

@end
