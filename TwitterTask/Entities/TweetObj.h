//
//  TweetObj.h
//  TwitterTask
//
//  Created by Samar-Mac book on 9/1/16.

#import <Foundation/Foundation.h>
#import "StaticVariables.h"
#import "AccountObj.h"

@interface TweetObj : NSObject{
    NSString* createdAt;
    NSString* value;
    AccountObj *creatorObj;
}

@property(nonatomic,retain) NSString* createdAt;
@property(nonatomic,retain) NSString* value;
@property(nonatomic,retain) AccountObj *creatorObj;


@end
