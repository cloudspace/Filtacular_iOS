//
//  FilterPickerViewAdapter.m
//  Filtacular
//
//  Created by John Li on 6/4/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "FilterPickerViewAdapter.h"
#import "FilterPickerViewDelegate.h"
#import "FilterPickerDataSource.h"

@implementation FilterPickerViewAdapter

-(id) init
{
    self = [super init];
    if(self)
    {
        self.pickerViewDelegate = [FilterPickerViewDelegate new];
        self.pickerViewDataSource = [FilterPickerDataSource new];
    }
    return self;
}

@end
