//
//  AppDelegate.m
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

//

#import "AppDelegate.h"
#import "CustomNavigationController.h"
#import "LocalizationSystem.h"
#import "LoginViewController.h"
#import "LocalizedMessages.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation AppDelegate

@synthesize pased;
@synthesize centerController = _viewController;
@synthesize leftController = _leftController;
@synthesize rightController =_rightController;
@synthesize canPan = _canPan;
@synthesize currentLang;
@synthesize islogOut;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    pased=NO;
    _canPan=YES;
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self SetAppLanguage];
    
    IIViewDeckController* deckController = [self generateControllerStack];
    self.leftController = deckController.leftController;
    self.rightController = deckController.rightController;
    self.centerController = deckController.centerController;
    self.window.rootViewController = deckController;
    [self.window makeKeyAndVisible];
    deckController.panningMode = IIViewDeckFullViewPanning;
    deckController.centerhiddenInteractivity=IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIView *addStatusBar = [[UIView alloc] init];
        addStatusBar.frame = CGRectMake(0, 0, self.window.frame.size.width, 20);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        addStatusBar.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1];
        [self.window.rootViewController.view addSubview:addStatusBar];
    }

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
        
        [[UIView appearanceWhenContainedIn:[UIAlertController class], nil] setSemanticContentAttribute:UISemanticContentAttributeUnspecified];
        [[UIView appearanceWhenContainedIn:[UIAlertView class], nil] setSemanticContentAttribute:UISemanticContentAttributeUnspecified];
        
        
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     pased=YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    pased=YES;
    
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    pased=NO;

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([[url scheme] isEqualToString:@"myapplication"] == NO) return NO;
    
    NSDictionary *d = [self parametersDictionaryFromQueryString:[url query]];
    
    NSString *token = d[@"oauth_token"];
    NSString *verifier = d[@"oauth_verifier"];
    
    LoginViewController *loginController = (LoginViewController *)[((CustomNavigationController*)self.centerController) getTopView ];
    [loginController setOAuthToken:token oauthVerifier:verifier];
    
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    
    
}

#pragma mark - view deck delegate

- (BOOL)viewDeckController:(IIViewDeckController *)viewDeckController shouldBeginPanOverView:(UIView *)view {
    if (([NSStringFromClass([view class]) isEqualToString:@"UINavigationButton"] && [[[(id)view titleLabel] text] isEqualToString:@"bounce"] ) || !_canPan)
        return NO;
    if( [[((CustomNavigationController*)self.centerController) getTopView ] class] == [LoginViewController class]) {
        return NO;
    }
    

    return YES;
}



- (IIViewDeckController*)generateControllerStack {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    

    
    CustomNavigationController *centerController = [mainStoryboard instantiateViewControllerWithIdentifier:@"CustomNavigationController"];
    IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:centerController leftViewController:nil rightViewController:nil];
    if(currentLang==Arabic){
        deckController.leftController=nil;
        deckController.rightController=nil;
    }
        deckController.leftSize = MenuStartX;
        deckController.rightSize = MenuStartX;
    [deckController setShadowEnabled:NO];
    [deckController setDelegate:self];
    [deckController disablePanOverViewsOfClass:NSClassFromString(@"_UITableViewHeaderFooterContentView")];
    return deckController;
}

- (BOOL)viewDeckController:(IIViewDeckController*)viewDeckController shouldOpenViewSide:(IIViewDeckSide)viewDeckSide {
    UINavigationController *navController = (UINavigationController*)self.centerController;
    
    if([[navController viewControllers] count] < 2) {
        return NO;
    }
    
    return YES;
}


#pragma mark - funtions

-(void) SetAppLanguage{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSLog(@"language=%@",language);
    language=@"ar";
    if([language isEqualToString:@"en"]){
        currentLang=English;
        ICLocalizationSetLanguage(language);
    }else if([language isEqualToString:@"ar"]){
        currentLang=Arabic;
        ICLocalizationSetLanguage(language);
    }else{ // default if the device language is not form all of this
        currentLang=Arabic;
        ICLocalizationSetLanguage(@"ar");
    }
}

- (NSDictionary *)parametersDictionaryFromQueryString:(NSString *)queryString {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    
    for(NSString *s in queryComponents) {
        NSArray *pair = [s componentsSeparatedByString:@"="];
        if([pair count] != 2) continue;
        
        NSString *key = pair[0];
        NSString *value = pair[1];
        
        md[key] = value;
    }
    
    return md;
}


-(void)switchMenuDirection{
    IIViewDeckController* deckController =(IIViewDeckController*)self.window.rootViewController;
    UIViewController* menuControler=nil;
    if(deckController.rightController!=nil)
        menuControler=deckController.rightController;
    else if (deckController.leftController!=nil)
        menuControler=deckController.leftController;
    if(menuControler==nil)return;
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    if(currentLang==English){
        deckController.leftController= [mainStoryboard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];
        self.leftController=menuControler;
        self.rightController=nil;
        deckController.rightController=nil;
    }else{
        deckController.rightController=[mainStoryboard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];//menuControler;
        self.rightController=menuControler;
        self.leftController=nil;
        deckController.leftController=nil;
    }
}


@end
