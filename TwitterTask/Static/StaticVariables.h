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

#define MenuStartX                                70

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

/////////////////////////////login constants/////////////////////////////
#define ConsumerKey                                @"zszxXhZxlET04NanfFWyMftEU"
#define ConsumerSecret                             @"YZS7PtBOrQl5VCEzmsLN4hk2odv1vkENniwyJ9IasBiIndWAp9"
#define ConsumerKeyName                            @"consumerKey"
#define ConsumerSecretKeyName                      @"consumerSecretKey"
#define AccessTokenName                            @"accessToken"
#define AccessTokenSecretName                      @"accessTokenSecret"

///////////////////////////Services general/////////////////////////////////


///////////////////////////////////User Constant////////////////////////////
#define fullNameKey                                @"fullName"
#define descriptionKey                             @"description"
#define followersCountKey                          @"followersCount"
#define userIDKey                                  @"userID"
#define profileBackgroundImageUrlKey               @"profileBackgroundImageUrl"
#define profileBackgroundImageUrlHttpsKey          @"profileBackgroundImageUrlHttps"
#define profileImageUrlKey                         @"profileImageUrl"
#define profileImageUrlHttpsKey                    @"profileImageUrlHttps"
#define screenNameKey                              @"screenName"
#define userLangKey                                @"userLang"

#endif
