//
//  PickerObject.h
//  Filtacular
//
//  Created by Isaac Paul on 6/8/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PickerObject <NSObject>

- (NSString*)stringForPicker;

@end


@interface NSString (PickerObject) <PickerObject>

@end