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
    [activityWheel setColor:[UIColor orangeColor]];
    [activityView addSubview:activityWheel];
    [window addSubview: activityView];
    
    [[[activityView subviews] objectAtIndex:0] startAnimating];
}
-(void)hideActivityViewer
{
    [[[activityView subviews] objectAtIndex:0] stopAnimating];
    [activityView removeFromSuperview];
    activityView = nil;
}

#pragma mark - back button color

+ (UIColor*)getBackBtnColor{
    return [UIColor whiteColor];
}

#pragma mark - methods


-(void)logout{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.islogOut=YES;

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
    UIViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier:SeagueLoginScreen];
    [self.navigationController pushViewController:viewController animated:YES];
}
@end
