//
//  UserPickerViewDelegate.h
//  Filtacular
//
//  Created by John Li on 6/3/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Reloadable.h"

@interface UserPickerViewDelegate : NSObject <UIPickerViewDelegate, Reloadable>

-(void) reload : (NSArray*) data;

@end
