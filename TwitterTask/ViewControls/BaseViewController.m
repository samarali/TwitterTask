//
//  BaseViewController.m
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

//

#import "BaseViewController.h"
#import "AppDelegate.h"
#import "CustomNavigationController.h"
#import "StaticVariables.h"
#import "LoginViewController.h"
#import "FollowersViewController.h"
#import "AccountObj.h"
#import "TweetObj.h"
#import "CommonFuntions.h"
#import "NSDictionary+NotNull.h"

@interface BaseViewController ()

@end

@implementation BaseViewController
@synthesize BGImage;
@synthesize noDataLbl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - view events
- (void)viewDidLoad{
    [super viewDidLoad];
    BGImage.image=[UIImage imageNamed:@"bg.png"];
    self.view.backgroundColor=[ UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1];
    [self initalizeViews];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self switchLayout];
    [self locatizeLables];
}
- (void)customizeNavigationBar:(BOOL)withHome WithMenu:(BOOL)withMenu   {
    
    if ([self.navigationController respondsToSelector:@selector(setPanning:)]) {
        CustomNavigationController * navigation = (CustomNavigationController *)self.navigationController;
        [navigation setPanning:withMenu];
    }
    
    self.navigationController.navigationBar.hidden = NO;
    
    self.navigationController.navigationBar.translucent = NO;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeTop;
    
    self.navigationItem.hidesBackButton = YES;
    UINavigationBar *navBar = [[self navigationController] navigationBar];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIImage *backgroundImage;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        backgroundImage = [UIImage imageNamed:@"header_20.png"];
        [[UIBarButtonItem appearance] setTintColor:[BaseViewController getBackBtnColor]];
        
    }else {
        backgroundImage = [UIImage imageNamed:@"header.png"];
        [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
        [[[self navigationController] navigationBar] setTintColor:[UIColor whiteColor]];
    }
    
    if (withMenu) {
        UIButton *menubarButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 46, 15, 36, 36)];
        [menubarButton setImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
        [menubarButton setImage:[UIImage imageNamed:@"menu_btn_pressed"] forState:UIControlStateHighlighted];
        UIBarButtonItem* barButton = [[UIBarButtonItem alloc]
                                      initWithCustomView:menubarButton];
        if(appDelegate.currentLang==Arabic)
            self.navigationItem.rightBarButtonItem = barButton;
        else
            self.navigationItem.leftBarButtonItem = barButton;
        [menubarButton addTarget:self action:@selector(onMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (withHome) {
        UIButton *homebarButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 15, 36, 36)];
        [homebarButton setImage:[UIImage imageNamed:@"home_btn"] forState:UIControlStateNormal];
        [homebarButton setImage:[UIImage imageNamed:@"home_btn_pressed"] forState:UIControlStateHighlighted];
        UIBarButtonItem* barButtonHome = [[UIBarButtonItem alloc]
                                          initWithCustomView:homebarButton];
        
        if(appDelegate.currentLang==Arabic)
            self.navigationItem.leftBarButtonItem = barButtonHome;
        else
            self.navigationItem.rightBarButtonItem = barButtonHome;
        [homebarButton addTarget:self action:@selector(onHomePressed:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    self.navigationItem.hidesBackButton = YES;

    [navBar setBackgroundImage:backgroundImage forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    navBar.barTintColor=[UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1];
    navBar.shadowImage = [[UIImage alloc] init];

    
}

- (IBAction)goBack:(id)sender   {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onHomePressed:(id)sender
{
    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    AccountObj * obj= [self getloggedinUSer];
    
    if(!appdelegate.islogOut){
        
        if(obj==nil||obj.screenName==nil||[CommonFuntions isStringEmpty:obj.screenName])
        {
            LoginViewController *dash=[self.storyboard instantiateViewControllerWithIdentifier:LoginScreenName];
            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
                [self.navigationController pushViewController:dash animated:YES];
            }else{
                for (UIViewController *viewController in self.navigationController.viewControllers) {
                    if ([viewController class] == [LoginViewController class]) {
                        [self.navigationController popToViewController:viewController animated:NO];
                        break;
                    }
                }
            }
        }
        else{
            FollowersViewController *followerController=[self.storyboard instantiateViewControllerWithIdentifier:FollowerScreenName];
            
            if ([CommonFuntions hasConnectivity])
                followerController.loadFromServer = YES;
            else
                followerController.loadFromServer = FALSE;
            
            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
                [self.navigationController pushViewController:followerController animated:YES];
            }else{
                for (UIViewController *viewController in self.navigationController.viewControllers) {
                    if ([viewController class] == [FollowersViewController class]) {
                        [self.navigationController popToViewController:viewController animated:NO];
                        break;
                        
                    }
                }
            }
        }
    }
    else
    {
        LoginViewController *login=[self.storyboard instantiateViewControllerWithIdentifier:LoginScreenName];
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
            [self.navigationController pushViewController:login animated:YES];
        }else{
            for (UIViewController *viewController in self.navigationController.viewControllers) {
                if ([viewController class] == [LoginViewController class]) {
                    [self.navigationController popToViewController:viewController animated:NO];
                    break;
                    
                }
            }
        }
    }
    
    
}

- (IBAction)onMenuButtonPressed:(id)sender  {
    self.viewDeckController.panningCancelsTouchesInView=YES;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CustomNavigationController *nav = (    CustomNavigationController *)self.navigationController;
    if(delegate.currentLang==English){

        [nav.viewDeckController toggleLeftViewAnimated:YES];
    }else{

        [nav.viewDeckController toggleRightViewAnimated:YES];
    }
}

- (void) hideMenuViewer
{
    self.viewDeckController.panningCancelsTouchesInView=YES;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CustomNavigationController *nav = (    CustomNavigationController *)self.navigationController;
    if(delegate.currentLang==English){
        
        [nav.viewDeckController toggleLeftViewAnimated:FALSE];
    }else{
        
        [nav.viewDeckController toggleRightViewAnimated:FALSE];
    }
}

#pragma mark - touch methods


//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self onMenuButtonPressed:nil];
}

- (void)initalizeViews {
    
}

#pragma mark - localize lables

-(void)locatizeLables{
}

#pragma mark - layout funtions
-(void)switchLayout{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(delegate.currentLang==Arabic){
        [self switchToArabicLayout];
    }else if(delegate.currentLang==English){
        [self switchToEnglishLayout];
    }
}

-(void)switchToEnglishLayout{
    
}

-(void)switchToArabicLayout{
    
}

#pragma mark- activity funtions


-(void)showActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = delegate.window;
    activityView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, window.bounds.size.width, window.bounds.size.height)];
    activityView.backgroundColor = [UIColor blackColor];
    activityView.alpha = 0.5;
    
    UIActivityIndicatorView *activityWheel = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(window.bounds.size.width / 2 - 12, window.bounds.size.height / 2 - 12, 24, 24)];
    activityWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activityWheel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleBottomMargin);
    [activityWheel setColor:[UIColor colorWithRed:32.0/255.0 green:145.0/255.0 blue:206.0/255.0 alpha:1]];
    [activityView addSubview:activityWheel];
    [window addSubview: activityView];
    
    [[[activityView subviews] objectAtIndex:0] startAnimating];
}
-(void)hideActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [[[activityView subviews] objectAtIndex:0] stopAnimating];
    [activityView removeFromSuperview];
    activityView = nil;
}

#pragma mark - back button color

+ (UIColor*)getBackBtnColor{
    return [UIColor whiteColor];
}

#pragma mark - methods

-(NSMutableArray *)runQuery:(NSString *)query{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",dbNameKey, dbTypeKey]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]){
        NSString *bundle = [[NSBundle mainBundle] pathForResource:dbNameKey ofType:dbTypeKey];
        [fileManager copyItemAtPath:bundle toPath: path error:&error];
    }
    sqlite3 *sqlite3Database;
    
    // Open the database.
    if(sqlite3_open([path UTF8String], &sqlite3Database) == SQLITE_OK) {
        sqlite3_stmt *statement;
        sqlite3_prepare_v2(sqlite3Database, [query UTF8String], -1, &statement, nil);
        
        NSMutableDictionary *obj;
        // Loop through the results and add them to the results array row by row.
        while(sqlite3_step(statement) == SQLITE_ROW) {
            
            // Get the total number of columns.
            int totalColumns = sqlite3_column_count(statement);
            obj = [[NSMutableDictionary alloc] init];
            // Go through all columns and fetch each column data.
            for (int i=0; i<totalColumns; i++){
                char *dbDataNameAsChars = (char *)sqlite3_column_name(statement, i);
                char *dbDataAsChars = (char *)sqlite3_column_text(statement, i);
                
                
                if (dbDataAsChars != nil) {
                    NSLog(@"%@",[NSString stringWithUTF8String:dbDataAsChars]);
                }
                
                [obj setValue:[NSString stringWithUTF8String:dbDataAsChars] forKey:[NSString  stringWithUTF8String:dbDataNameAsChars]];
            }
            // Store each fetched data row in the results array, but first check if there is actually data.
            [list addObject:obj];
        }
        
        sqlite3_finalize(statement);
    }
    // Close the database.
    sqlite3_close(sqlite3Database);
    
    
    return list;
}
-(void)runQuery:(NSString *)query listOfFollowers:(NSMutableArray *)listOfFollowers listOfTweets:(NSMutableArray *)listOfTweets isInsertStat:(BOOL)isInsertStat{
    
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",dbNameKey, dbTypeKey]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]){
        NSString *bundle = [[NSBundle mainBundle] pathForResource:dbNameKey ofType:dbTypeKey];
        [fileManager copyItemAtPath:bundle toPath: path error:&error];
    }
    sqlite3 *sqlite3Database;
    
    // Open the database.
    if(sqlite3_open([path UTF8String], &sqlite3Database) == SQLITE_OK) {
        sqlite3_stmt *statement;
        sqlite3_prepare_v2(sqlite3Database, [query UTF8String], -1, &statement, nil);
        
        if (isInsertStat) {
            if (listOfFollowers != nil) {
                AccountObj *obj;
                for (int i =0; i < [listOfFollowers count]; i++) {
                    obj = [[AccountObj alloc] init];//2
                    obj = [listOfFollowers objectAtIndex:i];
                    sqlite3_bind_text(statement,((i*11) + 1), [obj.fullName UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, ((i*11) + 2), [obj.description UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, ((i*11) + 3), [obj.followersCount UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, ((i*11) + 4), [obj.statusCount UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, ((i*11) + 5), [obj.userID UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, ((i*11) + 6), [obj.profileBackgroundImageUrl UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, ((i*11) + 7), [obj.profileBackgroundImageUrlHttps UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, ((i*11) + 8), [obj.profileImageUrl UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, ((i*11) + 9), [obj.profileImageUrlHttps UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, ((i*11) + 10), [obj.screenName UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, ((i*11) + 11), [obj.parentID UTF8String], -1, SQLITE_TRANSIENT);
                    
                }
            }
            else if (listOfTweets != nil)
            {
                TweetObj *obj;
                for (int i =0; i < [listOfTweets count]; i++) {
                    obj = [[TweetObj alloc] init];//2
                    obj = [listOfTweets objectAtIndex:i];
                    sqlite3_bind_text(statement,((i*3) + 1), [obj.creatorObj.userID UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, ((i*3) + 2), [obj.createdAt UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, ((i*3) + 3), [obj.value UTF8String], -1, SQLITE_TRANSIENT);
                }
            }
            else
            {
                AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                sqlite3_bind_text(statement,1, [appdelegate.userObj.screenName UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement,2, [appdelegate.userObj.userID UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement,3, [appdelegate.userObj.profileBackgroundImageUrlHttps UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement,4, [appdelegate.userObj.profileImageUrlHttps UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement,5, [appdelegate.userObj.accessTokenSecret UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement,6, [appdelegate.userObj.accessToken UTF8String], -1, SQLITE_TRANSIENT);
            }

            
        }
        // Execute the query.
        if (sqlite3_step(statement) == SQLITE_DONE)
            NSLog(@"Query was executed successfully. Affected rows = %d", sqlite3_changes(sqlite3Database));
        else
            NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
        
        sqlite3_finalize(statement);
    }
    // Close the database.
    sqlite3_close(sqlite3Database);
    
    
    
    
}

-(void)loadFollowerScreen:(BOOL)loadfromServer
{
    FollowersViewController *followerController = (FollowersViewController *)[self.storyboard instantiateViewControllerWithIdentifier:FollowerScreenName];
    followerController.loadFromServer = loadfromServer;
    [self.navigationController pushViewController:followerController animated:YES];
}
-(void)saveUserData:(NSMutableDictionary *)account
{
    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    appdelegate.userObj = [[AccountObj alloc] init];
    appdelegate.userObj.userID = [account objectForKeyedSubscript:userIDKey];
    NSString *profileBackgroundImageUrlHttps = [account objectForKeyedSubscript:profileBackgroundImageUrlHttpsKey];
    if ([CommonFuntions isStringNull:profileBackgroundImageUrlHttps]) {
        profileBackgroundImageUrlHttps = @"";
    }
    appdelegate.userObj.profileBackgroundImageUrlHttps = profileBackgroundImageUrlHttps;
    appdelegate.userObj.profileImageUrlHttps = [account objectForKeyedSubscript:profileImageUrlHttpsKey];
    appdelegate.userObj.screenName = [NSString stringWithFormat:@"@%@",[account objectForKeyedSubscript:screenNameKey]];
    appdelegate.userObj.accessToken = [NSString stringWithFormat:@"%@",[account objectForKeyedSubscript:accessTokenKey]];
    appdelegate.userObj.accessTokenSecret = [NSString stringWithFormat:@"%@",[account objectForKeyedSubscript:accessTokenSecretKey]];
    
    NSString *query;
    query = @"update user set is_selected='0'";
    [self runQuery:query listOfFollowers:nil listOfTweets:nil isInsertStat:FALSE];
    
    NSMutableArray *listOfusers;
    listOfusers = [self runQuery:[NSString stringWithFormat:@"%@%@ where id_str=%@",selectStatmentKey,userTableKey,appdelegate.userObj.userID]];
    if ([listOfusers count]>0){
        query = [NSString stringWithFormat:@"update %@ set is_selected='1' where id_str=%@",userTableKey,appdelegate.userObj.userID];
        [self runQuery:query listOfFollowers:nil listOfTweets:nil isInsertStat:FALSE];
    }else
    {
        query = [NSString stringWithFormat:@"%@ %@ values(null, ?, ?, ?, ?, ?, ?, '1')",insertStatmentKey,userTableKey];
        [self runQuery:query listOfFollowers:nil listOfTweets:nil isInsertStat:YES];
    }
    
    
}

-(AccountObj*)getloggedinUSer{
    AccountObj *userObj=[[AccountObj alloc] init];
    
    NSMutableArray *listOfusers = [[NSMutableArray alloc] init];
    listOfusers = [self runQuery:[NSString stringWithFormat:@"%@%@ where is_selected=1",selectStatmentKey,userTableKey]];
    if ([listOfusers count] > 0) {
        NSMutableDictionary *user = [listOfusers objectAtIndex:0];
        userObj = [[AccountObj alloc] init];
        userObj.screenName = [user objectForKeyedSubscript:screenNameKey];
        userObj.userID = [user objectForKeyedSubscript:userIDKey];
        userObj.profileBackgroundImageUrlHttps = [user objectForKeyedSubscript:profileBackgroundImageUrlHttpsKey];
        userObj.profileImageUrlHttps = [user objectForKeyedSubscript:profileImageUrlHttpsKey];
        userObj.accessToken = [user objectForKeyedSubscript:accessTokenKey];
        userObj.accessTokenSecret = [user objectForKeyedSubscript:accessTokenSecretKey];
        return userObj;
    }
    return nil;
    
}
-(void)logout{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.islogOut=YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:AccessTokenName];
    [defaults setObject:@"" forKey:AccessTokenSecretName];
    [defaults synchronize];
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        //[self.navigationController popToRootViewControllerAnimated:NO];
    }else{
        for (UIViewController *viewController in self.navigationController.viewControllers) {
            if ([viewController class] == [LoginViewController class]) {
                [self.navigationController popToViewController:viewController animated:NO];
                break;
                
            }
        }
    }
    UIViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier:LoginScreenName];
    [self.navigationController pushViewController:viewController animated:YES];
}
-(void)initRefreshControl:(UITableView*)tableView{
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setTintColor:[UIColor whiteColor]];
    UIColor *color = [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1];
    [refreshControl setBackgroundColor:color];
    refreshControl.layer.zPosition = tableView.backgroundView.layer.zPosition + 1;
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [tableView addSubview:refreshControl];
    
}

- (void)refresh:(UIRefreshControl *)refreshControl_ {
}
#pragma mark - refresh data
-(void) refreshView{
    
}



@end
