//
//  CustomNavigationController.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

//

#import <UIKit/UIKit.h>

@interface CustomNavigationController : UINavigationController

- (void)setPanning:(BOOL)allow;
-(UIViewController*)getTopView;

@end
