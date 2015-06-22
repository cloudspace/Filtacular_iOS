//
//  NSError+URLError.h
//  IsaacsIOSLibrary
//
//  Created by Isaac Paul on 10/22/14.
//  Copyright (c) 2014 Isaac Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (URLError)

- (bool)isConnectionError;
+ (bool)isConnectionError:(NSInteger)code;
- (NSString*)connectionErrorString;
+ (NSString*)connectionErrorStringForCode:(NSInteger)code;

@end
