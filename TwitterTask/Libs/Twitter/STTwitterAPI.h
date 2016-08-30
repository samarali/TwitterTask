/*
 Copyright (c) 2012, Nicolas Seriot
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of the Nicolas Seriot nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

//
//  STTwitterAPI.h
//  STTwitterRequests
//
//  Created by Nicolas Seriot on 9/18/12.
//  Copyright (c) 2012 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitterRequestProtocol.h"

extern NS_ENUM(NSUInteger, STTwitterAPIErrorCode) {
    STTwitterAPICannotPostEmptyStatus = 0,
    STTwitterAPIMediaDataIsEmpty,
    STTwitterAPIEmptyStream
};

extern NSString *kBaseURLStringAPI_1_1;
extern NSString *kBaseURLStringStream_1_1;
extern NSString *kBaseURLStringUserStream_1_1;
extern NSString *kBaseURLStringSiteStream_1_1;

@class STTwitterAPI;
@class ACAccount;

@protocol STTwitterAPIOSProtocol <NSObject>
- (void)twitterAPI:(STTwitterAPI *)twitterAPI accountWasInvalidated:(ACAccount *)invalidatedAccount;
@end



@interface STTwitterAPI : NSObject

/*
 called when need to authonticate user using iOS
 take: User account
 */
+ (instancetype)twitterAPIOSWithAccount:(ACAccount *)account delegate:(NSObject <STTwitterAPIOSProtocol> *)delegate;

/*
 called when need to authonticate user by webview
 take:
 1-required   : consumerKey - consumerSecret
 2-May be nil : oauthToken  - oauthTokenSecret (be nil in first authonticate after that set them with saved logged user data)
 */
+ (instancetype)twitterAPIWithOAuthConsumerKey:(NSString *)consumerKey
                                consumerSecret:(NSString *)consumerSecret
                                    oauthToken:(NSString *)oauthToken // aka accessToken
                              oauthTokenSecret:(NSString *)oauthTokenSecret; // aka accessTokenSecret

/*
 After authenticating in a web view, Twitter redirects to the callback URL with some additional parameters. MUST allow the usage of callbacks by specifying a dummy URL,
 This URL is then overriden by the `oauthCallback ` parameter in:
 */
- (void)postTokenRequest:(void(^)(NSURL *url, NSString *oauthToken))successBlock
authenticateInsteadOfAuthorize:(BOOL)authenticateInsteadOfAuthorize // use NO if you're not sure
              forceLogin:(NSNumber *)forceLogin
              screenName:(NSString *)screenName
           oauthCallback:(NSString *)oauthCallback
              errorBlock:(void(^)(NSError *error))errorBlock;

/*
 called after authenticating user by web view to verify him and return with user data
 */
- (void)postAccessTokenRequestWithPIN:(NSString *)pin
                         successBlock:(void(^)(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName))successBlock
                           errorBlock:(void(^)(NSError *error))errorBlock;

// ensure that the Twitter account is usable by performing local access checks and then an API call
// this method should typically be called at each launch of a Twitter client
- (void)verifyCredentialsWithUserSuccessBlock:(void(^)(NSString *username, NSString *userID))successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock;


@property (nonatomic, strong) NSString *userName; // set after successful connection for STTwitterOAuth
@property (nonatomic, strong) NSString *userID; // set after successful connection for STTwitterOAuth

@property (nonatomic, readonly) NSString *oauthAccessToken;
@property (nonatomic, readonly) NSString *oauthAccessTokenSecret;

@property (nonatomic, strong) NSString *sharedContainerIdentifier; // common to all STTwitterAPI instances


#pragma mark Generic methods to GET and POST

- (NSObject<STTwitterRequestProtocol> *)fetchResource:(NSString *)resource
                                           HTTPMethod:(NSString *)HTTPMethod
                                        baseURLString:(NSString *)baseURLString
                                           parameters:(NSDictionary *)params
                                  uploadProgressBlock:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))uploadProgressBlock
                                downloadProgressBlock:(void (^)(NSObject<STTwitterRequestProtocol> *request, NSData *data))downloadProgressBlock
                                         successBlock:(void (^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, id response))successBlock
                                           errorBlock:(void (^)(NSObject<STTwitterRequestProtocol> *request, NSDictionary *requestHeaders, NSDictionary *responseHeaders, NSError *error))errorBlock;

#pragma mark Timelines


/*
 GET	statuses/home_timeline
 
 Returns Tweets (*: tweets from people the user follows)
 
 Returns a collection of the most recent Tweets and retweets posted by the authenticating user and the users they follow. The home timeline is central to how most users interact with the Twitter service.
 
 Up to 800 Tweets are obtainable on the home timeline. It is more volatile for users that follow many users or follow users who tweet frequently.
 */

- (NSObject<STTwitterRequestProtocol> *)getStatusesHomeTimelineWithCount:(NSString *)count
                                                                 sinceID:(NSString *)sinceID
                                                                   maxID:(NSString *)maxID
                                                                trimUser:(NSNumber *)trimUser
                                                          excludeReplies:(NSNumber *)excludeReplies
                                                      contributorDetails:(NSNumber *)contributorDetails
                                                         includeEntities:(NSNumber *)includeEntities
                                                            successBlock:(void(^)(NSArray *statuses))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock;

// convenience method
- (NSObject<STTwitterRequestProtocol> *)getHomeTimelineSinceID:(NSString *)sinceID
                                                         count:(NSUInteger)count
                                                  successBlock:(void(^)(NSArray *statuses))successBlock
                                                    errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET	statuses/user_timeline
 Returns Tweets (*: tweets for the user)
 
 Returns a collection of the most recent Tweets posted by the user indicated by the screen_name or user_id parameters.
 
 User timelines belonging to protected users may only be requested when the authenticated user either "owns" the timeline or is an approved follower of the owner.
 
 The timeline returned is the equivalent of the one seen when you view a user's profile on twitter.com.
 
 This method can only return up to 3,200 of a user's most recent Tweets. Native retweets of other statuses by the user is included in this total, regardless of whether include_rts is set to false when requesting this resource.
 */

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
                                                              errorBlock:(void(^)(NSError *error))errorBlock;



#pragma mark Friends & Followers

/*
 GET    friends/list
 
 Returns a cursored collection of user objects for every user the specified user is following (otherwise known as their "friends").
 
 At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 20 users and multiple "pages" of results can be navigated through using the next_cursor value in subsequent requests. See Using cursors to navigate collections for more information.
 */
- (NSObject<STTwitterRequestProtocol> *)getFriendsListForUserID:(NSString *)userID
                                                   orScreenName:(NSString *)screenName
                                                         cursor:(NSString *)cursor
                                                          count:(NSString *)count
                                                     skipStatus:(NSNumber *)skipStatus
                                            includeUserEntities:(NSNumber *)includeUserEntities
                                                   successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                                                     errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    followers/list
 
 Returns a cursored collection of user objects for users following the specified user.
 
 At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 20 users and multiple "pages" of results can be navigated through using the next_cursor value in subsequent requests. See Using cursors to navigate collections for more information.
 */

- (NSObject<STTwitterRequestProtocol> *)getFollowersListForUserID:(NSString *)userID
                                                     orScreenName:(NSString *)screenName
                                                            count:(NSString *)count
                                                           cursor:(NSString *)cursor
                                                       skipStatus:(NSNumber *)skipStatus
                                              includeUserEntities:(NSNumber *)includeUserEntities
                                                     successBlock:(void(^)(NSArray *users, NSString *previousCursor, NSString *nextCursor))successBlock
                                                       errorBlock:(void(^)(NSError *error))errorBlock;

#pragma mark Users

/*
 GET	account/verify_credentials
 
 Returns an HTTP 200 OK response code and a representation of the requesting user if authentication was successful; returns a 401 status code and an error message if not. Use this method to test if supplied user credentials are valid.
 */

- (NSObject<STTwitterRequestProtocol> *)getAccountVerifyCredentialsWithIncludeEntites:(NSNumber *)includeEntities
                                                                           skipStatus:(NSNumber *)skipStatus
                                                                         includeEmail:(NSNumber *)includeEmail
                                                                         successBlock:(void(^)(NSDictionary *account))successBlock
                                                                           errorBlock:(void(^)(NSError *error))errorBlock;
/*
 POST	account/update_profile_image
 
 Updates the authenticating user's profile image. Note that this method expects raw multipart data, not a URL to an image.
 
 This method asynchronously processes the uploaded file before updating the user's profile image URL. You can either update your local cache the next time you request the user's information, or, at least 5 seconds after uploading the image, ask for the updated URL using GET users/show.
 */

- (NSObject<STTwitterRequestProtocol> *)postAccountUpdateProfileImage:(NSString *)base64EncodedImage
                                                      includeEntities:(NSNumber *)includeEntities
                                                           skipStatus:(NSNumber *)skipStatus
                                                         successBlock:(void(^)(NSDictionary *profile))successBlock
                                                           errorBlock:(void(^)(NSError *error))errorBlock;
/*
 GET    users/show
 
 Returns a variety of information about the user specified by the required user_id or screen_name parameter. The author's most recent Tweet will be returned inline when possible. GET users/lookup is used to retrieve a bulk collection of user objects.
 
 You must be following a protected user to be able to see their most recent Tweet. If you don't follow a protected user, the users Tweet will be removed. A Tweet will not always be returned in the current_status field.
 */

- (NSObject<STTwitterRequestProtocol> *)getUsersShowForUserID:(NSString *)userID
                                                 orScreenName:(NSString *)screenName
                                              includeEntities:(NSNumber *)includeEntities
                                                 successBlock:(void(^)(NSDictionary *user))successBlock
                                                   errorBlock:(void(^)(NSError *error))errorBlock;


#pragma mark OAuth

#pragma mark Help


/*
 GET    help/languages
 
 Returns the list of languages supported by Twitter along with their ISO 639-1 code. The ISO 639-1 code is the two letter value to use if you include lang with any of your requests.
 */

- (NSObject<STTwitterRequestProtocol> *)getHelpLanguagesWithSuccessBlock:(void(^)(NSArray *languages))successBlock
                                                              errorBlock:(void(^)(NSError *error))errorBlock;
#pragma mark -
#pragma mark UNDOCUMENTED APIs

// GET activity/about_me.json
- (NSObject<STTwitterRequestProtocol> *)_getActivityAboutMeSinceID:(NSString *)sinceID
                                                             count:(NSString *)count
                                                      includeCards:(NSNumber *)includeCards
                                                      modelVersion:(NSNumber *)modelVersion
                                                    sendErrorCodes:(NSNumber *)sendErrorCodes
                                                contributorDetails:(NSNumber *)contributorDetails
                                                   includeEntities:(NSNumber *)includeEntities
                                                  includeMyRetweet:(NSNumber *)includeMyRetweet
                                                      successBlock:(void(^)(NSArray *activities))successBlock
                                                        errorBlock:(void(^)(NSError *error))errorBlock;


@end
