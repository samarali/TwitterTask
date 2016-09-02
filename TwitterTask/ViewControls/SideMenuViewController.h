//
//  SideMenuViewController.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/31/16.
//

#import <UIKit/UIKit.h>
#import "STTwitterAPI.h"
#import "NSError+STTwitter.h"
#import "STHTTPRequest+STTwitter.h"

@interface SideMenuViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate,STTwitterAPIOSProtocol,UIActionSheetDelegate>{
 
    UILabel *menuTitleLbl;
    UIImageView *imageView;
}

@property(nonatomic,retain) IBOutlet UILabel *menuTitleLbl;
@property(nonatomic,retain) IBOutlet UIImageView *imageView;

- (void)setPanning:(BOOL)allow;
@end
