//
//  RestkitRequestReponse.h
//  Filtacular
//
//  Created by Isaac Paul on 6/3/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKMappingResult;

@interface RestkitRequestReponse : NSObject

@property (assign, nonatomic) BOOL successful;
@property (strong, nonatomic) RKMappingResult* mappingResult;
@property (strong, nonatomic) NSError* error;

@end
