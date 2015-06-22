//
//  UIAlertView+Shortcuts.m
//  IsaacsIOSLibrary
//
//  Created by IsaacPaul on 10/29/13.
//  Copyright (c) 2013 Isaac Paul. All rights reserved.
//

#import "UIAlertView+Shortcuts.h"

static NSString* const cGenericTitle = @"Notice";
static NSString* const c0LengthMessageWarning = @"Warning: Trying to show a 0 length message";

@implementation UIAlertView (Shortcuts)

+ (UIAlertView*)showAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
    if (message.length == 0 && title.length == 0)
    {
        NSLog(c0LengthMessageWarning);
        return nil;
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert forceMainThreadShow];
    return alert;
}

+ (UIAlertView*)showMessage:(NSString*)message {
    if (message.length == 0)
    {
        NSLog(c0LengthMessageWarning);
        return nil;
    }

    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert forceMainThreadShow];
    return alert;
}

+ (UIAlertView*)showQuestion:(NSString*)message {
    if (message.length == 0)
    {
        NSLog(c0LengthMessageWarning);
        return nil;
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert forceMainThreadShow];
    return alert;
}

+ (UIAlertView*)showNotice:(NSString*)message {
    if (message.length == 0)
    {
        NSLog(c0LengthMessageWarning);
        return nil;
    }
    
    return [UIAlertView showAlertWithTitle:cGenericTitle andMessage:message];
}

+ (UIAlertView*)showError:(NSError*)error {
    NSString* title = [NSString stringWithFormat:@"Error code %li", (long)error.code];
    NSString* message = [error localizedDescription];
    return [self showAlertWithTitle:title andMessage:message];
}

- (void)forceMainThreadShow {
    if ([NSThread currentThread] == [NSThread mainThread])
        [self show];
    else
        [self performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:true];
}

@end
