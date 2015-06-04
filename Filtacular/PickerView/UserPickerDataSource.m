//
//  UserPickerDataSource.m
//  Filtacular
//
//  Created by John Li on 6/3/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "UserPickerDataSource.h"

@interface UserPickerDataSource()

@property (nonatomic, strong) NSArray* users;

@end

@implementation UserPickerDataSource

#pragma mark - UIPickerViewDataSource Protocol

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.users count];
}

-(void) reload:(NSArray *)data
{
    _users = data;
}

@end
