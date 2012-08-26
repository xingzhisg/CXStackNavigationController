//
//  UIViewController+Stack.m
//  StackNavigationController
//
//  Created by Xingzhi C. on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+Stack.h"
#import "CXStackNavigationController.h"
#import <objc/runtime.h>

@implementation UIViewController (Stack)

static char SLIDE_KEY;

- (void) setStackNavigationController:(CXStackNavigationController *)stackNavigationController {
    if (nil == stackNavigationController) 
        objc_removeAssociatedObjects(self);
    else
        objc_setAssociatedObject(self, &SLIDE_KEY, stackNavigationController, OBJC_ASSOCIATION_ASSIGN);
}

- (CXStackNavigationController*) stackNavigationController {
    return (CXStackNavigationController *)objc_getAssociatedObject(self, &SLIDE_KEY);
}

- (UIViewController*) swipeToRightTest {
    if (self.modalViewController) return [self.modalViewController swipeToRightTest];
    
    return self;
}

- (void) handleSwipeToRightEvent {
    // do nothing by default;
}

- (void) viewWillBecomeTop:(BOOL)animated {

}

- (void) viewDidBecomeTop:(BOOL)animated {

}

- (void) viewWillResignTop:(BOOL)animated {

}

- (void) viewDidResignTop:(BOOL)animated {

}

- (void) viewWillBecomeTopIntermediate:(BOOL)animated {

}

- (void) viewDidBecomeTopIntermediate:(BOOL)animated {

}

- (void) viewWillResignTopIntermediate:(BOOL)animated {

}

- (void) viewDidResignTopIntermediate:(BOOL)animated {

}

- (void) viewWillAppearWithiOS5Fix:(BOOL)animated {
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)) return;
    [self viewWillAppear:animated];
}

- (void) viewWillDisappearWithiOS5Fix:(BOOL)animated {
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)) return;
    [self viewWillDisappear:animated];
}

- (void) viewDidAppearWithiOS5Fix:(BOOL)animated {
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)) return;
    [self viewDidAppear:animated];
}

- (void) viewDidDisappearWithiOS5Fix:(BOOL)animated {
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)) return;
    [self viewDidDisappear:animated];
}

@end
