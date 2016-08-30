//
//  LoginViewController.m
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

//

#import "LoginViewController.h"
#import "LocalizedMessages.h"
#import "AppDelegate.h"
#import "CommonFuntions.h"
#import "STTwitterAPI.h"
#import "NSError+STTwitter.h"
#import "STHTTPRequest+STTwitter.h"
#import <Accounts/Accounts.h>

typedef void (^accountChooserBlock_t)(ACAccount *account, NSString *errorMessage); // don't bother with NSError for that

@interface LoginViewController ()
@property (nonatomic, strong) STTwitterAPI *twitter;
@end

@implementation LoginViewController
@synthesize loginBtn;
@synthesize langBtn;
@synthesize cancelWebViewBtn;
@synthesize webView;
@synthesize controlsView;
@synthesize savedAccessToken;
@synthesize savedAccessTokenSecret;
@synthesize userObj;

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
    
    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    userObj = [[AccountObj alloc] init];
    userObj = [CommonFuntions getSavedData];
    //update the app lanuguage with last selected language
    if(![CommonFuntions isStringNull:userObj.screenName])
    {
        if(appdelegate.currentLang!=userObj.userLang)
            [self onLanguagePressed:nil];
        appdelegate.currentLang=userObj.userLang;
    }
    
    if ([CommonFuntions isStringNull:[[NSUserDefaults standardUserDefaults] objectForKey: ConsumerKeyName]] || [CommonFuntions isStringNull:[[NSUserDefaults standardUserDefaults] objectForKey: ConsumerSecretKeyName]]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:ConsumerKey forKey:ConsumerKeyName];
        [defaults setObject:ConsumerSecret forKey:ConsumerSecretKeyName];
        [defaults synchronize];
    }
    
    savedAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey: AccessTokenName];
    savedAccessTokenSecret = [[NSUserDefaults standardUserDefaults] objectForKey: AccessTokenSecretName];
    
    if (![savedAccessToken isEqualToString:@""] && ![CommonFuntions isStringNull:savedAccessToken]) {
        [self showActivityViewer];
        self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:ConsumerKey consumerSecret:ConsumerSecret oauthToken:savedAccessToken oauthTokenSecret:savedAccessTokenSecret];
        
        [_twitter getAccountVerifyCredentialsWithIncludeEntites:nil skipStatus:nil includeEmail:nil successBlock:^(NSDictionary *account) {
            
            [self save_userData:account lang:appdelegate.currentLang];
            
            [self hideActivityViewer];
        }errorBlock:^(NSError *error) {
            [CommonFuntions showAlertWithTitle:ApplicationTitleText Message:[error localizedDescription]];
            [self hideActivityViewer];
        }];
        
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
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:ConsumerKey
                                                 consumerSecret:ConsumerSecret oauthToken:nil oauthTokenSecret:nil];
    [self showActivityViewer];
    [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
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
    if(delegate.currentLang==Arabic){
        language=@"en";
        delegate.currentLang=English;
    }else if(delegate.currentLang==English){
        language= @"ar";
        delegate.currentLang=Arabic;
    }
    
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
    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret , NSString *userID, NSString *screenName) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_twitter.oauthAccessToken forKey:AccessTokenName];
        [defaults setObject:_twitter.oauthAccessTokenSecret forKey:AccessTokenSecretName];
        [defaults synchronize];
        
        AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self showActivityViewer];
        
        [_twitter getAccountVerifyCredentialsWithIncludeEntites:nil skipStatus:nil includeEmail:nil successBlock:^(NSDictionary *account) {
            
            [self save_userData:account lang:appdelegate.currentLang];
            
            [self hideActivityViewer];
        }errorBlock:^(NSError *error) {
            [CommonFuntions showAlertWithTitle:ApplicationTitleText Message:[error localizedDescription]];
            [self hideActivityViewer];
        }];
        
        
    } errorBlock:^(NSError *error) {
        [CommonFuntions showAlertWithTitle:ApplicationTitleText Message:[error localizedDescription]];
    }];
    
}
-(void)save_userData:(NSDictionary *)account lang:(MyLanguages)lang
{
    userObj = [[AccountObj alloc] init];
    userObj.fullName = [account objectForKey:@"name"];
    userObj.description = [account objectForKey:@"description"];
    userObj.followersCount = [NSString stringWithFormat:@"%li",[[account objectForKey:@"followers_count"] integerValue]];
    userObj.userID = [account objectForKey:@"id_str"];
    userObj.profileBackgroundImageUrl = [account objectForKey:@"profile_background_image_url"];
    userObj.profileBackgroundImageUrlHttps = [account objectForKey:@"profile_background_image_url_https"];
    userObj.profileImageUrl = [account objectForKey:@"profile_image_url"];
    userObj.profileImageUrlHttps = [account objectForKey:@"profile_image_url_https"];
    userObj.screenName = [account objectForKey:@"screen_name"];
    userObj.userLang = lang;
    
    [CommonFuntions createFile:userObj];
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
    if(twitterAPI != _twitter) return;
}



#pragma mark- alert delegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}
@end
