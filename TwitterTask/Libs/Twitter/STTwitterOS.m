//
//  STTwitterOS.m
//  STTwitter
//
//  Created by Nicolas Seriot on 5/1/10.
//  Copyright 2010 seriot.ch. All rights reserved.
//

#import "STTwitterOS.h"
#import "STTwitterOSRequest.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "NSError+STTwitter.h"
#if TARGET_OS_IPHONE
#import <Twitter/Twitter.h> // iOS 5
#endif

const NSString *STTwitterOSInvalidatedAccount = @"STTwitterOSInvalidatedAccount";

@interface ACAccount (STTwitterOS)
- (NSString *)st_userID; // private API
@end

@interface STTwitterOS ()
@property (nonatomic, strong) ACAccountStore *accountStore; // the ACAccountStore must be kept alive for as long as we need an ACAccount instance, see WWDC 2011 Session 124 for more info
@property (nonatomic, strong) ACAccount *account; // if nil, will be set to first account available
@end

@implementation STTwitterOS

- (instancetype)init {
    self = [super init];
    
    self.accountStore = [[ACAccountStore alloc] init];
    
    return self;
}

- (instancetype)initWithAccount:(ACAccount *) account {
    self = [super init];
    self.accountStore = [[ACAccountStore alloc] init];
    self.account = account;
    return self;
}

+ (instancetype)twitterAPIOSWithAccount:(ACAccount *)account {
    return [[self alloc] initWithAccount:account];
}

- (NSString *)username {
    return self.account.username;
}

- (NSString *)userID {
    return [self.account st_userID];
}

- (NSString *)consumerName {
#if TARGET_OS_IPHONE
    return @"iOS";
#else
    return @"OS X";
#endif
}

- (NSString *)loginTypeDescription {
    return @"System";
}

- (void)verifyCredentialsRemotelyWithSuccessBlock:(void(^)(NSString *username, NSString *userID))successBlock
                                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    __weak typeof(self) weakSelf = self;
    
    [self fetchResource:@"account/verify_credentials.json"
             HTTPMethod:@"GET"
          baseURLString:@"https://api.twitter.com/1.1"
             parameters:nil
    uploadProgressBlock:nil
  downloadProgressBlock:nil
           successBlock:^(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
               
               __strong typeof(weakSelf) strongSelf = weakSelf;
               if(strongSelf == nil) return;
               
               if([response isKindOfClass:[NSDictionary class]] == NO) {
                   NSString *errorDescription = [NSString stringWithFormat:@"Expected dictionary, found %@", response];
                   NSError *error = [NSError errorWithDomain:NSStringFromClass([strongSelf class]) code:0 userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
                   errorBlock(error);
                   return;
               }
               
               NSDictionary *dict = response;
               successBlock(dict[@"screen_name"], dict[@"id_str"]);
           } errorBlock:^(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
               
               // add recovery suggestion if we can
               if([[error domain] isEqualToString:kSTTwitterTwitterErrorDomain] && ([error code] == 220)) {
                   NSMutableDictionary *extendedUserInfo = [[error userInfo] mutableCopy];
                   extendedUserInfo[NSLocalizedRecoverySuggestionErrorKey] = @"Consider entering the Twitter credentials again in OS Settings.";
                   NSError *extendedError = [NSError errorWithDomain:[error domain] code:[error code] userInfo:extendedUserInfo];
                   errorBlock(extendedError);
                   return;
               }
               
               errorBlock(error);
           }];
}

- (BOOL)hasAccessToTwitter {
    
#if !TARGET_OS_IPHONE
    return YES;
#else
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) {
        return [TWTweetComposeViewController canSendTweet]; // iOS 5
    } else {
        return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
    }
#else
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
#endif
    
#endif
}

- (void)verifyCredentialsLocallyWithSuccessBlock:(void(^)(NSString *username, NSString *userID))successBlock errorBlock:(void(^)(NSError *error))errorBlock {
    
    if([self hasAccessToTwitter] == NO) {
        NSString *message = @"This system cannot access Twitter.";
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterOSSystemCannotAccessTwitter userInfo:@{NSLocalizedDescriptionKey : message}];
        errorBlock(error);
        return;
    }
    
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    if(accountType == nil) {
        NSString *message = @"Cannot find Twitter account.";
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterOSCannotFindTwitterAccount userInfo:@{NSLocalizedDescriptionKey : message}];
        errorBlock(error);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreRequestCompletionHandler = ^(BOOL granted, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            __strong typeof(self) strongSelf = weakSelf;
            
            if(strongSelf == nil) return;
            
            if(granted == NO) {
                
                if(error) {
                    errorBlock(error);
                    return;
                }
                
                NSString *message = @"User denied access to their account(s).";
                NSError *grantError = [NSError errorWithDomain:NSStringFromClass([strongSelf class]) code:STTwitterOSUserDeniedAccessToTheirAccounts userInfo:@{NSLocalizedDescriptionKey : message}];
                errorBlock(grantError);
                return;
            }
            
            ACAccount *formerAccount = strongSelf.account;
            NSString *previouslyStoredUsername = strongSelf.account.username;
            
            NSArray *accounts = [strongSelf.accountStore accountsWithAccountType:accountType];
            
            if([accounts count] == 0) {
                NSString *message = @"No Twitter account available.";
                NSError *error = [NSError errorWithDomain:NSStringFromClass([strongSelf class]) code:STTwitterOSNoTwitterAccountIsAvailable userInfo:@{NSLocalizedDescriptionKey : message}];
                errorBlock(error);
                return;
            }
            
            __block BOOL accountFound = NO;
            [accounts enumerateObjectsUsingBlock:^(ACAccount *account, NSUInteger idx, BOOL *stop) {
                
                // ignore accounts that have no indentifier
                // possible workaround for accounts with no password stored
                // see https://twittercommunity.com/t/ios-6-twitter-accounts-with-no-password-stored/6183
                if([[account identifier] length] == 0) {
                    NSLog(@"-- ignore account %@ because identifier is empty", account);
                    return;
                }
                
                // see https://github.com/nst/STTwitter/issues/228
                BOOL noAccountWasSetYet = previouslyStoredUsername == NULL;
                BOOL canUseAccountWithSameUsernameAsBeforeAccountInvalidation = [account.username isEqualToString:previouslyStoredUsername];
                if(noAccountWasSetYet || canUseAccountWithSameUsernameAsBeforeAccountInvalidation) {
                    strongSelf.account = account;
                    *stop = YES;
                    accountFound = YES;
                    successBlock(strongSelf.account.username, [strongSelf.account st_userID]);
                    return;
                }
            }];
            
            if(accountFound) return;
            
            NSString *message = [NSString stringWithFormat:@"Twitter account is invalid: %@", previouslyStoredUsername];
            NSMutableDictionary *userInfo = [ @{NSLocalizedDescriptionKey:message} mutableCopy];
            if(formerAccount) userInfo[STTwitterOSInvalidatedAccount] = formerAccount;
            NSError *error = [NSError errorWithDomain:NSStringFromClass([strongSelf class]) code:STTwitterOSTwitterAccountInvalid userInfo:userInfo];
            errorBlock(error);
        }];
    };
    
#if TARGET_OS_IPHONE &&  (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                     withCompletionHandler:accountStoreRequestCompletionHandler];
    } else {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                                   options:NULL
                                                completion:accountStoreRequestCompletionHandler];
    }
#else
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:accountStoreRequestCompletionHandler];
#endif
}



+ (SLRequestMethod)slRequestMethodForString:(NSString *)HTTPMethod {
    if([HTTPMethod isEqualToString:@"POST"]) return SLRequestMethodPOST;
    if([HTTPMethod isEqualToString:@"PUT"]) return SLRequestMethodPUT;
    if([HTTPMethod isEqualToString:@"DELETE"]) return SLRequestMethodDELETE;
    if([HTTPMethod isEqualToString:@"GET"] == NO) {
        NSAssert(NO, @"Unsupported HTTP method");
    }
    return SLRequestMethodGET;
}

- (NSObject<STTwitterRequestProtocol> *)fetchResource:(NSString *)resource
                                           HTTPMethod:(NSString *)HTTPMethod
                                        baseURLString:(NSString *)baseURLString
                                           parameters:(NSDictionary *)params
                                  uploadProgressBlock:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))uploadProgressBlock
                                downloadProgressBlock:(void (^)(NSObject<STTwitterRequestProtocol> *request, NSData *data))progressBlock // FIXME: how to handle progressBlock?
                                         successBlock:(void (^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response))successBlock
                                           errorBlock:(void (^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock {
    
    NSInteger slRequestMethod = [[self class] slRequestMethodForString:HTTPMethod];
    
    NSDictionary *d = params;
    
    if([HTTPMethod isEqualToString:@"GET"] == NO) {
        if (d == nil) d = @{};
    }
    
    NSString *baseURLStringWithTrailingSlash = baseURLString;
    if([baseURLString hasSuffix:@"/"] == NO) {
        baseURLStringWithTrailingSlash = [baseURLString stringByAppendingString:@"/"];
    }
    
    STTwitterOSRequest *r = [[STTwitterOSRequest alloc] initWithAPIResource:resource
                                                              baseURLString:baseURLStringWithTrailingSlash
                                                                 httpMethod:slRequestMethod
                                                                 parameters:d
                                                                    account:_account
                                                           timeoutInSeconds:_timeoutInSeconds
                                                        uploadProgressBlock:uploadProgressBlock
                                                                streamBlock:progressBlock
                                                            completionBlock:successBlock
                                                                 errorBlock:errorBlock];
    [r startRequest];
    
    return r;
}

+ (NSDictionary *)parametersDictionaryFromCommaSeparatedParametersString:(NSString *)s {
    
    NSArray *parameters = [s componentsSeparatedByString:@", "];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    for(NSString *parameter in parameters) {
        // transform k="v" into {'k':'v'}
        
        NSArray *keyValue = [parameter componentsSeparatedByString:@"="];
        if([keyValue count] != 2) {
            continue;
        }
        
        NSString *value = [keyValue[1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        [md setObject:value forKey:keyValue[0]];
    }
    
    return md;
}

// TODO: this code is duplicated from STTwitterOAuth
+ (NSDictionary *)parametersDictionaryFromAmpersandSeparatedParameterString:(NSString *)s {
    
    NSArray *parameters = [s componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    for(NSString *parameter in parameters) {
        NSArray *keyValue = [parameter componentsSeparatedByString:@"="];
        if([keyValue count] != 2) {
            continue;
        }
        
        [md setObject:keyValue[1] forKey:keyValue[0]];
    }
    
    return md;
}

@end

@implementation ACAccount (STTwitterOS)

- (NSString *)st_userID {
    return [self valueForKeyPath:@"properties.user_id"];
}

@end