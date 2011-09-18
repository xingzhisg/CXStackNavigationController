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

@end
