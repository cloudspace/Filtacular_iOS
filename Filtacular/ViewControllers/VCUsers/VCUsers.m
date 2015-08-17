//
//  VCUsers.m
//  Filtacular
//
//  Created by Isaac Paul on 8/17/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "VCUsers.h"
#import "VCTwitterFeed.h"

#import "CustomTableView.h"

#import "SimpleTitleCell.h"
#import "User.h"

#import "UIView+Positioning.h"

#import <IIViewDeckController.h>

@interface VCUsers () <UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet CustomTableView *tableUsers;
@property (strong, nonatomic) NSNumber* tableHeight;
@property (strong, nonatomic) NSArray* lastDisplayedUsers;

@end

@implementation VCUsers

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [_tableUsers addTableCellClass:[SimpleTitleCell class] forDataType:[TitleObject class]];
    [_tableUsers setNoItemText:@"No Users."];
    
    __weak VCUsers* weakSelf = self;
    [_tableUsers setSelectObjectBlock:^(TitleObject* object) {
        User* userObj = (User*)object.associatedObj;
        VCUsers* strongSelf = weakSelf;
        NSLog(@"Selected: %@", userObj.displayName);
        [strongSelf.viewDeckController toggleLeftViewAnimated:true];
        [strongSelf.twitterFeed showUser:userObj];
        strongSelf.selectedUser = userObj;
        [strongSelf showUsers:strongSelf.lastDisplayedUsers]; //We reload to show the selected user
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:userObj.userId forKey:@"lastSelectedUser"];
        [defaults synchronize];
    }];
    [self showUsers:_users];
}

- (void)showUsers:(NSArray*)users {
    NSMutableArray* cellData = [[NSMutableArray alloc] initWithCapacity:users.count];
    for (User* eachUser in users) {
        TitleObject* titleObj = [TitleObject new];
        titleObj.title = [eachUser stringForPicker];
        titleObj.isBold = (eachUser == self.selectedUser);
        titleObj.associatedObj = eachUser;
        [cellData addObject:titleObj];
    }
    _lastDisplayedUsers = users;
    [_tableUsers loadData:cellData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self performSelector:@selector(updateTableWithFilter:) withObject:searchText afterDelay:0.33f];
}

- (void)updateTableWithFilter:(NSString*)filterText {
    if (filterText.length == 0) {
        [self showUsers:_users];
        return;
    }
    NSPredicate* entriesMatchingValue = [NSPredicate predicateWithFormat:@"stringForPicker CONTAINS[cd] %@", filterText];
    NSArray* filteredUsers = [_users filteredArrayUsingPredicate:entriesMatchingValue];
    [self showUsers:filteredUsers];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)inNotification {
    if (_tableHeight == nil)
        _tableHeight = @(_tableUsers.height);
    
    CGFloat height = [inNotification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    NSTimeInterval animationDuration = [inNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration animations:^{
        _tableUsers.height -= height;
    }];
}

- (void)keyboardWillHide:(NSNotification *)inNotification {
    NSTimeInterval animationDuration = [inNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration animations:^{
        _tableUsers.height = [_tableHeight floatValue];
    }];
}

@end
