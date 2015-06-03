//
//  ServerWrapper.h
//  Filtacular
//
//  Created by Isaac Paul on 10/14/14.
//  Copyright (c) 2014 CloudSpace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "RestkitRequest.h"
#import "RestkitRequestReponse.h"

/*! See RKObjectManager for documentation on REST methods */
@interface ServerWrapper : NSObject

+ (ServerWrapper*)sharedInstance;
/*! Make a sync requests inside this queue */
+ (dispatch_queue_t)requestQueue;

- (void)performRequest:(RestkitRequest*)request;
- (RestkitRequestReponse*)performSyncRequest:(RestkitRequest*)request;
- (RestkitRequestReponse*)performSyncGet:(NSString*)path;

@end

