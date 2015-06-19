//
//  NSObject+Shortcuts.h
//  IsaacsIOSLibrary
//
//  Created by Isaac Paul on 5/16/14.
//  Copyright (c) 2014 Isaac Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Shortcuts)

- (NSError*)errorWithCode:(NSInteger)code andLocalizedDescription:(NSString*)desc;
+ (NSError*)errorWithCode:(NSInteger)code description:(NSString*)errorDesc;

@end
