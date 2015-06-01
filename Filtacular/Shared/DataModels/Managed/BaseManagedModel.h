//
//  BaseManagedModel.h
//  Filtacular
//
//  Created by Isaac Paul on 10/8/14.
//  Copyright (c) 2014 CloudSpace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>

@interface BaseManagedModel : NSManagedObject

+ (RKEntityMapping*)entityMapping;
+ (RKEntityMapping*)entityMappingWithStore:(RKManagedObjectStore*)store;
+ (instancetype)createEntity;

+ (NSManagedObjectContext*)mainContext;

@end
