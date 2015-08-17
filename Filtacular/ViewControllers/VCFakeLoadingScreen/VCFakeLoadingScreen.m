//
//  VCFakeLoadingScreen.m
//  Filtacular
//
//  Created by Isaac Paul on 6/24/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "VCFakeLoadingScreen.h"
#import "IntroViewController.h"
#import "VCTwitterFeed.h"

#import <TwitterKit/TwitterKit.h>
#import <IIViewDeckController.h>

@interface VCFakeLoadingScreen ()

@property (strong, nonatomic) TWTRSession* session;

@end

@implementation VCFakeLoadingScreen

+ (VCFakeLoadingScreen*)buildWithSession:(TWTRSession*)session {
    UIView* view = nil;
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LaunchScreen" owner:nil options:nil];
    view = [topLevelObjects objectAtIndex:0];
    
    VCFakeLoadingScreen* vc = [VCFakeLoadingScreen new];
    vc.view = view;
    vc.session = session;
    return vc;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [IntroViewController loginToFiltacular:_session failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        IntroViewController* vc = [IntroViewController build];
        [self.navigationController setViewControllers:@[vc] animated:true];
    } success:^(UIViewController *mainScreen) {
        
        IntroViewController* vc = [IntroViewController build];

        [self.navigationController setViewControllers:@[vc, mainScreen] animated:true];
    }];
}

@end
