//
//  LoadingCallBack.h
//  Filtacular
//
//  Created by Isaac Paul on 6/19/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "BaseUnmanagedModel.h"

@interface LoadingCallBack : BaseUnmanagedModel

@property (nonatomic, copy) void (^isShown) ();

@end
