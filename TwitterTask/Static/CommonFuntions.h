//
//  CommonFuntions.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.


#import "AccountObj.h"

@interface CommonFuntions : NSObject

+ (BOOL)hasConnectivity;
+ (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message ;
+ (BOOL)isStringEmpty:(NSString *)string;
+ (BOOL)isStringNull:(NSString *)string ;


+ (void)createFile:(AccountObj*)obj;
+(AccountObj*)getSavedData;
+ (void)clearUserData;


@end
