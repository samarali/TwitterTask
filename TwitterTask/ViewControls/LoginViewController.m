//
//  LoginViewController.m
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

//

#import "LoginViewController.h"
#import "FollowersViewController.h"
#import "LocalizedMessages.h"
#import "AppDelegate.h"
#import "CommonFuntions.h"
#import "STTwitterAPI.h"
#import "NSError+STTwitter.h"
#import "STHTTPRequest+STTwitter.h"
#import <Accounts/Accounts.h>

typedef void (^accountChooserBlock_t)(ACAccount *account, NSString *errorMessage); // don't bother with NSError for that

@interface LoginViewController ()
@end

@implementation LoginViewController
@synthesize loginBtn;
@synthesize langBtn;
@synthesize cancelWebViewBtn;
@synthesize webView;
@synthesize controlsView;
@synthesize savedAccessToken;
@synthesize savedAccessTokenSecret;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    AccountObj *userObj = [[AccountObj alloc] init];
    userObj = [CommonFuntions getSavedData];
    //update the app lanuguage with last selected language
    if(![CommonFuntions isStringNull:[[NSUserDefaults standardUserDefaults] objectForKey: userLangKey]] && ![CommonFuntions isStringEmpty:[[NSUserDefaults standardUserDefaults] objectForKey: userLangKey]])
    {
        NSString *lastLanguageStr = [[NSUserDefaults standardUserDefaults] objectForKey: userLangKey];
        if(appDelegate.currentLang!=[lastLanguageStr integerValue])
            [self onLanguagePressed:nil];
        appDelegate.currentLang=(MyLanguages)[lastLanguageStr integerValue];
    }
    else{
        [defaults setObject:[NSString stringWithFormat:@"%i",appDelegate.currentLang] forKey:userLangKey];
        [defaults synchronize];
    }
    
    
    appDelegate.twitter = [[STTwitterAPI alloc] init];
    
    if (!appDelegate.islogOut) {
        if ([CommonFuntions hasConnectivity]) {
            if ([CommonFuntions isStringNull:[[NSUserDefaults standardUserDefaults] objectForKey: ConsumerKeyName]] || [CommonFuntions isStringNull:[[NSUserDefaults standardUserDefaults] objectForKey: ConsumerSecretKeyName]]) {
                
                [defaults setObject:ConsumerKey forKey:ConsumerKeyName];
                [defaults setObject:ConsumerSecret forKey:ConsumerSecretKeyName];
                [defaults synchronize];
            }
            
            savedAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey: AccessTokenName];
            savedAccessTokenSecret = [[NSUserDefaults standardUserDefaults] objectForKey: AccessTokenSecretName];
            
            if (![savedAccessToken isEqualToString:@""] && ![CommonFuntions isStringNull:savedAccessToken]) {
                [self showActivityViewer];
                appDelegate.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:ConsumerKey consumerSecret:ConsumerSecret oauthToken:savedAccessToken oauthTokenSecret:savedAccessTokenSecret];
                
                [appDelegate.twitter getAccountVerifyCredentialsWithIncludeEntites:nil skipStatus:nil includeEmail:nil successBlock:^(NSDictionary *account) {
                    
                    [self saveUserData:account];
                    [self loadFollowerScreen:YES];
                    [self hideActivityViewer];
                }errorBlock:^(NSError *error) {
                    [CommonFuntions showAlertWithTitle:ApplicationTitleText Message:[error localizedDescription]];
                    [self hideActivityViewer];
                }];
                
            }
        }
        else if (userObj != nil)
        {
            [self loadFollowerScreen:FALSE];
        }
    }
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - base methods

-(void)initalizeViews{
    self.BGImage.image= [UIImage imageNamed:@"login-bg.png"];
}

-(void)locatizeLables{
    
    [loginBtn setTitle:loginLblText forState:UIControlStateNormal];
}

-(void)switchToEnglishLayout{
    [langBtn setImage:[UIImage imageNamed:@"language_ar.png"] forState:UIControlStateNormal];
}

-(void)switchToArabicLayout{
    [langBtn setImage:[UIImage imageNamed:@"language.png"] forState:UIControlStateNormal];
}

#pragma mark - events

-(IBAction)onLoginPressed:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:ConsumerKey
                                                        consumerSecret:ConsumerSecret oauthToken:nil oauthTokenSecret:nil];

    [self showActivityViewer];
    [appDelegate.twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [self previewWebview:request];
        
    } authenticateInsteadOfAuthorize:NO
                    forceLogin:@(YES)
                    screenName:nil
                 oauthCallback:@"myapplication://twitter_access_tokens/"
                    errorBlock:^(NSError *error) {
                        [self hideActivityViewer];
                        [CommonFuntions showAlertWithTitle:ApplicationTitleText Message:[error localizedDescription]];
                    }];

}

-(IBAction)onLanguagePressed:(id)sender{
        [self setAppLanguage];
        [self locatizeLables];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDelegate.currentLang==English){
            [self switchToEnglishLayout];
        }else{
            [self switchToArabicLayout];
        }
}

- (IBAction)onCancelWebView:(id)sender{
    [self hideWebview];
}


#pragma mark - methods 

-(void) setAppLanguage{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *language=@"";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(delegate.currentLang==Arabic){
        language=@"en";
        delegate.currentLang=English;
        [defaults setObject:@"1" forKey:userLangKey];
    }else if(delegate.currentLang==English){
        language= @"ar";
        delegate.currentLang=Arabic;
        [defaults setObject:@"0" forKey:userLangKey];
    }
    [defaults synchronize];
    
    
    ICLocalizationSetLanguage(language);
    
    [delegate switchMenuDirection];
    
}
-(void)previewWebview:(NSURLRequest *)request
{
    cancelWebViewBtn.hidden = FALSE;
    webView.hidden = FALSE;
    [webView loadRequest:request];
    //[[UIApplication sharedApplication] openURL:request.URL];
}
-(void)hideWebview
{
    cancelWebViewBtn.hidden = YES;
    webView.hidden = YES;
}

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    [self hideWebview];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret , NSString *userID, NSString *screenName) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:appDelegate.twitter.oauthAccessToken forKey:AccessTokenName];
        [defaults setObject:appDelegate.twitter.oauthAccessTokenSecret forKey:AccessTokenSecretName];
        [defaults synchronize];
        
        
        [self showActivityViewer];
        
        [appDelegate.twitter getAccountVerifyCredentialsWithIncludeEntites:nil skipStatus:nil includeEmail:nil successBlock:^(NSDictionary *account) {
            
            [self saveUserData:account];
            [self loadFollowerScreen:YES];
            [self hideActivityViewer];
        }errorBlock:^(NSError *error) {
            [CommonFuntions showAlertWithTitle:ApplicationTitleText Message:[error localizedDescription]];
            [self hideActivityViewer];
        }];
        
        
    } errorBlock:^(NSError *error) {
        [CommonFuntions showAlertWithTitle:ApplicationTitleText Message:[error localizedDescription]];
    }];
    
}
-(void)saveUserData:(NSDictionary *)account
{
    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    appdelegate.userObj=[[AccountObj alloc] init];
    appdelegate.userObj = [[AccountObj alloc] init];
    appdelegate.userObj.fullName = [account objectForKey:fullNameKey];
    appdelegate.userObj.description = [account objectForKey:descriptionKey];
    appdelegate.userObj.followersCount = [NSString stringWithFormat:@"%li",[[account objectForKey:followersCountKey] integerValue]];
    appdelegate.userObj.statusCount = [NSString stringWithFormat:@"%li",[[account objectForKey:statusCountKey] integerValue]];
    appdelegate.userObj.userID = [account objectForKey:userIDKey];
    appdelegate.userObj.profileBackgroundImageUrl = [account objectForKey:profileBackgroundImageUrlKey];
    appdelegate.userObj.profileBackgroundImageUrlHttps = [account objectForKey:profileBackgroundImageUrlHttpsKey];
    appdelegate.userObj.profileImageUrl = [account objectForKey:profileBackgroundImageUrlKey];
    appdelegate.userObj.profileImageUrlHttps = [account objectForKey:profileBackgroundImageUrlHttpsKey];
    appdelegate.userObj.screenName = [NSString stringWithFormat:@"@%@",[account objectForKey:screenNameKey]];
    
    [CommonFuntions createFile:appdelegate.userObj];
    
    
}
-(void)loadFollowerScreen:(BOOL)loadfromServer
{
    FollowersViewController *followerController = (FollowersViewController *)[self.storyboard instantiateViewControllerWithIdentifier:FollowerScreenName];
    followerController.loadFromServer = loadfromServer;
    [self.navigationController pushViewController:followerController animated:YES];
}

#pragma mark- webview delegate

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self hideActivityViewer];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self hideActivityViewer];
}

#pragma mark STTwitterAPIOSProtocol

- (void)twitterAPI:(STTwitterAPI *)twitterAPI accountWasInvalidated:(ACAccount *)invalidatedAccount {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(twitterAPI != appDelegate.twitter) return;
}

@end
