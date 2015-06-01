//
//  BaseUnmanagedModel.h
//  Filtacular
//
//  Created by Isaac Paul on 10/9/14.
//  Copyright (c) 2014 CloudSpace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface BaseUnmanagedModel : NSObject

+ (RKObjectMapping*)objectMapping;

@end
