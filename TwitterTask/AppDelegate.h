//
//  AppDelegate.h
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

//

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"
#import "StaticVariables.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,IIViewDeckControllerDelegate>{
    BOOL pased;
    MyLanguages currentLang;
    BOOL islogOut;
}


@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) BOOL pased;

@property (retain, nonatomic) UIViewController *centerController;
@property (retain, nonatomic) UIViewController *leftController;
@property (retain, nonatomic) UIViewController *rightController;
@property (nonatomic, readwrite) BOOL canPan;
@property (nonatomic)MyLanguages currentLang;
@property (nonatomic) BOOL islogOut;

- (IIViewDeckController*)generateControllerStack;


-(void) switchMenuDirection;
@end
