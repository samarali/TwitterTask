//
//  STTwitterAPI.m
//  STTwitterRequests
//
//  Created by Nicolas Seriot on 9/18/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI.h"
#import "STTwitterOS.h"
#import "STTwitterOAuth.h"
#import <Accounts/Accounts.h>
#import "STHTTPRequest.h"
#import "STHTTPRequest+STTwitter.h"

NSString *kBaseURLStringAPI_1_1 = @"https://api.twitter.com/1.1";
NSString *kBaseURLStringUpload_1_1 = @"https://upload.twitter.com/1.1";
NSString *kBaseURLStringStream_1_1 = @"https://stream.twitter.com/1.1";
NSString *kBaseURLStringUserStream_1_1 = @"https://userstream.twitter.com/1.1";
NSString *kBaseURLStringSiteStream_1_1 = @"https://sitestream.twitter.com/1.1";

static NSDateFormatter *dateFormatter = nil;

@interface STTwitterAPI ()
@property (nonatomic, strong) NSObject <STTwitterProtocol> *oauth;
@property (nonatomic, weak) NSObject <STTwitterAPIOSProtocol> *delegate;
@property (nonatomic, weak) id observer;
@end

@implementation STTwitterAPI

- (instancetype)init {
    self = [super init];
    
    __weak typeof(self) weakSelf = self;
    
    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:ACAccountStoreDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        if(weakSelf == nil) return;
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if([strongSelf.oauth isKindOfClass:[STTwitterOS class]]) {
            
            STTwitterOS *twitterOS = (STTwitterOS *)[strongSelf oauth];
            
            [twitterOS verifyCredentialsLocallyWithSuccessBlock:^(NSString *username, NSString *userID) {
                NSLog(@"-- account is still valid: %@", username);
            } errorBlock:^(NSError *error) {
                
                if([[error domain] isEqualToString:@"STTwitterOS"]) {
                    NSString *invalidatedAccount = [error userInfo][STTwitterOSInvalidatedAccount];
                    [strongSelf.delegate twitterAPI:strongSelf accountWasInvalidated:(ACAccount *)invalidatedAccount];
                }
                
            }];
        }
    }];
    
    NSLog(@"-- %@", _observer);
    
    return self;
}

- (void)dealloc {
    self.oauth = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:_observer name:ACAccountStoreDidChangeNotification object:nil];
    
    self.delegate = nil;
    self.observer = nil;
}

+ (instancetype)twitterAPIOSWithAccount:(ACAccount *)account delegate:(NSObject <STTwitterAPIOSProtocol> *)delegate {
    STTwitterAPI *twitter = [[STTwitterAPI alloc] init];
    twitter.oauth = [STTwitterOS twitterAPIOSWithAccount:account];
    twitter.delegate = delegate;
    return twitter;
}


+ (instancetype)twitterAPIWithOAuthConsumerKey:(NSString *)consumerKey
                                consumerSecret:(NSString *)consumerSecret
                                    oauthToken:(NSString *)oauthToken
                              oauthTokenSecret:(NSString *)oauthTokenSecret {

    STTwitterAPI *twitter = [[STTwitterAPI alloc] init];
    
    twitter.oauth = [STTwitterOAuth twitterOAuthWithConsumerKey:consumerKey
                                                  consumerSecret:consumerSecret
                                                      oauthToken:oauthToken
                                                oauthTokenSecret:oauthTokenSecret];
    
    return twitter;
}


- (NSDateFormatter *)dateFormatter {
    if(dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:SS'Z'"];
    }
    return dateFormatter;
}

- (void)postTokenRequest:(void(^)(NSURL *url, NSString *oauthToken))successBlock
authenticateInsteadOfAuthorize:(BOOL)authenticateInsteadOfAuthorize
              forceLogin:(NSNumber *)forceLogin screenName:(NSString *)screenName
           oauthCallback:(NSString *)oauthCallback
              errorBlock:(void(^)(NSError *error))errorBlock {
    
    [_oauth postTokenRequest:successBlock
authenticateInsteadOfAuthorize:authenticateInsteadOfAuthorize
                  forceLogin:forceLogin
                  screenName:screenName
               oauthCallback:oauthCallback
                  errorBlock:errorBlock];
}

- (void)postAccessTokenRequestWithPIN:(NSString *)pin
                         successBlock:(void(^)(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock {
    [_oauth postAccessTokenRequestWithPIN:pin
                             successBlock:successBlock
                               errorBlock:errorBlock];
}

- (void)verifyCredentialsWithUserSuccessBlock:(void(^)(NSDictionary *account))successBlock errorBlock:(void(^)(NSError *error))errorBlock {
    
    __weak typeof(self) weakSelf = self;
    
    [_oauth verifyCredentialsLocallyWithSuccessBlock:^(NSString *username, NSString *userID) {
        
        __strong typeof(self) strongSelf = weakSelf;
        if(strongSelf == nil) {
            errorBlock(nil);
            return;
        }
        
        if(username) [strongSelf setUserName:username];
        if(userID) [strongSelf setUserID:userID];
        
        [_oauth verifyCredentialsRemotelyWithSuccessBlock:^(NSDictionary *account) {
            
            if(strongSelf == nil) {
                errorBlock(nil);
                return;
            }
            
            [strongSelf setUserName:[account objectForKey:@"screen_name"]];
            [strongSelf setUserID:[account objectForKey:@"id_str"]];
            
            successBlock(account);
        } errorBlock:^(NSError *error) {
            errorBlock(error);
        }];
        
    } errorBlock:^(NSError *error) {
        errorBlock(error); // early, local detection of account issues, eg. incomplete OS account
    }];
}


- (NSString *)oauthAccessTokenSecret {
    if([_oauth respondsToSelector:@selector(oauthAccessTokenSecret)]) {
        return [_oauth oauthAccessTokenSecret];
    }
    return nil;
}

- (NSString *)oauthAccessToken {
    if([_oauth respondsToSelector:@selector(oauthAccessToken)]) {
        return [_oauth oauthAccessToken];
    }
    return nil;
}


- (NSString *)userName {
    
    if([_oauth isKindOfClass:[STTwitterOS class]]) {
        STTwitterOS *twitterOS = (STTwitterOS *)_oauth;
        return twitterOS.username;
    }
    
    return _userName;
}

- (NSString *)userID {
    
    if([_oauth isKindOfClass:[STTwitterOS class]]) {
        STTwitterOS *twitterOS = (STTwitterOS *)_oauth;
        return twitterOS.userID;
    }
    
    return _userID;
}

/**/

#pragma mark Generic methods to GET and POST

- (NSObject<STTwitterRequestProtocol> *)fetchResource:(NSString *)resource
                                           HTTPMethod:(NSString *)HTTPMethod
                                        baseURLString:(NSString *)baseURLString
                                           parameters:(NSDictionary *)params
                                  uploadProgressBlock:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))uploadProgressBlock
                                downloadProgressBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSData *data))downloadProgressBlock
                                         successBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response))successBlock
                                           errorBlock:(void(^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock {
    
    return [_oauth fetchResource:resource
                      HTTPMethod:HTTPMethod
                   baseURLString:baseURLString
                      parameters:params
             uploadProgressBlock:uploadProgressBlock
           downloadProgressBlock:downloadProgressBlock
                    successBlock:successBlock
                      errorBlock:errorBlock];
}


#pragma mark Timelines

/**/

- (NSObject<STTwitterRequestProtocol> *)getStatusesHomeTimelineWithCount:(NSString *)count
                                                                 sinceID:(NSString *)sinceID
                                                                   maxID:(NSString *)maxID
                                                                trimUser:(NSNumber *)trimUser
                                                          excludeReplies:(NSNumber *)excludeReplies
                                                      contributorDetails:(NSNumber *)contributorDetails
                                                         includeEntities:(NSNumber *)includeEntities
                                                            successBlock:(void(^)(NSArray *statuses))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(count) md[@"count"] = count;
    if(sinceID) md[@"since_id"] = sinceID;
    if(maxID) md[@"max_id"] = maxID;
    
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    if(excludeReplies) md[@"exclude_replies"] = [excludeReplies boolValue] ? @"1" : @"0";
    if(contributorDetails) md[@"contributor_details"] = [contributorDetails boolValue] ? @"1" : @"0";
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    
    return [_oauth fetchResource:@"statuses/home_timeline.json"
                      HTTPMethod:@"GET"
                   baseURLString:kBaseURLStringAPI_1_1
                      parameters:md
             uploadProgressBlock:nil
           downloadProgressBlock:nil
                    successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
                        if(successBlock)
                            successBlock(response);
                    } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                        if(errorBlock) errorBlock(error);
                    }];
}


- (NSObject<STTwitterRequestProtocol> *)getHomeTimelineSinceID:(NSString *)sinceID
                                                         count:(NSUInteger)count
                                                  successBlock:(void(^)(NSArray *statuses))successBlock
                                                    errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSString *countString = count > 0 ? [@(count) description] : nil;
    
    return [self getStatusesHomeTimelineWithCount:countString
                                          sinceID:sinceID
                                            maxID:nil
                                         trimUser:nil
                                   excludeReplies:nil
                               contributorDetails:nil
                                  includeEntities:nil
                                     successBlock:^(NSArray *statuses) {
                                         successBlock(statuses);
                                     } errorBlock:^(NSError *error) {
                                         errorBlock(error);
                                     }];
}

- (NSObject<STTwitterRequestProtocol> *)getStatusesUserTimelineForUserID:(NSString *)userID
                                                              screenName:(NSString *)screenName
                                                                 sinceID:(NSString *)sinceID
                                                                   count:(NSString *)count
                                                                   maxID:(NSString *)maxID
                                                                trimUser:(NSNumber *)trimUser
                                                          excludeReplies:(NSNumber *)excludeReplies
                                                      contributorDetails:(NSNumber *)contributorDetails
                                                         includeRetweets:(NSNumber *)includeRetweets
                                                            successBlock:(void(^)(NSArray *statuses))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(sinceID) md[@"since_id"] = sinceID;
    if(count) md[@"count"] = count;
    if(maxID) md[@"max_id"] = maxID;
    
    if(trimUser) md[@"trim_user"] = [trimUser boolValue] ? @"1" : @"0";
    if(excludeReplies) md[@"exclude_replies"] = [excludeReplies boolValue] ? @"1" : @"0";
    if(contributorDetails) md[@"contributor_details"] = [contributorDetails boolValue] ? @"1" : @"0";
    if(includeRetweets) md[@"include_rts"] = [includeRetweets boolValue] ? @"1" : @"0";
    
    
    return [_oauth fetchResource:@"statuses/user_timeline.json"
                      HTTPMethod:@"GET"
                   baseURLString:kBaseURLStringAPI_1_1
                      parameters:md
             uploadProgressBlock:nil
           downloadProgressBlock:nil
                    successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
                        if(successBlock)
                            successBlock(response);
                    } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                        if(errorBlock) errorBlock(error);
                    }];
}

#pragma mark Friends & Followers

- (NSObject<STTwitterRequestProtocol> *)getFriendsListForUserID:(NSString *)userID
                                                   orScreenName:(NSString *)screenName
                                                         cursor:(NSString *)cursor
                                                          count:(NSString *)count
                                                     skipStatus:(NSNumber *)skipStatus
                                            includeUserEntities:(NSNumber *)includeUserEntities
                                                   successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                                                     errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(cursor) md[@"cursor"] = cursor;
    if(count) md[@"count"] = count;
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    if(includeUserEntities) md[@"include_user_entities"] = [includeUserEntities boolValue] ? @"1" : @"0";
    
    return [_oauth fetchResource:@"friends/list.json"
                      HTTPMethod:@"GET"
                   baseURLString:kBaseURLStringAPI_1_1
                      parameters:md
             uploadProgressBlock:nil
           downloadProgressBlock:nil
                    successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
                        NSArray *users = nil;
                        NSString *previousCursor = nil;
                        NSString *nextCursor = nil;
                        
                        if([response isKindOfClass:[NSDictionary class]]) {
                            users = [response valueForKey:@"users"];
                            previousCursor = [response valueForKey:@"previous_cursor_str"];
                            nextCursor = [response valueForKey:@"next_cursor_str"];
                        }
                        
                        successBlock(users, previousCursor, nextCursor);
                    } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                        if(errorBlock) errorBlock(error);
                    }];
}


- (NSObject<STTwitterRequestProtocol> *)getFollowersListForUserID:(NSString *)userID
                                                     orScreenName:(NSString *)screenName
                                                            count:(NSString *)count
                                                           cursor:(NSString *)cursor
                                                       skipStatus:(NSNumber *)skipStatus
                                              includeUserEntities:(NSNumber *)includeUserEntities
                                                     successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                                                       errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((userID || screenName), @"userID or screenName is missing");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(count) md[@"count"] = count;
    if(cursor) md[@"cursor"] = cursor;
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    if(includeUserEntities) md[@"include_user_entities"] = [includeUserEntities boolValue] ? @"1" : @"0";
    
    
    return [_oauth fetchResource:@"followers/list.json"
                      HTTPMethod:@"GET"
                   baseURLString:kBaseURLStringAPI_1_1
                      parameters:md
             uploadProgressBlock:nil
           downloadProgressBlock:nil
                    successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
                        NSArray *users = nil;
                        NSString *previousCursor = nil;
                        NSString *nextCursor = nil;
                        
                        if([response isKindOfClass:[NSDictionary class]]) {
                            users = [response valueForKey:@"users"];
                            previousCursor = [response valueForKey:@"previous_cursor_str"];
                            nextCursor = [response valueForKey:@"next_cursor_str"];
                        }
                        
                        successBlock(users, previousCursor, nextCursor);
                    } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                        if(errorBlock) errorBlock(error);
                    }];
}


#pragma mark Users

// GET account/verify_credentials
- (NSObject<STTwitterRequestProtocol> *)getAccountVerifyCredentialsWithIncludeEntites:(NSNumber *)includeEntities
                                                                           skipStatus:(NSNumber *)skipStatus
                                                                         includeEmail:(NSNumber *)includeEmail
                                                                         successBlock:(void(^)(NSDictionary *myInfo))successBlock
                                                                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    if(includeEmail) md[@"include_email"] = [includeEmail boolValue] ? @"true" : @"false";
    
    return [_oauth fetchResource:@"account/verify_credentials.json"
                      HTTPMethod:@"GET"
                   baseURLString:kBaseURLStringAPI_1_1
                      parameters:md
             uploadProgressBlock:nil
           downloadProgressBlock:nil
                    successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
                        if(successBlock)
                            successBlock(response);
                    } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                        if(errorBlock) errorBlock(error);
                    }];
}



// POST account/update_profile_image
- (NSObject<STTwitterRequestProtocol> *)postAccountUpdateProfileImage:(NSString *)base64EncodedImage
                                                      includeEntities:(NSNumber *)includeEntities
                                                           skipStatus:(NSNumber *)skipStatus
                                                         successBlock:(void(^)(NSDictionary *profile))successBlock
                                                           errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSParameterAssert(base64EncodedImage);
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    md[@"image"] = base64EncodedImage;
    
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    if(skipStatus) md[@"skip_status"] = [skipStatus boolValue] ? @"1" : @"0";
    
    return [_oauth fetchResource:@"account/update_profile_image.json"
                      HTTPMethod:@"POST"
                   baseURLString:kBaseURLStringAPI_1_1
                      parameters:md
             uploadProgressBlock:nil
           downloadProgressBlock:nil
                    successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
                        if(successBlock)
                            successBlock(response);
                    } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                        if(errorBlock) errorBlock(error);
                    }];
}


// GET users/show
- (NSObject<STTwitterRequestProtocol> *)getUsersShowForUserID:(NSString *)userID
                                                 orScreenName:(NSString *)screenName
                                              includeEntities:(NSNumber *)includeEntities
                                                 successBlock:(void(^)(NSDictionary *user))successBlock
                                                   errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSAssert((screenName || userID), @"missing screenName or userID");
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    if(userID) md[@"user_id"] = userID;
    if(screenName) md[@"screen_name"] = screenName;
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"1" : @"0";
    
    return [_oauth fetchResource:@"users/show.json"
                      HTTPMethod:@"GET"
                   baseURLString:kBaseURLStringAPI_1_1
                      parameters:md
             uploadProgressBlock:nil
           downloadProgressBlock:nil
                    successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
                        if(successBlock)
                            successBlock(response);
                    } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                        if(errorBlock) errorBlock(error);
                    }];
}

#pragma mark OAuth

// GET oauth/authenticate
// GET oauth/authorize
// POST oauth/access_token
// POST oauth/request_token
// POST oauth2/token
// POST oauth2/invalidate_token

#pragma mark Help

// GET help/languages
- (NSObject<STTwitterRequestProtocol> *)getHelpLanguagesWithSuccessBlock:(void (^)(NSArray *languages))successBlock
                                                              errorBlock:(void (^)(NSError *))errorBlock {
    
    return [_oauth fetchResource:@"help/languages.json"
                      HTTPMethod:@"GET"
                   baseURLString:kBaseURLStringAPI_1_1
                      parameters:nil
             uploadProgressBlock:nil
           downloadProgressBlock:nil
                    successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
                        if(successBlock)
                            successBlock(response);
                    } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                        if(errorBlock) errorBlock(error);
                    }];
}



#pragma mark -
#pragma mark UNDOCUMENTED APIs

// GET activity/about_me.json
- (NSObject<STTwitterRequestProtocol> *)_getActivityAboutMeSinceID:(NSString *)sinceID
                                                             count:(NSString *)count //
                                                      includeCards:(NSNumber *)includeCards
                                                      modelVersion:(NSNumber *)modelVersion
                                                    sendErrorCodes:(NSNumber *)sendErrorCodes
                                                contributorDetails:(NSNumber *)contributorDetails
                                                   includeEntities:(NSNumber *)includeEntities
                                                  includeMyRetweet:(NSNumber *)includeMyRetweet
                                                      successBlock:(void(^)(NSArray *activities))successBlock
                                                        errorBlock:(void(^)(NSError *error))errorBlock {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if(sinceID) md[@"since_id"] = sinceID;
    if(count) md[@"count"] = count;
    if(contributorDetails) md[@"contributor_details"] = [contributorDetails boolValue] ? @"1" : @"0";
    if(includeEntities) md[@"include_entities"] = [includeEntities boolValue] ? @"true" : @"false";
    if(includeMyRetweet) md[@"include_my_retweet"] = [includeMyRetweet boolValue] ? @"1" : @"0";
    if(includeCards) md[@"include_cards"] = [includeCards boolValue] ? @"1" : @"0";
    if(modelVersion) md[@"model_version"] = [modelVersion boolValue] ? @"true" : @"false";
    if(sendErrorCodes) md[@"send_error_codes"] = [sendErrorCodes boolValue] ? @"1" : @"0";
    
    
    return [_oauth fetchResource:@"activity/about_me.json"
                      HTTPMethod:@"GET"
                   baseURLString:kBaseURLStringAPI_1_1
                      parameters:md
             uploadProgressBlock:nil
           downloadProgressBlock:nil
                    successBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response) {
                        if(successBlock)
                            successBlock(response);
                    } errorBlock:^(id request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error) {
                        if(errorBlock) errorBlock(error);
                    }];
}



@end
