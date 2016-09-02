//
//  FollowersViewController.m
//  TwitterTask
//
//  Created by Samar-Mac book on 8/31/16.
//

#import "FollowersViewController.h"
#import "TweetsViewController.h"
#import "LocalizedMessages.h"
#import "commonFuntions.h"
#import "FollowerTableViewCell.h"
#import "STTwitterAPI.h"
#import "NSError+STTwitter.h"
#import "STHTTPRequest+STTwitter.h"
#import "NSDictionary+NotNull.h"

@interface FollowersViewController ()
@end

@implementation FollowersViewController

@synthesize titleLbl;
@synthesize tableView;
@synthesize controlsView;
@synthesize loadFromServer;
@synthesize listOfFollowers;
@synthesize noDataImg;
@synthesize appDelegate;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    

    
    [self customizeNavigationBar:FALSE WithMenu:YES];
    
    tableView.layoutMargins = UIEdgeInsetsZero;
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if (loadFromServer){
        [self loadFollowersOnline];
        [self initRefreshControl:self.tableView];
    }
    else{
        [self loadFollowersOffline];
    }
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - base methods

-(void)initalizeViews{
    noDataLbl.hidden=YES;
    noDataImg.hidden=YES;
    listOfFollowers = [[NSMutableArray alloc] init];

    tableView.allowsMultipleSelectionDuringEditing = NO;
}

-(void)locatizeLables{
    titleLbl.text=FollowersTitleText;
    noDataLbl.text=FollowersNoDataFoundMsg;
}

-(void)switchToEnglishLayout{
    titleLbl.textAlignment=NSTextAlignmentLeft;
}
-(void)switchToArabicLayout{
    titleLbl.textAlignment=NSTextAlignmentRight;
}


#pragma mark - methods
-(void)loadFollowersOnline{
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self showActivityViewer];
    [appDelegate.twitter getFollowersListForUserID:appDelegate.userObj.userID orScreenName:nil count:nil cursor:nil skipStatus:nil includeUserEntities:nil successBlock:^(NSArray *users, NSString *previousCursor, NSString *nextCursor) {
        if ([users count]>0)
        {
            [self fillUsersArray:users];
            [self deleteOldFollowers];
            [self AddNewFollowersDB];
        }
        [tableView reloadData];
        [self hideActivityViewer];
        
    } errorBlock:^(NSError *error) {
        [self loadFollowersOffline];
        [CommonFuntions showAlertWithTitle:ApplicationTitleText Message:[error localizedDescription]];
        [self hideActivityViewer];
    }];
}

-(void)loadFollowersOffline{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.listOfFollowers = [[NSMutableArray alloc]init];
    listOfFollowers = [self runQuery:[NSString stringWithFormat:@"%@%@ where %@=%@",selectStatmentKey,followerTableKey,parentIDKey,appDelegate.userObj.userID]];
    
    if ([listOfFollowers count] > 0) {
        NSMutableArray* arr = [[NSMutableArray alloc] initWithArray:listOfFollowers];
        [listOfFollowers removeAllObjects];
        AccountObj *uObj;
        NSMutableDictionary *objDic;
        for (int i=0; i<[arr count]; i++) {
            objDic = [[NSMutableDictionary alloc] init];
            objDic = [arr objectAtIndex:i];
            uObj = [[AccountObj alloc] init];
            uObj = [self convertDicToAccount:objDic];
            [listOfFollowers addObject:uObj];
        }
    }
    [tableView reloadData];
}

-(void)fillUsersArray:(NSArray *)users{
    NSMutableDictionary *objDic;
    AccountObj *uObj;
    listOfFollowers = [[NSMutableArray alloc] init];
    for (int i =0 ; i < [users count]; i++) {
        objDic = [[NSMutableDictionary alloc] init];
        objDic = [users objectAtIndex:i];
        uObj = [[AccountObj alloc] init];
        uObj = [self convertDicToAccount:objDic];
        [listOfFollowers addObject:uObj];
    }
    
    
    
}

-(AccountObj *)convertDicToAccount:(NSMutableDictionary *)objDic{
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    AccountObj *uObj = [[AccountObj alloc] init];
    uObj.fullName = [objDic objectForKeyedSubscript:fullNameKey];
    uObj.description = [objDic objectForKeyedSubscript:descriptionKey];
    uObj.followersCount = [NSString stringWithFormat:@"%li",[[objDic objectForKeyedSubscript:followersCountKey] integerValue]];
    uObj.statusCount = [NSString stringWithFormat:@"%li",[[objDic objectForKeyedSubscript:statusCountKey] integerValue]];
    uObj.userID = [objDic objectForKeyedSubscript:userIDKey];
    uObj.profileBackgroundImageUrl = [objDic objectForKeyedSubscript:profileBackgroundImageUrlKey];
    uObj.profileBackgroundImageUrlHttps = [objDic objectForKeyedSubscript:profileBackgroundImageUrlHttpsKey];
    uObj.profileImageUrl = [objDic objectForKeyedSubscript:profileImageUrlKey];
    uObj.profileImageUrlHttps = [objDic objectForKeyedSubscript:profileImageUrlHttpsKey];
    uObj.screenName = [NSString stringWithFormat:@"%@",[objDic objectForKeyedSubscript:screenNameKey]];
    uObj.parentID = appDelegate.userObj.userID;
    return uObj;
}
-(void)deleteOldFollowers
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self runQuery:[NSString stringWithFormat:@"%@%@ where %@=%@",deleteStatmentKey,followerTableKey,parentIDKey,appDelegate.userObj.userID] listOfFollowers:nil listOfTweets:nil isInsertStat:FALSE];
}
-(void)AddNewFollowersDB{
    /*
     CREATE TABLE follower(_id integer primary key, name text, description text, followers_count text, statuses_count text, id_str text, profile_background_image_url text, profile_background_image_url_https text, profile_image_url text, profile_image_url_https text, screen_name text);
     */
    
    NSString *query;
    query = @"insert into follower values";
    for (int i = 0; i < [listOfFollowers count]; i++) {
        if (i == 0)
            query = [NSString stringWithFormat:@"%@(null, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",query];
        else
            query = [NSString stringWithFormat:@"%@,(null, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",query];
    }
    [self runQuery:query listOfFollowers:listOfFollowers listOfTweets:nil isInsertStat:YES];
    
}

-(void)initRefreshControl:(UITableView*)tblView{
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setTintColor:[UIColor whiteColor]];
    UIColor *color = [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1];
    [refreshControl setBackgroundColor:color];
    refreshControl.layer.zPosition = tblView.backgroundView.layer.zPosition + 1;
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [tblView addSubview:refreshControl];
}


#pragma mark - table delegate

-(CGFloat)tableView:(UITableView *)tblView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger height = 0;
    AccountObj *uObj = [[AccountObj alloc] init];
    uObj=[listOfFollowers objectAtIndex:(int)indexPath.row];
    
    static NSString *CellIdentifier=@"FollowerTableViewCell";
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.currentLang==English)
        CellIdentifier=@"FollowerTableViewCell_en";
    else
        CellIdentifier=@"FollowerTableViewCell";
    
    FollowerTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[FollowerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.nameValLbl.numberOfLines = 1000;
    cell.userNameValLbl.numberOfLines = 1000;
    cell.bioValLbl.numberOfLines = 1000;

    
    cell.nameValLbl.text=uObj.fullName;
    cell.userNameValLbl.text=uObj.screenName;
    cell.bioValLbl.text=uObj.description;
    
    
    CGRect newFrame = cell.nameValLbl.frame;
    CGSize newSize = [cell.nameValLbl sizeThatFits:CGSizeMake(cell.nameValLbl.frame.size.width, MAXFLOAT)];
    newFrame.size = CGSizeMake(fmaxf(newSize.width, cell.nameValLbl.frame.size.width), newSize.height);
    height+=newFrame.size.height;
    
    newFrame = cell.userNameValLbl.frame;
    newSize = [cell.userNameValLbl sizeThatFits:CGSizeMake(cell.userNameValLbl.frame.size.width, MAXFLOAT)];
    newFrame.size = CGSizeMake(fmaxf(newSize.width, cell.userNameValLbl.frame.size.width), newSize.height);
    height+=newFrame.size.height;
    
    
    newFrame = cell.bioValLbl.frame;
    newSize = [cell.bioValLbl sizeThatFits:CGSizeMake(cell.bioValLbl.frame.size.width, MAXFLOAT)];
    newFrame.size = CGSizeMake(fmaxf(newSize.width, cell.bioValLbl.frame.size.width), newSize.height);
    height+=newFrame.size.height;
    //separation space
    if ([uObj.description length] > 0)
        height += 20;
    else
        height += 15;
    
    
    if (height < 58)
        height = 58;
    return height;
}


-(UITableViewCell*) tableView:(UITableView *)tblView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier=@"FollowerTableViewCell";
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.currentLang==English)
        CellIdentifier=@"FollowerTableViewCell_en";
    else
        CellIdentifier=@"FollowerTableViewCell";
    
    FollowerTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[FollowerTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    AccountObj *obj=nil;
    
    obj=[listOfFollowers objectAtIndex:(int)indexPath.row];
    [cell initWithAccountObj:obj withRowId:(int)indexPath.row];
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section{

    if([listOfFollowers count]==0){
        noDataLbl.hidden=NO;
        noDataImg.hidden=NO;
        return 0;
    }
    noDataLbl.hidden=YES;
    noDataImg.hidden=YES;
    return [listOfFollowers count];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSIndexPath *)tableView:(UITableView *)tblView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

- (void)tableView:(UITableView *)tblView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AccountObj *uObj = [listOfFollowers objectAtIndex:indexPath.row];
    
    TweetsViewController *tweetsController = (TweetsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:TweetsScreenName];
    tweetsController.loadFromServer = loadFromServer;
    tweetsController.selectedUser = uObj.userID;
    [self.navigationController pushViewController:tweetsController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - refresh

- (void)refresh:(UIRefreshControl *)refreshControl_ {
    [self loadFollowersOnline];
    [refreshControl endRefreshing];
}




@end
