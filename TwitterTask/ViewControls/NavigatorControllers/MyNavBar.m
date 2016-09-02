//
//  MyNavBar.m
//  TwitterTask
//
//  Created by Samar-Mac book on 8/29/16.

#import "MyNavBar.h"

@implementation MyNavBar



- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect barFrame = self.frame;
    barFrame.size.height = 33;
    self.frame = barFrame;
    for (UIView *view in self.subviews)
    {
        if([NSStringFromClass([view class]) isEqualToString:@"_UINavigationBarBackground"] ){
            CGRect frame = view.frame;
            frame.origin.y = 0;
            view.frame = frame;
        }else{
            CGRect frame = view.frame;
            frame.origin.y = 9;
            view.frame = frame;
        }
    }
}

@end
