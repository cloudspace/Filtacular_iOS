//
//  UserPickerViewDelegate.m
//  Filtacular
//
//  Created by John Li on 6/3/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "UserPickerViewDelegate.h"
#import "User.h"

@interface UserPickerViewDelegate()

@property (nonatomic, strong) NSArray* users;

@end

@implementation UserPickerViewDelegate


-(void) reload:(NSArray *)data
{
    _users = data;
}

#pragma mark - UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView
     didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    User* user = self.users[row];
    NSLog(@"Pressed on %@", user.nickname);
}

-(NSString *)pickerView:(UIPickerView *)pickerView
            titleForRow:(NSInteger)row
           forComponent:(NSInteger)component
{
    User* user =self.users[row];
    return user.nickname;
}


@end
