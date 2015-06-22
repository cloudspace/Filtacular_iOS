//
//  NSError+URLError.m
//  IsaacsIOSLibrary
//
//  Created by Isaac Paul on 10/22/14.
//  Copyright (c) 2014 Isaac Paul. All rights reserved.
//

#import "NSError+URLError.h"

@implementation NSError (URLError)

- (bool)isConnectionError {
    return [NSError isConnectionError:self.code];
}

+ (bool)isConnectionError:(NSInteger)code {
    
    switch (code) {
        case kCFURLErrorBadURL:
        case kCFURLErrorTimedOut:
        case kCFURLErrorUnsupportedURL:
        case kCFURLErrorCannotFindHost:
        case kCFURLErrorCannotConnectToHost:
        case kCFURLErrorNetworkConnectionLost:
        case kCFURLErrorDNSLookupFailed:
        case kCFURLErrorNotConnectedToInternet:
        case kCFURLErrorRedirectToNonExistentLocation:
        case kCFURLErrorBadServerResponse:
            return true;
            
        default:
            return false;
    }
    return false;
}

- (NSString*)connectionErrorString {
    return [NSError connectionErrorStringForCode:self.code];
}

+ (NSString*)connectionErrorStringForCode:(NSInteger)code {
    switch (code) {
        case kCFURLErrorBadURL:
            return @"Error connecting to the server: Bad URL.";
        case kCFURLErrorTimedOut:
            return @"Error connecting to the server: Connection timed out.";
        case kCFURLErrorUnsupportedURL:
            return @"Error connecting to the server: Unsupported URL.";
        case kCFURLErrorCannotFindHost:
            return @"Error connecting to the server: Could not find host.";
        case kCFURLErrorCannotConnectToHost:
            return @"Error connecting to the server: Could not connect to host.";
        case kCFURLErrorNetworkConnectionLost:
            return @"Error connecting to the server: Network connection lost.";
        case kCFURLErrorDNSLookupFailed:
            return @"Error connecting to the server: DNS lookup failed.";
        case kCFURLErrorNotConnectedToInternet:
            return @"Error connecting to the server: Not connected to a network.";
        case kCFURLErrorRedirectToNonExistentLocation:
            return @"Error connecting to the server: Redirect to non existent location.";
        case kCFURLErrorBadServerResponse:
            return @"Error connecting to the server: Bad server response.";
            
        default:
            return nil;
    }
    
    return nil;
}

@end
