//
//  BaseViewController.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface BaseViewController : UIViewController{
    UIView *activityView;
    UIView *MenuView;
    UIImageView * _BGImage;
    UILabel *noDataLbl;
}

@property (nonatomic, retain) IBOutlet UIImageView * BGImage;
@property (nonatomic, retain) IBOutlet UILabel *noDataLbl;

- (IBAction)onMenuButtonPressed:(id)sender;
- (void)customizeNavigationBar:(BOOL)withHome WithMenu:(BOOL)withMenu ;
- (void)initalizeViews;

-(void)showActivityViewer;
-(void)hideActivityViewer;
-(void)switchToArabicLayout;
-(void)switchToEnglishLayout;
-(void)locatizeLables;


- (IBAction)goBack:(id)sender ;
-(IBAction)onHomePressed:(id)sender;
- (void) hideMenuViewer;


-(void)logout;
-(NSMutableArray *)runQuery:(NSString *)query;
-(void)runQuery:(NSString *)query listOfFollowers:(NSMutableArray *)listOfFollowers isInsertStat:(BOOL)isInsertStat;

@end

