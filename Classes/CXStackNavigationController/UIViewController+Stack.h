//
//  UIViewController+Stack.h
//  StackNavigationController
//
//  Created by Xingzhi C. on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CXStackNavigationController;

@interface UIViewController (Stack)
@property(nonatomic, assign) CXStackNavigationController * stackNavigationController;

- (void) viewWillBecomeTop:(BOOL)animated;
- (void) viewDidBecomeTop:(BOOL)animated;
- (void) viewWillResignTop:(BOOL)animated;
- (void) viewDidResignTop:(BOOL)animated;
- (void) viewWillBecomeTopIntermediate:(BOOL)animated;
- (void) viewDidBecomeTopIntermediate:(BOOL)animated;
- (void) viewWillResignTopIntermediate:(BOOL)animated;
- (void) viewDidResignTopIntermediate:(BOOL)animated;

- (void) viewWillAppearWithiOS5Fix:(BOOL)animated;
- (void) viewWillDisappearWithiOS5Fix:(BOOL)animated;
- (void) viewDidAppearWithiOS5Fix:(BOOL)animated;
- (void) viewDidDisappearWithiOS5Fix:(BOOL)animated;

- (UIViewController*) swipeToRightTest;
- (void) handleSwipeToRightEvent;

@end
