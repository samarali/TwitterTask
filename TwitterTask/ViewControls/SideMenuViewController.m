//
//  SideMenuViewController.m
//  TwitterTask
//
//  Created by Samar-Mac book on 8/31/16.
//

#import "SideMenuViewController.h"
#import "TweetsViewController.h"
#import "AppDelegate.h"
#import "SideMenuCell.h"
#import "LocalizedMessages.h"
#import "CustomNavigationController.h"
#import "BaseViewController.h"
#import "CommonFuntions.h"
#import "STTwitterAPI.h"
#import "NSError+STTwitter.h"
#import "STHTTPRequest+STTwitter.h"
#import <Accounts/Accounts.h>


typedef void (^accountChooserBlock_t)(ACAccount *account, NSString *errorMessage); // don't bother with NSError for

@interface SideMenuViewController ()
@property (nonatomic, strong) NSArray *iOSAccounts;
@property (nonatomic, strong) accountChooserBlock_t accountChooserBlock;
@end

@implementation SideMenuViewController
@synthesize menuTitleLbl,imageView;

- (id)initWithCoder:(NSCoder *)aDecoder     {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        //  [notificationsSwitch addTarget:self action:@selector(switchChangesState:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

#pragma mark - table delegate

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    static NSString *CellIdentifier=@"SideMenuCell";
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.currentLang==English)
        CellIdentifier=@"SideMenuCell_en";
    else
        CellIdentifier=@"SideMenuCell";
    
    SideMenuCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[SideMenuCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    [cell initWithMenu:[SideMenuCellObj getMenuForindex:(int)indexPath.row]];
    
    return cell;
    //return nil;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        return NumberMenuItems;
}
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return 1;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    NSString * viewControllerName =[SideMenuCellObj getViewControllerName:(int)indexPath.row];
    
    if([CommonFuntions isStringEmpty:viewControllerName]){
        
    }
    else if ([viewControllerName isEqualToString:TweetsScreenName]) {
        
        
    
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CustomNavigationController *navigationController = (CustomNavigationController *)appDelegate.centerController;
        [((BaseViewController*)[navigationController getTopView]) onMenuButtonPressed:nil];
    
        TweetsViewController *tweetsController = [self.storyboard instantiateViewControllerWithIdentifier:TweetsScreenName];
        if ([CommonFuntions hasConnectivity])
            tweetsController.loadFromServer = YES;
        else
            tweetsController.loadFromServer = FALSE;
        tweetsController.selectedUser = appDelegate.userObj.userID;
        if([[navigationController getTopView] class]!=[tweetsController class]){
            [navigationController pushViewController:tweetsController animated:YES];
        }
    }
    else if ([viewControllerName isEqualToString:@"loadUsers"])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CustomNavigationController *navigationController = (CustomNavigationController *)appDelegate.centerController;
        [((BaseViewController*)[navigationController getTopView]) onMenuButtonPressed:nil];
        [self LoadUsers];
    }
    
}


#pragma mark - view

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self changeLocalization];

}
-(void) viewDidLoad{
    [super viewDidLoad];
}


- (void)setPanning:(BOOL)allow  {
    self.viewDeckController.panningMode = allow ? IIViewDeckFullViewPanning : IIViewDeckNoPanning ;
}

#pragma mark - methods

-(void)changeLocalization{
    menuTitleLbl.text=MenuTitleText;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.currentLang==Arabic){
        CGRect frame=menuTitleLbl.frame;
        
            frame.origin.x=MenuStartX;
        menuTitleLbl.frame=frame;
        
        frame=imageView.frame;
        
            frame.origin.x=MenuStartX;
        imageView.frame=frame;
    }else{
        CGRect frame=menuTitleLbl.frame;
        frame.origin.x=0;
        menuTitleLbl.frame=frame;
        
        frame=imageView.frame;
        frame.origin.x=0;
        imageView.frame=frame;
    }
    [self.tableView reloadData];
}

-(void)LoadUsers{
    
    [self chooseAccount];
    
    __weak typeof(self) weakSelf = self;
    self.accountChooserBlock = ^(ACAccount *account, NSString *errorMessage) {
        if(account) {
            [weakSelf loginWithiOSAccount:account];
        } else {
            [CommonFuntions showAlertWithTitle:ApplicationTitleText Message:errorMessage];
        }
        
        
    };
}

//Preview actionsheet with user saved
- (void)chooseAccount {
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init] ;
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreRequestCompletionHandler = ^(BOOL granted, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if(granted == NO) {
                _accountChooserBlock(nil, @"Acccess not granted.");
                return;
            }
            
            self.iOSAccounts = [accountStore accountsWithAccountType:accountType];
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select an account:"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil otherButtonTitles:nil];
            for(ACAccount *account in _iOSAccounts) {
                [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"@%@", account.username]];
            }
            [actionSheet showInView:self.view.window];
        }];
    };
    
    
#if TARGET_OS_IPHONE &&  (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) {
        [accountStore requestAccessToAccountsWithType:accountType
                                     withCompletionHandler:accountStoreRequestCompletionHandler];
    } else {
        [accountStore requestAccessToAccountsWithType:accountType options:NULL completion:accountStoreRequestCompletionHandler];
    }
#else
    [accountStore requestAccessToAccountsWithType:accountType options:NULL completion:accountStoreRequestCompletionHandler];
#endif
    
}

- (void)loginWithiOSAccount:(ACAccount *)userAccount {
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CustomNavigationController *navigationController = (CustomNavigationController *)appDelegate.centerController;
    
    appDelegate.twitter = nil;
    
    ACAccount *ac = [[ACAccount alloc] init];
    ac.username = userAccount.username;
    
    appDelegate.twitter = [STTwitterAPI twitterAPIOSWithAccount:ac delegate:self];
    
    [((BaseViewController*)[navigationController getTopView]) showActivityViewer];
    [appDelegate.twitter verifyCredentialsWithUserSuccessBlock:^(NSDictionary *account) {
        [((BaseViewController*)[navigationController getTopView]) hideActivityViewer];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:account];
        
        
        [dic setObject:appDelegate.twitter.oauthAccessToken forKeyedSubscript:accessTokenKey];
        [dic setObject:appDelegate.twitter.oauthAccessTokenSecret forKeyedSubscript:accessTokenSecretKey];
        [((BaseViewController*)[navigationController getTopView]) saveUserData:dic];
        if ([CommonFuntions hasConnectivity])
            [((BaseViewController*)[navigationController getTopView]) loadFollowerScreen:YES];
        else
            [((BaseViewController*)[navigationController getTopView]) loadFollowerScreen:FALSE];
        
        
        
    } errorBlock:^(NSError *error) {
        [((BaseViewController*)[navigationController getTopView]) hideActivityViewer];
        NSMutableArray *listOfusers = [[NSMutableArray alloc] init];
        listOfusers = [((BaseViewController*)[navigationController getTopView]) runQuery:[NSString stringWithFormat:@"%@%@where screen_name=\"@%@\"",selectStatmentKey,userTableKey,userAccount.username]];
        if ([listOfusers count] > 0) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[listOfusers objectAtIndex:0]];
            [((BaseViewController*)[navigationController getTopView]) saveUserData:dic];
            if ([CommonFuntions hasConnectivity])
                [((BaseViewController*)[navigationController getTopView]) loadFollowerScreen:YES];
            else
                [((BaseViewController*)[navigationController getTopView]) loadFollowerScreen:FALSE];
        }
        [CommonFuntions showAlertWithTitle:ApplicationTitleText Message:[error localizedDescription]];
    }];
    
}

#pragma mark STTwitterAPIOSProtocol

- (void)twitterAPI:(STTwitterAPI *)twitterAPI accountWasInvalidated:(ACAccount *)invalidatedAccount {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(twitterAPI != appDelegate.twitter) return;
}


#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == [actionSheet cancelButtonIndex]) {
        _accountChooserBlock(nil, ActionSheetCancelTxt);
        return;
    }
    
    NSUInteger accountIndex = buttonIndex - 1;
    ACAccount *account = [_iOSAccounts objectAtIndex:accountIndex];
    
    _accountChooserBlock(account, nil);
}

@end
