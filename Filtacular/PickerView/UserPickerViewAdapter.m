//
//  UserPickerView.m
//  Filtacular
//
//  Created by John Li on 6/3/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "UserPickerViewAdapter.h"
#import "UserPickerViewDelegate.h"
#import "UserPickerDataSource.h"

@interface UserPickerViewAdapter()

@property (nonatomic, strong) NSArray* users;

@end

@implementation UserPickerViewAdapter

-(id) init
{
    self = [super init];
    if(self)
    {
        self.pickerViewDelegate = [UserPickerViewDelegate new];
        self.pickerViewDataSource = [UserPickerDataSource new];
    }
    return self;
}

-(void) bind: (UIPickerView*) pickerView
{
    pickerView.delegate = self.pickerViewDelegate;
    pickerView.dataSource = self.pickerViewDataSource;
}

-(void) setData:(NSArray *)data
{
    [self.pickerViewDelegate reload: data];
    [self.pickerViewDataSource reload: data];
}

@end
