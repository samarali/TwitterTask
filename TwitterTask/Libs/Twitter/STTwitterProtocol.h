//
//  STOAuthProtocol.h
//  STTwitterRequests
//
//  Created by Nicolas Seriot on 9/18/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitterRequestProtocol.h"

@class STHTTPRequest;

@protocol STTwitterProtocol <NSObject>

@property (nonatomic) NSTimeInterval timeoutInSeconds;

// ensure that the Twitter account is usable by performing local access checks
- (void)verifyCredentialsLocallyWithSuccessBlock:(void(^)(NSString *username, NSString *userID))successBlock
                                      errorBlock:(void(^)(NSError *error))errorBlock;

// called after verifyCredentialsLocallyWithSuccessBlock: to ensure that the Twitter account is usable by Remote access
- (void)verifyCredentialsRemotelyWithSuccessBlock:(void(^)(NSString *username, NSString *userID))successBlock
                                       errorBlock:(void(^)(NSError *error))errorBlock;

- (NSObject<STTwitterRequestProtocol> *)fetchResource:(NSString *)resource
                                           HTTPMethod:(NSString *)HTTPMethod
                                        baseURLString:(NSString *)baseURLString
                                           parameters:(NSDictionary *)params
                                  uploadProgressBlock:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))uploadProgressBlock
                                downloadProgressBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSData *data))progressBlock
                                         successBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response))successBlock
                                           errorBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock;

- (NSString *)consumerName;
- (NSString *)loginTypeDescription;

@optional

- (void)postTokenRequest:(void(^)(NSURL *url, NSString *oauthToken))successBlock
authenticateInsteadOfAuthorize:(BOOL)authenticateInsteadOfAuthorize
              forceLogin:(NSNumber *)forceLogin
              screenName:(NSString *)screenName
           oauthCallback:(NSString *)oauthCallback
              errorBlock:(void(^)(NSError *error))errorBlock;

- (void)postAccessTokenRequestWithPIN:(NSString *)pin
                         successBlock:(void(^)(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock;

// access tokens are available only with plain OAuth authentication
- (NSString *)oauthAccessToken;
- (NSString *)oauthAccessTokenSecret;

@end
