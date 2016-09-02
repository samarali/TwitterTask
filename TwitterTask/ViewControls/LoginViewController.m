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
    userObj = [self getloggedinUSer];
    appDelegate.userObj = userObj;
    
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
            
            if (appDelegate.userObj != nil) {
                savedAccessToken = appDelegate.userObj.accessToken;
                savedAccessTokenSecret = appDelegate.userObj.accessTokenSecret;
            }
            else{
                savedAccessToken = @"";
                savedAccessTokenSecret = @"";
            }
            
            if ([savedAccessTokenSecret isEqual:@"(null)"]) {
                ACAccount *ac = [[ACAccount alloc] init];
                
                
                ac.username = appDelegate.userObj.screenName;
                ac.username = [ac.username stringByReplacingOccurrencesOfString:@"@" withString:@""];
                appDelegate.twitter = [STTwitterAPI twitterAPIOSWithAccount:ac delegate:self];
                
                [self showActivityViewer];
                [appDelegate.twitter verifyCredentialsWithUserSuccessBlock:^(NSDictionary *account) {
                    [self hideActivityViewer];
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:account];
                    [dic setObject:appDelegate.twitter.oauthAccessToken forKeyedSubscript:accessTokenKey];
                    [dic setObject:appDelegate.twitter.oauthAccessTokenSecret forKeyedSubscript:accessTokenSecretKey];
                    [self saveUserData:dic];
                    if ([CommonFuntions hasConnectivity])
                        [self loadFollowerScreen:YES];
                    else
                        [self loadFollowerScreen:FALSE];
                } errorBlock:^(NSError *error) {
                    [self hideActivityViewer];
                    [CommonFuntions showAlertWithTitle:ApplicationTitleText Message:[error localizedDescription]];
                }];
            }
            else if (![savedAccessToken isEqualToString:@""] && ![CommonFuntions isStringNull:savedAccessToken]) {
                [self showActivityViewer];
                appDelegate.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:ConsumerKey consumerSecret:ConsumerSecret oauthToken:savedAccessToken oauthTokenSecret:savedAccessTokenSecret];
                
                [appDelegate.twitter getAccountVerifyCredentialsWithIncludeEntites:nil skipStatus:nil includeEmail:nil successBlock:^(NSDictionary *account) {
                    
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:account];
                    [dic setObject:savedAccessToken forKeyedSubscript:accessTokenKey];
                    [dic setObject:savedAccessTokenSecret forKeyedSubscript:accessTokenSecretKey];
                    [self saveUserData:dic];
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
            [CommonFuntions showAlertWithTitle:ApplicationTitleText Message:NoInternetConnection];
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
        [self showActivityViewer];
        
        [appDelegate.twitter getAccountVerifyCredentialsWithIncludeEntites:nil skipStatus:nil includeEmail:nil successBlock:^(NSDictionary *account) {
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:account];
            [dic setObject:appDelegate.twitter.oauthAccessToken forKeyedSubscript:accessTokenKey];
            [dic setObject:appDelegate.twitter.oauthAccessTokenSecret forKeyedSubscript:accessTokenSecretKey];
            [self saveUserData:dic];
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
