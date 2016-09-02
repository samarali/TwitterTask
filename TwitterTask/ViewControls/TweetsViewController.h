//
//  TweetsViewController.h
//  TwitterTask
//
//  Created by Samar-Mac book on 9/1/16.
//

#import "BaseViewController.h"
#import "TweetObj.h"
#import "AccountObj.h"
#import "STTwitterAPI.h"
#import "NSError+STTwitter.h"
#import "STHTTPRequest+STTwitter.h"



@interface TweetsViewController :  BaseViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>{
    UIImageView * userBGImg;
    UIImageView * userProfileImg;
    
    UITableView *tableView;
    UIView *controlsView;
    NSString *selectedUser;
    BOOL loadFromServer;
    NSMutableArray *listOfTweets;
    UIImageView * noDataImg;
    
}
@property(nonatomic,retain) IBOutlet UIImageView * userBGImg;
@property(nonatomic,retain) IBOutlet UIImageView * userProfileImg;
@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UIView *controlsView;
@property(nonatomic,retain) NSString *selectedUser;
@property (nonatomic, assign) BOOL loadFromServer;
@property(nonatomic,retain) NSMutableArray *listOfTweets;

@property(nonatomic,retain) IBOutlet UIImageView * noDataImg;

@end
