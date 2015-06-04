//
//  FilterPickerViewDelegate.m
//  Filtacular
//
//  Created by John Li on 6/4/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "FilterPickerViewDelegate.h"
#import "Filter.h"

@interface FilterPickerViewDelegate()

@property NSArray* filters;

@end

@implementation FilterPickerViewDelegate

-(void) reload:(NSArray *)data
{
    _filters = data;
}

#pragma mark - UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView
     didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    self.onItemSelected(self.filters[row]);
}

-(NSString *)pickerView:(UIPickerView *)pickerView
            titleForRow:(NSInteger)row
           forComponent:(NSInteger)component
{
    Filter* filter =self.filters[row];
    return filter.displayName;
}

@end
