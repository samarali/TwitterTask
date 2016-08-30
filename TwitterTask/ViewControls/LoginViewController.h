//
//  LoginViewController.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

//

#import "BaseViewController.h"
#import "STTwitterAPI.h"
#import "NSError+STTwitter.h"
#import "STHTTPRequest+STTwitter.h"
#import "AccountObj.h"

@interface LoginViewController : BaseViewController<UIAlertViewDelegate,STTwitterAPIOSProtocol,UIWebViewDelegate>{
  
    UIButton *loginBtn;
    UIButton *langBtn;
    UIButton *cancelWebViewBtn;
    UIWebView *webView;
    UIView *controlsView;
    
}

@property (nonatomic,retain) IBOutlet UIButton *loginBtn;
@property (nonatomic,retain) IBOutlet UIButton *langBtn;
@property (nonatomic,retain) IBOutlet UIButton *cancelWebViewBtn;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic,retain) IBOutlet UIView *controlsView;
@property (nonatomic,retain) NSString *savedAccessToken;
@property (nonatomic,retain) NSString *savedAccessTokenSecret;
@property (nonatomic,retain) AccountObj *userObj;


- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier;

-(IBAction)onLoginPressed:(id)sender;
-(IBAction)onLanguagePressed:(id)sender;
- (IBAction)onCancelWebView:(id)sender;
@end
