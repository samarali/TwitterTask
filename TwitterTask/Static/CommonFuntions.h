//
//  CommonFuntions.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.


#import "AccountObj.h"

@interface CommonFuntions : NSObject

+ (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message ;
+ (BOOL)isStringNull:(NSString *)string ;


+ (void)createFile:(AccountObj*)obj;
+(AccountObj*)getSavedData;


@end
