//
//  STTwitterOS.h
//  STTwitter
//
//  Created by Nicolas Seriot on 5/1/10.
//  Copyright 2010 seriot.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitterProtocol.h"

extern NS_ENUM(NSUInteger, STTwitterOSErrorCode) {
    STTwitterOSSystemCannotAccessTwitter = 0,
    STTwitterOSCannotFindTwitterAccount,
    STTwitterOSUserDeniedAccessToTheirAccounts,
    STTwitterOSNoTwitterAccountIsAvailable,
    STTwitterOSTwitterAccountInvalid
};

@class ACAccount;

extern const NSString *STTwitterOSInvalidatedAccount;

@interface STTwitterOS : NSObject <STTwitterProtocol>

@property (nonatomic) NSTimeInterval timeoutInSeconds;

+ (instancetype)twitterAPIOSWithAccount:(ACAccount *)account;

- (NSString *)username;
- (NSString *)userID;


@end
