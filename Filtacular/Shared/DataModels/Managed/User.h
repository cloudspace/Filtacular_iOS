//
//  User.h
//  Filtacular
//
//  Created by John Li on 6/2/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "BaseManagedModel.h"
#import "PickerObject.h"

@interface User : BaseManagedModel <PickerObject>

@property (nonatomic, assign) int identifier;
@property (nonatomic, assign) NSString* userId;//twitterId
@property (nonatomic, strong) NSString* nickname;
@property (nonatomic, strong) NSString* name;

+ (RKEntityMapping*)entityMappingWithStore:(RKManagedObjectStore*)store;
+ (NSArray*)pseudoUsers;
- (NSString*)displayName;
- (NSString*)stringForPicker;
- (NSString*)sortingName;

@end
