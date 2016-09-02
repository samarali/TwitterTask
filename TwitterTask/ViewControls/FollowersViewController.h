//
//  FollowersViewController.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/31/16.
//

#import "BaseViewController.h"
#import "AccountObj.h"
#import "STTwitterAPI.h"
#import "NSError+STTwitter.h"
#import "STHTTPRequest+STTwitter.h"
#import "AppDelegate.h"



@interface FollowersViewController :  BaseViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>{
    UILabel *titleLbl;

    UITableView *tableView;
    UIView *controlsView;
    BOOL loadFromServer;
    NSMutableArray *listOfFollowers;
    UIImageView * noDataImg;
}
@property(nonatomic,retain) IBOutlet UILabel *titleLbl;

@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UIView *controlsView;
@property(nonatomic,retain) AppDelegate *appDelegate;
@property (nonatomic, assign) BOOL loadFromServer;
@property(nonatomic,retain) NSMutableArray *listOfFollowers;

@property(nonatomic,retain) IBOutlet UIImageView * noDataImg;

@end
