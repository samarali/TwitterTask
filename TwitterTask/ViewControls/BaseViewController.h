//
//  BaseViewController.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

//

#import <UIKit/UIKit.h>

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


@end

