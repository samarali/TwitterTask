//
//  LoginViewController.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

//

#import "BaseViewController.h"

@interface LoginViewController : BaseViewController<UIAlertViewDelegate>{
  
    UIButton *loginBtn;
    UIButton *langBtn;
    UIView *controlsView;
}

@property (nonatomic,retain) IBOutlet UIButton *loginBtn;
@property (nonatomic,retain) IBOutlet UIButton *langBtn;
@property (nonatomic,retain) IBOutlet UIView *controlsView;

-(IBAction)onLoginPressed:(id)sender;
-(IBAction)onLanguagePressed:(id)sender;
@end
