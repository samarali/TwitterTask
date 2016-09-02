//
//  AccountObj.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

#import <Foundation/Foundation.h>
#import "StaticVariables.h"

@interface AccountObj : NSObject{
    NSString* fullName;
    NSString* description;
    NSString* followersCount;
    NSString* statusCount;
    NSString* userID;
    NSString* profileBackgroundImageUrl;
    NSString* profileBackgroundImageUrlHttps;
    NSString* profileImageUrl;
    NSString* profileImageUrlHttps;
    NSString* screenName;
    NSString* parentID;
    NSString* accessToken;
    NSString* accessTokenSecret;
}

@property(nonatomic,retain) NSString* fullName;
@property(nonatomic,retain) NSString* description;
@property(nonatomic,retain) NSString* followersCount;
@property(nonatomic,retain) NSString* statusCount;
@property(nonatomic,retain) NSString* userID;
@property(nonatomic,retain) NSString* profileBackgroundImageUrl;
@property(nonatomic,retain) NSString* profileBackgroundImageUrlHttps;
@property(nonatomic,retain) NSString* profileImageUrl;
@property(nonatomic,retain) NSString* profileImageUrlHttps;
@property(nonatomic,retain) NSString* screenName;
@property(nonatomic,retain) NSString* parentID;
@property(nonatomic,retain) NSString* accessToken;
@property(nonatomic,retain) NSString* accessTokenSecret;

@end
