//
//  BasePickerViewAdapter.h
//  Filtacular
//
//  Created by John Li on 6/3/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void (^ItemSelectedBlock)(id item);


@interface BasePickerViewAdapter : NSObject <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, copy) ItemSelectedBlock onItemSelected;
@property (nonatomic, strong) NSArray* data;

- (void)bind:(UIPickerView*)pickerView;

///Items should response to [instance pickerString]
- (void)setData:(NSArray*)data;

@end
