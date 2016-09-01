//
//  SideMenuCellObj.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/31/16.
//

#import <Foundation/Foundation.h>

@interface SideMenuCellObj : NSObject

@property (nonatomic,retain) NSString* menuName;
@property (nonatomic,retain) UIImage* menuImg;

+(SideMenuCellObj*)getChangeLangMenu;
+(SideMenuCellObj*)getProfileMenu;
+(SideMenuCellObj*)getUsersMenu;
+(SideMenuCellObj*)getLogOutMenu;

+(SideMenuCellObj*)getMenuForindex:(int)index;

+(NSString*)getViewControllerName:(int)index;
@end
