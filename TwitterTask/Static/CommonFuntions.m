//
//  CommonFuntions.m
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

#import "CommonFuntions.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "LocalizedMessages.h"
#import "AppDelegate.h"


@implementation CommonFuntions

+ (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message {
    NSString * messageTitle = title ? title : ApplicationTitleText;
    [[[UIAlertView alloc] initWithTitle:messageTitle
                                message:message
                               delegate:nil
                      cancelButtonTitle:OKayButtonText
                      otherButtonTitles:nil] show];
}
+ (BOOL)isStringNull:(NSString *)string  {
    if (string == nil) {
        return YES;
    }
    return NO;
}

+(void)createFile:(AccountObj*)obj{

    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"UserData.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]){
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"UserData" ofType:@"plist"];
        [fileManager copyItemAtPath:bundle toPath: path error:&error];
    }
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    [data setObject:obj.fullName forKey:fullNameKey];
    [data setObject:obj.description forKey:descriptionKey];
    [data setObject:obj.followersCount forKey:followersCountKey];
    [data setObject:obj.userID forKey:userIDKey];
    [data setObject:obj.profileBackgroundImageUrl forKey:profileBackgroundImageUrlKey];
    [data setObject:obj.profileBackgroundImageUrlHttps forKey:profileBackgroundImageUrlHttpsKey];
    [data setObject:obj.profileImageUrl forKey:profileImageUrlKey];
    [data setObject:obj.profileImageUrlHttps forKey:profileImageUrlHttpsKey];
    [data setObject:obj.screenName forKey:screenNameKey];
    [data setObject:[NSNumber numberWithInt:(int)obj.userLang] forKey:userLangKey];
    
    [data writeToFile: path atomically:YES];
}


+(AccountObj*)getSavedData{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"UserData.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath: path]){
        NSMutableDictionary *savedData = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        
        AccountObj *obj=[[AccountObj alloc]init];
        obj.fullName = [savedData objectForKey:fullNameKey];
        obj.description = [savedData objectForKey:descriptionKey];
        obj.followersCount = [savedData objectForKey:followersCountKey];
        obj.userID = [savedData objectForKey:userIDKey];
        obj.profileBackgroundImageUrl = [savedData objectForKey:profileBackgroundImageUrlKey];
        obj.profileBackgroundImageUrlHttps = [savedData objectForKey:profileBackgroundImageUrlHttpsKey];
        obj.profileImageUrl = [savedData objectForKey:profileImageUrlKey];
        obj.profileImageUrlHttps = [savedData objectForKey:profileImageUrlHttpsKey];
        obj.screenName = [savedData objectForKey:screenNameKey];
    
        
        obj.userLang=(MyLanguages)[[savedData objectForKey:userLangKey] intValue];
        return obj;
    }
    return nil;
    
}

@end
