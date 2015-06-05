//
//  JSONRequestOperation.h
//  Filtacular
//
//  Created by Isaac Paul on 6/5/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "AFJSONRequestOperation.h"

/*! We need a custom class to specify that "application/vnd.api+json" is an acceptable content type*/
@interface JSONRequestOperation : AFJSONRequestOperation

@end
