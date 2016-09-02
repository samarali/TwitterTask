//
//  CommonFuntions.m
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

#import "CommonFuntions.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "LocalizedMessages.h"
#import "AppDelegate.h"


@implementation CommonFuntions

+ (BOOL)hasConnectivity{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                
                return YES;
            }
        }
    }
    
    return NO;
}

+ (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message {
    NSString * messageTitle = title ? title : ApplicationTitleText;
    [[[UIAlertView alloc] initWithTitle:messageTitle
                                message:message
                               delegate:nil
                      cancelButtonTitle:OKayButtonText
                      otherButtonTitles:nil] show];
}

+ (BOOL)isStringEmpty:(NSString *)string  {
    NSString *rawString = string;
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] == 0) {
        return YES;
    }
    return NO;
}

+ (BOOL)isStringNull:(NSString *)string  {
    if (string == nil) {
        return YES;
    }
    return NO;
}
+ (UIColor*)getTableCellBGColor_OddRow{
    return [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1];
    
}
+ (UIColor*)getTableCellBGColor_EvenRow{
    return [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1];
}



@end
