//
//  AppDelegate.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

//

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"
#import "StaticVariables.h"
#import "AccountObj.h"
#import "STTwitterAPI.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,IIViewDeckControllerDelegate>{
    MyLanguages currentLang;
    BOOL islogOut;
    STTwitterAPI *twitter;
}


@property (strong, nonatomic) UIWindow *window;


@property (retain, nonatomic) UIViewController *centerController;
@property (retain, nonatomic) UIViewController *leftController;
@property (retain, nonatomic) UIViewController *rightController;
@property (nonatomic, readwrite) BOOL canPan;
@property (nonatomic)MyLanguages currentLang;
@property (nonatomic,retain) AccountObj *userObj;
@property (nonatomic) BOOL islogOut;
@property (nonatomic, retain) STTwitterAPI *twitter;

- (IIViewDeckController*)generateControllerStack;


-(void) switchMenuDirection;
@end
