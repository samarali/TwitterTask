//
//  SideMenuViewController.m
//  TwitterTask
//
//  Created by Samar-Mac book on 8/31/16.
//

#import "SideMenuViewController.h"
#import "AppDelegate.h"
#import "SideMenuCell.h"
#import "LocalizedMessages.h"
#import "CustomNavigationController.h"
#import "BaseViewController.h"
#import "CommonFuntions.h"


@interface SideMenuViewController ()

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
    NSString * seagueName =[SideMenuCellObj getViewControllerName:(int)indexPath.row];
    
    if([seagueName isEqualToString:@""]){
        
    }
    else {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CustomNavigationController *navigationController = (CustomNavigationController *)appDelegate.centerController;
        
        //[((BaseViewController*)[navigationController getTopView]) hideMenuViewer];
        
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:seagueName];
        
        if([[navigationController getTopView] class]!=[viewController class]){
            [navigationController pushViewController:viewController animated:YES];
        }
        //[navigationController.viewDeckController toggleLeftViewAnimated:YES];
        [((BaseViewController*)[navigationController getTopView]) onMenuButtonPressed:nil];
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
@end
