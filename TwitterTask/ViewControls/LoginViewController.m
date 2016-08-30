//
//  LoginViewController.m
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

//

#import "LoginViewController.h"
#import "LocalizedMessages.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize loginBtn;
@synthesize langBtn;
@synthesize controlsView;

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
    [self onLanguagePressed:nil];
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

#pragma mark- alert delegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}
@end
