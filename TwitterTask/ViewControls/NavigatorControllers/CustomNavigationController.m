//
//  CustomNavigationController.m
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

//

#import "CustomNavigationController.h"
#import "AppDelegate.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pushAsRootView:(UIViewController *)viewController   {
}


-(UIViewController*)getTopView{
    return self.topViewController;
}
- (void)pushAsView:(UIViewController *)viewController   {
    
    [self pushViewController:viewController animated:YES];
}

- (void)setPanning:(BOOL)allow  {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setCanPan:allow];
}
@end
