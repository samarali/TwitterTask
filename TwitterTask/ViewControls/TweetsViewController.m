//
//  TweetsViewController.m
//  TwitterTask
//
//  Created by Samar-Mac book on 9/1/16.
//

#import "TweetsViewController.h"
#import "AppDelegate.h"
#import "LocalizedMessages.h"
#import "commonFuntions.h"
#import "TweetsTableViewCell.h"
#import "STTwitterAPI.h"
#import "NSError+STTwitter.h"
#import "STHTTPRequest+STTwitter.h"
#import "NSDictionary+NotNull.h"

@interface TweetsViewController ()
@end

@implementation TweetsViewController

@synthesize userBGImg;
@synthesize userProfileImg;
@synthesize tableView;
@synthesize controlsView;
@synthesize selectedUser;
@synthesize loadFromServer;
@synthesize listOfTweets;
@synthesize noDataImg;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self customizeNavigationBar:YES WithMenu:YES];
    
    tableView.layoutMargins = UIEdgeInsetsZero;
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if (loadFromServer){
        [self loadTweetsOnline];
        [self initRefreshControl:self.tableView];
    }
    else{
        [self loadTweetsOffline];
        
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
    listOfTweets = [[NSMutableArray alloc] init];

    tableView.allowsMultipleSelectionDuringEditing = NO;
    
    userBGImg.image=[UIImage imageNamed:@"userBgdefault.png"];
    userProfileImg.image=[UIImage imageNamed:@"ProfileImg.png"];
}

-(void)locatizeLables{
    noDataLbl.text=TweetsNoDataFoundMsg;
}

-(void)switchToEnglishLayout{
}
-(void)switchToArabicLayout{
}


#pragma mark - methods
-(void)loadTweetsOnline{
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self showActivityViewer];
    
    [appDelegate.twitter getStatusesUserTimelineForUserID:selectedUser screenName:nil sinceID:nil count:@"10" maxID:nil trimUser:nil excludeReplies:nil contributorDetails:nil includeRetweets:nil successBlock:^(NSArray *statuses) {
        if ([statuses count]>0)
        {
            [self fillTweetsArray:statuses];
            [self updateimages:[listOfTweets objectAtIndex:0]];
            [self deleteOldTweets];
            [self AddNewTweetsDB];
        }
        [tableView reloadData];
        [self hideActivityViewer];
        
    } errorBlock:^(NSError *error) {
        [self loadTweetsOffline];
        [CommonFuntions showAlertWithTitle:ApplicationTitleText Message:[error localizedDescription]];
        [self hideActivityViewer];
    }];
    

}

-(void)fillTweetsArray:(NSArray *)tweets{
    NSMutableDictionary *objDic;
    TweetObj *tObj;
    listOfTweets = [[NSMutableArray alloc] init];
    
    for (int i =0 ; i < [tweets count]; i++) {
        objDic = [[NSMutableDictionary alloc] init];
        objDic = [tweets objectAtIndex:i];
        tObj = [[TweetObj alloc] init];
        tObj = [self convertDicToTweet:objDic];
        [listOfTweets addObject:tObj];
    }
}

-(TweetObj *)convertDicToTweet:(NSMutableDictionary *)objDic{
    TweetObj *tObj = [[TweetObj alloc] init];
    tObj.createdAt = [objDic objectForKeyedSubscript:tweetTimeKey];
    
    tObj.creatorObj = [[AccountObj alloc] init];
    
    tObj.creatorObj.userID = [NSString stringWithFormat:@"%@",[objDic valueForKeyPath:[NSString stringWithFormat:@"%@%@",tweetUserObjKey,userIDKey]]];
    tObj.creatorObj.profileBackgroundImageUrlHttps = [NSString stringWithFormat:@"%@",[objDic valueForKeyPath:[NSString stringWithFormat:@"%@%@",tweetUserObjKey,profileBackgroundImageUrlHttpsKey]]];
    tObj.creatorObj.profileImageUrlHttps = [NSString stringWithFormat:@"%@",[objDic valueForKeyPath:[NSString stringWithFormat:@"%@%@",tweetUserObjKey,profileImageUrlHttpsKey]]];
    tObj.creatorObj.screenName = [NSString stringWithFormat:@"@%@",[objDic valueForKeyPath:[NSString stringWithFormat:@"%@%@",tweetUserObjKey,screenNameKey]]];
    
    tObj.value = [objDic objectForKeyedSubscript:tweetTextKey];
    return tObj;
}


-(void)updateimages:(TweetObj *)obj{
    
    if (![CommonFuntions isStringEmpty:obj.creatorObj.profileImageUrlHttps]) {
        obj.creatorObj.profileImageUrlHttps = [obj.creatorObj.profileImageUrlHttps stringByReplacingOccurrencesOfString:@"_normal"
                                             withString:@""];
    }
    UIView *blockview = [[UIView alloc] initWithFrame:userProfileImg.frame];
    [blockview setBackgroundColor:[UIColor clearColor]];
    [self.view insertSubview:blockview aboveSubview:userProfileImg];
    
    UIActivityIndicatorView *activityindecator = [[UIActivityIndicatorView alloc] init];
    NSInteger loaderXPox = (blockview.frame.size.width - 20) / 2;
    NSInteger loaderYPox = (blockview.frame.size.height - 20) / 2;
    activityindecator.frame = CGRectMake(loaderXPox, loaderYPox, 20, 20);
    
    [activityindecator startAnimating];
    [activityindecator setColor:[UIColor darkGrayColor]];
    [blockview addSubview:activityindecator];
    
    NSURL *imageURL;
    imageURL =[NSURL URLWithString:obj.creatorObj.profileImageUrlHttps];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        activityindecator.hidden = FALSE;
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                userProfileImg.image = image;
            });
            activityindecator.hidden = YES;
            //[self.cf performTransition:@"fading" viewController:blockimage];
        }
        else
            activityindecator.hidden = YES;
    });
    
    
    if (![CommonFuntions isStringEmpty:obj.creatorObj.profileBackgroundImageUrlHttps]) {
        imageURL =[NSURL URLWithString:obj.creatorObj.profileBackgroundImageUrlHttps];
        
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            
            NSData *data = [NSData dataWithContentsOfURL:imageURL];
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    userBGImg.image = image;
                });
            }
        });
    }
}
-(void)deleteOldTweets
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self runQuery:[NSString stringWithFormat:@"%@%@ where %@=%@",deleteStatmentKey,tweetTableKey,tweetCreatorIDKey,selectedUser] listOfFollowers:nil listOfTweets:nil isInsertStat:FALSE];
}

-(void)AddNewTweetsDB{
    NSString *query;
    query = @"insert into tweet values";
    for (int i = 0; i < [listOfTweets count]; i++) {
        if (i == 0)
            query = [NSString stringWithFormat:@"%@(null, ?, ?, ?)",query];
        else
            query = [NSString stringWithFormat:@"%@,(null, ?, ?, ?)",query];
    }
    [self runQuery:query listOfFollowers:nil listOfTweets:listOfTweets isInsertStat:YES];
    
}

-(void)loadTweetsOffline{
    listOfTweets = [self runQuery:[NSString stringWithFormat:@"%@%@ where %@=%@",selectStatmentKey,tweetTableKey,tweetCreatorIDKey,selectedUser]];
    
    
    if ([listOfTweets count] > 0) {
        NSMutableArray* arr = [[NSMutableArray alloc] initWithArray:listOfTweets];
        [listOfTweets removeAllObjects];
        TweetObj *tObj;
        
    
        NSMutableArray *listOffollowers = [[NSMutableArray alloc] initWithArray:[self runQuery:[NSString stringWithFormat:@"%@%@ where %@=%@",selectStatmentKey,followerTableKey,userIDKey,selectedUser]]];
        if ([listOffollowers count] > 0) {
            
            NSMutableDictionary *objDic;
            NSMutableDictionary *internalUserObj = [[NSMutableDictionary alloc] initWithDictionary:[self setFollowerObjDic:[listOffollowers objectAtIndex:0]]];
            
            for (int i=0; i<[arr count]; i++) {
                objDic = [[NSMutableDictionary alloc] init];
                objDic = [arr objectAtIndex:i];
                [objDic setObject:internalUserObj forKey:userObjKey];
                
                tObj = [[TweetObj alloc] init];
                //add to objDic user data
                tObj = [self convertDicToTweet:objDic];
                [listOfTweets addObject:tObj];
            }
        }
    }
    [tableView reloadData];
    
}
-(NSMutableDictionary *)setFollowerObjDic:(NSMutableDictionary *)obj
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[obj valueForKey:screenNameKey] forKey:screenNameKey];
    [dic setObject:[obj valueForKey:profileBackgroundImageUrlHttpsKey] forKey:profileBackgroundImageUrlHttpsKey];
    [dic setObject:[obj valueForKey:profileImageUrlHttpsKey] forKey:profileImageUrlHttpsKey];
    [dic setObject:[obj valueForKey:userIDKey] forKey:userIDKey];
    return dic;
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
    TweetObj *tObj = [[TweetObj alloc] init];
    tObj=[listOfTweets objectAtIndex:(int)indexPath.row];
    
    static NSString *CellIdentifier=@"TweetsTableViewCell";
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.currentLang==English)
        CellIdentifier=@"TweetsTableViewCell_en";
    else
        CellIdentifier=@"TweetsTableViewCell";
    
    TweetsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[TweetsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.valueValLbl.numberOfLines = 1000;
    cell.creatorNameValLbl.numberOfLines = 1000;
    cell.createdAtValLbl.numberOfLines = 1000;

    
    cell.valueValLbl.text=tObj.value;
    cell.creatorNameValLbl.text=tObj.creatorObj.screenName;
    cell.createdAtValLbl.text=tObj.createdAt;
    
    
    CGRect newFrame = cell.valueValLbl.frame;
    CGSize newSize = [cell.valueValLbl sizeThatFits:CGSizeMake(cell.valueValLbl.frame.size.width, MAXFLOAT)];
    newFrame.size = CGSizeMake(fmaxf(newSize.width, cell.valueValLbl.frame.size.width), newSize.height);
    height+=newFrame.size.height;
    
    newFrame = cell.creatorNameValLbl.frame;
    newSize = [cell.creatorNameValLbl sizeThatFits:CGSizeMake(cell.creatorNameValLbl.frame.size.width, MAXFLOAT)];
    newFrame.size = CGSizeMake(fmaxf(newSize.width, cell.creatorNameValLbl.frame.size.width), newSize.height);
    NSInteger creatorLblHeight = newFrame.size.height;
    
    newFrame = cell.createdAtValLbl.frame;
    newSize = [cell.createdAtValLbl sizeThatFits:CGSizeMake(cell.createdAtValLbl.frame.size.width, MAXFLOAT)];
    newFrame.size = CGSizeMake(fmaxf(newSize.width, cell.createdAtValLbl.frame.size.width), newSize.height);
    NSInteger createdAtLblHeight = newFrame.size.height;
    
    NSInteger finalBiggerHeight = 0;
    if (creatorLblHeight > createdAtLblHeight)
        finalBiggerHeight = creatorLblHeight;
    else
        finalBiggerHeight = createdAtLblHeight;
    height+=finalBiggerHeight;
    
    //separation space
    height += 15;

    return height;
}


-(UITableViewCell*) tableView:(UITableView *)tblView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier=@"TweetsTableViewCell";
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.currentLang==English)
        CellIdentifier=@"TweetsTableViewCell_en";
    else
        CellIdentifier=@"TweetsTableViewCell";
    
    TweetsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[TweetsTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    TweetObj *obj=nil;
    
    obj=[listOfTweets objectAtIndex:(int)indexPath.row];
    [cell initWithTweetObj:obj withRowId:(int)indexPath.row];
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section{

    if([listOfTweets count]==0){
        noDataLbl.hidden=NO;
        noDataImg.hidden=NO;
        return 0;
    }
    noDataLbl.hidden=YES;
    noDataImg.hidden=YES;
    return [listOfTweets count];
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

#pragma mark - refresh

- (void)refresh:(UIRefreshControl *)refreshControl_ {
    [self loadTweetsOnline];
    [refreshControl endRefreshing];
}


@end
