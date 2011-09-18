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
@end
