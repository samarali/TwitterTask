//
//  SideMenuCell.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/31/16.
//

#import <UIKit/UIKit.h>
#import "SideMenuCellObj.h"

@interface SideMenuCell : UITableViewCell{
    SideMenuCellObj* menuObj;
}

@property (nonatomic,retain) IBOutlet UILabel* menuNameLbl;
@property (nonatomic,retain) IBOutlet UIImageView* menuImgView;

-(void) initWithMenu:(SideMenuCellObj*)menu;
@end
