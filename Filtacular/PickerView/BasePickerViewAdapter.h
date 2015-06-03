//
//  BasePickerViewAdapter.h
//  Filtacular
//
//  Created by John Li on 6/3/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Reloadable.h"

@interface BasePickerViewAdapter : NSObject

@property id<UIPickerViewDelegate, Reloadable> pickerViewDelegate;
@property id<UIPickerViewDataSource, Reloadable> pickerViewDataSource;

-(void) bind: (UIPickerView*) pickerView;

-(void) setData : (NSArray*) data;

@end
