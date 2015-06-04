//
//  FilterPickerDataSource.m
//  Filtacular
//
//  Created by John Li on 6/4/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "FilterPickerDataSource.h"

@interface FilterPickerDataSource()

@property (nonatomic, strong) NSArray* filters;

@end

@implementation FilterPickerDataSource

#pragma mark - UIPickerViewDataSource Protocol

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.filters count];
}

-(void) reload:(NSArray *)data
{
    _filters = data;
}


@end
