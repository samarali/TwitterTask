//
//  SideMenuCell.m
//  TwitterTask
//
//  Created by Samar-Mac book on 8/31/16.
//

#import "SideMenuCell.h"

@implementation SideMenuCell
@synthesize menuImgView;
@synthesize menuNameLbl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - funtions

-(void)initWithMenu:(SideMenuCellObj *)menu{
    menuObj=menu;
    menuNameLbl.text=menu.menuName;
    menuImgView.image=menu.menuImg;
}


@end
