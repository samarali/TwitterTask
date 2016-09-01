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
            return  @"";
            break;
        case ChangeLangItem:
            [self UpdateLang_method];
            break;
        case UsersItem:
            [self LoadUsers_method];
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

    NSString *language=@"";
    if(appDelegate.currentLang==Arabic){
        appDelegate.currentLang=English;
        language=@"en";
    }else{
        appDelegate.currentLang=Arabic;
        language= @"ar";
    }
    ICLocalizationSetLanguage(language);
    
    appDelegate.userObj.userLang=appDelegate.currentLang;
    [CommonFuntions createFile:appDelegate.userObj];
    [appDelegate switchMenuDirection];
    [((BaseViewController*)[nav getTopView]) onHomePressed:nil];
    [CommonFuntions showAlertWithTitle:ApplicationTitleText Message:UpdateLanguageConfirmationMsg];
    
}

+(void)LoadUsers_method{
}

+(void)logout_method{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CustomNavigationController *nav=(CustomNavigationController*)appDelegate.centerController;
    [((BaseViewController*)[nav getTopView]) onMenuButtonPressed:nil];
    [((BaseViewController*)[nav getTopView]) logout];
    [((BaseViewController*)[nav getTopView]) runQuery:@"delete from follower" listOfFollowers:nil isInsertStat:FALSE];
    
   // [((BaseViewController*)[nav getTopView]) logout];
    
}
@end
