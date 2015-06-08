//
//  BasePickerViewAdapter.m
//  Filtacular
//
//  Created by John Li on 6/3/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "BasePickerViewAdapter.h"
#import "PickerObject.h"

@interface BasePickerViewAdapter()

@end

@implementation BasePickerViewAdapter

- (void)bind:(UIPickerView*)pickerView
{
    pickerView.delegate = self;
    pickerView.dataSource = self;
}

#pragma mark - Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_onItemSelected)
        _onItemSelected(_data[row]);
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    id object = _data[row];
    return [object stringForPicker];
}

#pragma mark - DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.data count];
}

@end
