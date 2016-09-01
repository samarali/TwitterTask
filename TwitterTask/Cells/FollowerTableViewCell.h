//
//  FollowerTableViewCell.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/31/16.
//

#import <UIKit/UIKit.h>
#import "AccountObj.h"

@interface FollowerTableViewCell : UITableViewCell{
    AccountObj * aObj;
    
}

@property (nonatomic,retain) IBOutlet UIImageView * profileImg;
@property (nonatomic,retain) IBOutlet UILabel * nameTitleLbl;
@property (nonatomic,retain) IBOutlet UILabel * userNameTitleLbl;
@property (nonatomic,retain) IBOutlet UILabel * bioTitleLbl;

@property (nonatomic,retain) IBOutlet UILabel * nameValLbl;
@property (nonatomic,retain) IBOutlet UILabel * userNameValLbl;
@property (nonatomic,retain) IBOutlet UILabel * bioValLbl;

@property (nonatomic,retain) IBOutlet UIView * SeparatorView;


-(void)initWithAccountObj:(AccountObj*)obj withRowId:(int)rowId;
@end
