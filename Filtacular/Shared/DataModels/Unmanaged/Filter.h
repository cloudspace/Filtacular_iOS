//
//  Filter.h
//  Filtacular
//
//  Created by Isaac Paul on 6/3/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "BaseUnmanagedModel.h"

@interface Filter : BaseUnmanagedModel

@property (nonatomic, strong) NSString* displayName;

+ (NSArray*)pseudoFilters;

@end
