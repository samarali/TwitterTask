//
//  SideMenuCellObj.m
//  TwitterTask
//
//  Created by Samar-Mac book on 8/31/16.
//

#import "SideMenuCellObj.h"
#import "LocalizedMessages.h"
#import "StaticVariables.h"
#import "BaseViewController.h"
#import "CustomNavigationController.h"
#import "AppDelegate.h"
#import "CommonFuntions.h"

@implementation SideMenuCellObj
@synthesize menuImg;
@synthesize menuName;

#pragma mark - get menu objects



+(SideMenuCellObj*)getChangeLangMenu{
    SideMenuCellObj *cell=[[SideMenuCellObj alloc] init];
    cell.menuImg=[UIImage imageNamed:@"lang.png"];
    cell.menuName=MenuItemChangeLangText;
    return cell;
}

+(SideMenuCellObj*)getProfileMenu{
    SideMenuCellObj *cell=[[SideMenuCellObj alloc] init];
    cell.menuImg=[UIImage imageNamed:@"home.png"];
    cell.menuName=MenuItemProfileText;
    return cell;
}

+(SideMenuCellObj*)getUsersMenu{
    SideMenuCellObj *cell=[[SideMenuCellObj alloc] init];
    cell.menuImg=[UIImage imageNamed:@"contacts.png"];
    cell.menuName=MenuItemUsersText;
    return cell;
}

+(SideMenuCellObj*)getLogOutMenu{
    SideMenuCellObj *cell=[[SideMenuCellObj alloc] init];
    cell.menuImg=[UIImage imageNamed:@"log_out.png"];
    cell.menuName=MenuItemLogoutText;
    return cell;
}

+(SideMenuCellObj*)getMenuForindex:(int)index{
    
    switch (index) {
        case MyProfileItem:
            return  [self getProfileMenu];
            break;
        case ChangeLangItem:
            return [self getChangeLangMenu];
            break;
        case UsersItem:
            return [self getUsersMenu];
            break;
        case LogoutItem:
            return  [self getLogOutMenu];
            break;
        default:
            break;
    }
    
    return nil;
}

+(NSString*)getViewControllerName:(int)index{

    switch (index) {
        //to set my profile view controller
        case MyProfileItem:
            return  TweetsScreenName;
            break;
        case ChangeLangItem:
            [self UpdateLang_method];
            break;
        case UsersItem:
            return loadUsersPopup;
            break;
        case LogoutItem:
            [self logout_method];
            break;
        default:
            break;
    }
    
    return @"";
}

+(void)UpdateLang_method{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CustomNavigationController *nav=(CustomNavigationController*)appDelegate.centerController;
    [((BaseViewController*)[nav getTopView]) onMenuButtonPressed:nil];

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *language=@"";
    if(appDelegate.currentLang==Arabic){
        appDelegate.currentLang=English;
        language=@"en";
        [defaults setObject:@"1" forKey:userLangKey];
    }else{
        appDelegate.currentLang=Arabic;
        language= @"ar";
        [defaults setObject:@"0" forKey:userLangKey];
    }
    [defaults synchronize];
    
    ICLocalizationSetLanguage(language);
    
    [appDelegate switchMenuDirection];
    [((BaseViewController*)[nav getTopView]) onHomePressed:nil];
    [CommonFuntions showAlertWithTitle:ApplicationTitleText Message:UpdateLanguageConfirmationMsg];
    
}




+(void)logout_method{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CustomNavigationController *nav=(CustomNavigationController*)appDelegate.centerController;
    [((BaseViewController*)[nav getTopView]) onMenuButtonPressed:nil];
    [((BaseViewController*)[nav getTopView]) logout];
    
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    list = [((BaseViewController*)[nav getTopView]) runQuery:[NSString stringWithFormat:@"%@%@ where %@=%@",selectStatmentKey,followerTableKey,parentIDKey,appDelegate.userObj.userID]];
    NSMutableDictionary *obj;
    if ([list count] > 0) {
        
        for (int i = 0 ; i < [list count]; i++) {
            obj = [[NSMutableDictionary alloc] init];
            obj = [list objectAtIndex:i];
            [((BaseViewController*)[nav getTopView]) runQuery:[NSString stringWithFormat:@"%@%@ where %@=%@",deleteStatmentKey,tweetTableKey,tweetCreatorIDKey,[obj objectForKeyedSubscript:userIDKey]] listOfFollowers:nil listOfTweets:nil isInsertStat:FALSE];
        }
        [((BaseViewController*)[nav getTopView]) runQuery:[NSString stringWithFormat:@"%@%@ where %@=%@",deleteStatmentKey,followerTableKey,parentIDKey,appDelegate.userObj.userID] listOfFollowers:nil listOfTweets:nil isInsertStat:FALSE];
    }
    
    [((BaseViewController*)[nav getTopView]) runQuery:[NSString stringWithFormat:@"%@%@ where %@=%@",deleteStatmentKey,userTableKey,userIDKey,appDelegate.userObj.userID] listOfFollowers:nil listOfTweets:nil isInsertStat:FALSE];
    
    
    list = [[NSMutableArray alloc] init];
    list = [((BaseViewController*)[nav getTopView]) runQuery:[NSString stringWithFormat:@"%@%@",selectStatmentKey,userTableKey]];
    
    if ([list count] > 0) {
        obj = [[NSMutableDictionary alloc] init];
        obj = [list objectAtIndex:0];
        
        NSString *query = [NSString stringWithFormat:@"update %@ set is_selected='1' where id_str=%@",userTableKey,[obj objectForKeyedSubscript:userIDKey]];
        [((BaseViewController*)[nav getTopView]) runQuery:query listOfFollowers:nil listOfTweets:nil isInsertStat:FALSE];
    }
    
}
@end
