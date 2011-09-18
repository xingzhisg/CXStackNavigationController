//
//  CXStackNavigationController.h
//  StackNavigationController
//
//  Created by Xingzhi C. on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
  SLIDE_NONE, SLIDE_VERTICAL, SLIDE_HORIZONAL
} SLIDE_ANIMATION;

@interface CXStackNavigationController: UIViewController {

}

@property(nonatomic, retain) NSMutableArray * viewControllers;
@property(nonatomic, retain) UISwipeGestureRecognizer * swipeGestureRecognizer;

- (id) initWithRootViewController:(UIViewController *)rootViewController;

- (void) pushViewController:(UIViewController*)detailedViewController animated:(BOOL)animated;
- (void) pushViewController:(UIViewController*)detailedViewController byDismissingViewControllersBeyond:(UIViewController*)parentViewController animated:(BOOL)animated;
- (void) popViewControllerWithAnimation:(SLIDE_ANIMATION)animation;
- (void) popToRootViewControllerWithAnimation:(SLIDE_ANIMATION)animation;
- (void) popToViewController:(UIViewController*)viewController withAnimation:(SLIDE_ANIMATION)animation;
- (UIViewController*) topViewController;
@end
