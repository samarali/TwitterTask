//
//  FollowersViewController.m
//  TwitterTask
//
//  Created by Samar-Mac book on 8/31/16.
//

#import "FollowersViewController.h"
#import "AppDelegate.h"
#import "LocalizedMessages.h"
#import "commonFuntions.h"
#import "FollowerTableViewCell.h"
#import "STTwitterAPI.h"
#import "NSError+STTwitter.h"
#import "STHTTPRequest+STTwitter.h"

@interface FollowersViewController ()
@end

@implementation FollowersViewController

@synthesize titleLbl;
@synthesize tableView;
@synthesize controlsView;
@synthesize loadFromServer;
@synthesize listOfFollowers;
@synthesize noDataImg;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    

    
    [self customizeNavigationBar:FALSE WithMenu:YES];
    
    tableView.layoutMargins = UIEdgeInsetsZero;
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if (loadFromServer)
        [self loadFollowers];
    else{
        self.listOfFollowers = [[NSMutableArray alloc]init];
        listOfFollowers = [self runQuery:@"select * from follower"];
        
        if ([listOfFollowers count] > 0) {
            AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSMutableArray* arr = [[NSMutableArray alloc] initWithArray:listOfFollowers];
            [listOfFollowers removeAllObjects];
            AccountObj *uObj;
            for (int i=0; i<[arr count]; i++) {
                NSMutableDictionary *objDic = [arr objectAtIndex:i];
                uObj = [[AccountObj alloc] init];
                uObj = [self convertDicToAccount:objDic lang:appdelegate.currentLang];
                [listOfFollowers addObject:uObj];
            }
        }
        [tableView reloadData];
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
    [super setEditing:YES animated:YES];
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
-(void)loadFollowers{
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self showActivityViewer];
    [appDelegate.twitter getFollowersListForUserID:appDelegate.userObj.userID orScreenName:nil count:nil cursor:nil skipStatus:nil includeUserEntities:nil successBlock:^(NSArray *users, NSString *previousCursor, NSString *nextCursor) {
        if ([users count]>0)
        {
            [self fillUsersArray:users];
            [self updateDB:YES];
        }
        [tableView reloadData];
        [self hideActivityViewer];
        
    } errorBlock:^(NSError *error) {
        [CommonFuntions showAlertWithTitle:ApplicationTitleText Message:[error localizedDescription]];
        [self hideActivityViewer];
    }];
}

-(void)fillUsersArray:(NSArray *)users{
    NSMutableDictionary *objDic;
    AccountObj *uObj;
    listOfFollowers = [[NSMutableArray alloc] init];
    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (int i =0 ; i < [users count]; i++) {
        objDic = [[NSMutableDictionary alloc] init];
        objDic = [users objectAtIndex:i];
        uObj = [[AccountObj alloc] init];
        uObj = [self convertDicToAccount:objDic lang:appdelegate.currentLang];
        [listOfFollowers addObject:uObj];
    }
    
    
    
}

-(AccountObj *)convertDicToAccount:(NSMutableDictionary *)objDic lang:(MyLanguages)lang{
    AccountObj *uObj = [[AccountObj alloc] init];
    uObj.fullName = [objDic objectForKey:fullNameKey];
    uObj.description = [objDic objectForKey:descriptionKey];
    uObj.followersCount = [NSString stringWithFormat:@"%li",[[objDic objectForKey:followersCountKey] integerValue]];
    uObj.statusCount = [NSString stringWithFormat:@"%li",[[objDic objectForKey:statusCountKey] integerValue]];
    uObj.userID = [objDic objectForKey:userIDKey];
    uObj.profileBackgroundImageUrl = [objDic objectForKey:profileBackgroundImageUrlKey];
    uObj.profileBackgroundImageUrlHttps = [objDic objectForKey:profileBackgroundImageUrlHttpsKey];
    uObj.profileImageUrl = [objDic objectForKey:profileImageUrlKey];
    uObj.profileImageUrlHttps = [objDic objectForKey:profileImageUrlHttpsKey];
    uObj.screenName = [NSString stringWithFormat:@"@%@",[objDic objectForKey:screenNameKey]];
    uObj.userLang = lang;
    return uObj;
}

-(void)updateDB:(BOOL)firsttime{
    NSString *query;
    //delete old records if it called from login page
    if (firsttime) {
        query = @"delete from follower";
        [self runQuery:query listOfFollowers:nil isInsertStat:FALSE];
    }
    query = @"insert into follower values";
    for (int i = 0; i < [listOfFollowers count]; i++) {
        if (i == 0)
            query = [NSString stringWithFormat:@"%@(null, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",query];
        else
            query = [NSString stringWithFormat:@"%@,(null, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",query];
    }
    [self runQuery:query listOfFollowers:listOfFollowers isInsertStat:YES];
    
}



#pragma mark - table delegate

-(CGFloat)tableView:(UITableView *)tblView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger height = 0;
    AccountObj *uObj = [[AccountObj alloc] init];
    uObj=[listOfFollowers objectAtIndex:(int)indexPath.row];
    
    static NSString *CellIdentifier=@"FollowerTableViewCell";
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - events

@end
