//
//  UIAlertView+Shortcuts.h
//  IsaacsIOSLibrary
//
//  Created by IsaacPaul on 10/29/13.
//  Copyright (c) 2013 Isaac Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Shortcuts)

+ (UIAlertView*)showAlertWithTitle:(NSString*)title andMessage:(NSString*)message;
+ (UIAlertView*)showMessage:(NSString*)message;
+ (UIAlertView*)showNotice:(NSString*)message;
+ (UIAlertView*)showError:(NSError*)error;
+ (UIAlertView*)showQuestion:(NSString*)message;

@end
