//
//  VCFilters.m
//  Filtacular
//
//  Created by Isaac Paul on 8/17/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "VCFilters.h"
#import "VCTwitterFeed.h"
#import "CustomTableView.h"
#import "SimpleTitleCell.h"

#import "UIView+Positioning.h"

#import <IIViewDeckController.h>

@interface VCFilters ()
@property (strong, nonatomic) IBOutlet CustomTableView *tableFilters;

@end

@implementation VCFilters

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_tableFilters addTableCellClass:[SimpleTitleCell class] forDataType:[TitleObject class]];
    [_tableFilters setNoItemText:@"No Filters."];
    __weak VCFilters* weakSelf = self;
    [_tableFilters setSelectObjectBlock:^(TitleObject* object) {
        NSString* filter = (NSString*)object.associatedObj;
        VCFilters* strongSelf = weakSelf;
        NSLog(@"Selected: %@", object);
        [strongSelf.viewDeckController toggleRightViewAnimated:true];
        [strongSelf.twitterFeed showFilter:filter];
        strongSelf.selectedFilter = filter;
        [strongSelf showFilters:strongSelf.filters];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:filter forKey:@"lastSelectedFilter"];
        [defaults synchronize];
    }];
    [self showFilters:_filters];
}

- (void)showFilters:(NSArray*)filters {
    NSMutableArray* cellData = [[NSMutableArray alloc] initWithCapacity:filters.count];
    for (NSString* eachFilter in filters) {
        TitleObject* titleObj = [TitleObject new];
        titleObj.title = eachFilter;
        titleObj.isBold = ([eachFilter isEqualToString:self.selectedFilter]);
        titleObj.associatedObj = eachFilter;
        [cellData addObject:titleObj];
    }
    [_tableFilters loadData:cellData];
}

@end
