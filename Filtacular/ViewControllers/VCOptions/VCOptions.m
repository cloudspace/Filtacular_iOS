//
//  VCOptions.m
//  Filtacular
//
//  Created by Isaac Paul on 8/12/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "VCOptions.h"
#import "VCTwitterFeed.h"
#import "CustomTableView.h"
#import "SimpleTitleCell.h"
#import "User.h"

#import "UIView+Positioning.h"

#import <OAStackView.h>
#import <TwitterKit/TwitterKit.h>

@interface VCOptions () <UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UILabel              *lblUser;
@property (strong, nonatomic) IBOutlet UILabel              *lblFilter;
@property (strong, nonatomic) IBOutlet UISearchBar          *searchBarUsers;
@property (strong, nonatomic) IBOutlet CustomTableView      *tableUsers;
@property (strong, nonatomic) IBOutlet CustomTableView      *tableFilters;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint   *lcUserTableHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint   *lcFilterTableHeight;
@property (strong, nonatomic) IBOutlet UIView               *viewUserTableContainer;
@property (strong, nonatomic) IBOutlet UIView               *viewFilterTableContainer;
@property (strong, nonatomic) IBOutlet UIView               *stackContent;
@property (strong, nonatomic) IBOutlet UIView               *viewTableHeight;
@property (strong, nonatomic) IBOutlet UIButton             *btnLogout;
@property (strong, nonatomic) IBOutlet UIScrollView         *scrollView;

@property (strong, nonatomic) NSArray* filteredUsers;

@end

//    if (_lastUser != _selectedUser) {
//        [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Viewed User: %@", _selectedUser.nickname]];
//    }
//
//    if ([_lastFilter isEqualToString:_selectedFilter] == false) {
//        [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Viewed Filter: %@", _selectedFilter]];
//    }

@implementation VCOptions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_lblUser   setText:[NSString stringWithFormat:@"User: %@"  , _selectedUser.stringForPicker]];
    [_lblFilter setText:[NSString stringWithFormat:@"Filter: %@", _selectedFilter]];
    
    [_tableUsers addTableCellClass:[SimpleTitleCell class] forDataType:[User class]];
    [_tableUsers setNoItemText:@"No Users."];
    __weak VCOptions* weakSelf = self;
    [_tableUsers setSelectObjectBlock:^(User* object) {
        VCOptions* strongSelf = weakSelf;
        NSLog(@"Selected: %@", object.displayName);
        [strongSelf tapUser];
        [strongSelf.twitterFeed showUser:object];
        [strongSelf.lblUser setText:[NSString stringWithFormat:@"User: %@", object.stringForPicker]];
    }];
    [_tableUsers loadData:_users];
    
    [_tableFilters addTableCellClass:[SimpleTitleCell class] forKey:@"__NSCFString"];
    [_tableFilters setNoItemText:@"No Filters."];
    [_tableFilters setSelectObjectBlock:^(NSString* object) {
        VCOptions* strongSelf = weakSelf;
        NSLog(@"Selected: %@", object);
        [strongSelf tapFilter];
        [strongSelf.twitterFeed showFilter:object];
        [strongSelf.lblFilter setText:[NSString stringWithFormat:@"Filter: %@", object]];
    }];
    [_tableFilters loadData:_filters];
}

- (void)setUsers:(NSArray *)users {
    _users = users;
}

- (IBAction)tapLogout {
    [[Twitter sharedInstance] logOut];
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)tapUser {
    [self toggleTable:_viewUserTableContainer tableHeightConstraint:_lcUserTableHeight numItems:_users.count];
}

- (IBAction)tapFilter {
    [self toggleTable:_viewFilterTableContainer tableHeightConstraint:_lcFilterTableHeight numItems:_filters.count];
}

- (void)toggleTable:(UIView*)tableContainer tableHeightConstraint:(NSLayoutConstraint*)tableHeight numItems:(NSUInteger)numItems {
    
    bool isTableVisible = (tableContainer.height > 0);
    if (isTableVisible) {
        [UIView animateWithDuration:0.33f animations:^{
            tableHeight.constant = 0.0f;
            [self.view layoutIfNeeded];
        }];
    }
    else {
        [UIView animateWithDuration:0.33f animations:^{
            CGFloat newHeight = _viewTableHeight.height;
//            CGFloat calcHeight = numItems * 54.0f;
//            if (calcHeight < newHeight)
//                newHeight = calcHeight;
//            if (newHeight < 108.0f)
//                newHeight = 108.0f;
//            
            tableHeight.constant = newHeight;
            _scrollView.contentOffset = CGPointMake(0.0f, tableContainer.y - 54.0f);
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self performSelector:@selector(updateTableWithFilter:) withObject:searchText afterDelay:0.33f];
}

- (void)updateTableWithFilter:(NSString*)filterText {
    if (filterText.length == 0) {
        [_tableUsers loadData:_users];
        return;
    }
    NSPredicate* entriesMatchingValue = [NSPredicate predicateWithFormat:@"stringForPicker CONTAINS[cd] %@", filterText];
    _filteredUsers = [_users filteredArrayUsingPredicate:entriesMatchingValue];
    [_tableUsers loadData:_filteredUsers];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


@end
