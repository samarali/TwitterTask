//
//  StaticVariables.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

//

#import <Foundation/Foundation.h>

#ifndef TwitterTask_StaticVariables_h
#define TwitterTask_StaticVariables_h

typedef enum myLanguages{
    Arabic=0,
    English=1
}MyLanguages;

typedef enum mainMenuItems{
    MyProfileItem=0,
    ChangeLangItem,
    UsersItem,
    LogoutItem
    
}MainMenuItems;

#define MenuStartX                                70
#define NumberMenuItems                           4

///////////////////////////////////////////////////////////////////////////////
#define nilOrJSONObjectForKey(JSON_, KEY_) [[JSON_ objectForKey:KEY_] isKindOfClass:[NSNull null]] ? nil : [JSON_ objectForKey:KEY_];



#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)



/////////////////////////////////////////////////////////////////
//////////////////////View Controls constants///////////////////////
//////////////////////////////////////////////////////////////////
#define LoginScreenName                            @"LoginViewController"
#define FollowerScreenName                         @"FollowersViewController"
#define TweetsScreenName                           @"TweetsViewController"
#define loadUsersPopup                             @"loadUsersPopup"
/////////////////////////////login constants/////////////////////////////
#define ConsumerKey                                @"zszxXhZxlET04NanfFWyMftEU"
#define ConsumerSecret                             @"YZS7PtBOrQl5VCEzmsLN4hk2odv1vkENniwyJ9IasBiIndWAp9"
#define ConsumerKeyName                            @"consumerKey"
#define ConsumerSecretKeyName                      @"consumerSecretKey"

///////////////////////////general general/////////////////////////////////
#define dbNameKey                                  @"TwitterTask"
#define dbTypeKey                                  @"sqlite"
#define selectStatmentKey                          @"select * from "
#define deleteStatmentKey                          @"delete from "
#define insertStatmentKey                          @"insert into "
#define followerTableKey                           @"follower "
#define tweetTableKey                              @"tweet "
#define userTableKey                               @"user "
///////////////////////////////////User Constant////////////////////////////
#define fullNameKey                                @"name"
#define descriptionKey                             @"description"
#define followersCountKey                          @"followers_count"
#define statusCountKey                             @"statuses_count"
#define userIDKey                                  @"id_str"
#define profileBackgroundImageUrlKey               @"profile_background_image_url"
#define profileBackgroundImageUrlHttpsKey          @"profile_background_image_url_https"
#define profileImageUrlKey                         @"profile_image_url"
#define profileImageUrlHttpsKey                    @"profile_image_url_https"
#define screenNameKey                              @"screen_name"
#define parentIDKey                                @"parent_ID"
#define userLangKey                                @"userLang"
#define accessTokenKey                             @"accesstoken_secret"
#define accessTokenSecretKey                       @"accesstoken"

///////////////////////////////////Tweet Constant////////////////////////////
#define tweetTimeKey                               @"created_at"
#define tweetCreatorIDKey                          @"creator_ID"
#define tweetTextKey                               @"text"
#define tweetUserObjKey                            @"user."
#define userObjKey                                 @"user"

#endif
