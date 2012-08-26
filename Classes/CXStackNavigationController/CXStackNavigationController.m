//
//  CXStackNavigationController.m
//  StackNavigationController
//
//  Created by Xingzhi C. on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//
//	Known Issues
//	1. at memory warning we nil out the viewcontrollers' in-visible views - thus losing the stacks vision for intermediate viewcontrollers
//	2. One needs to implement the swipeGestureRecognizer.delegate to avoid conflicts with other recognizers. In most cases, this should be done in the topViewController
//
//  Possible enhancement
//  1. bouncing effects can be implemented via a UIPanGestureRecognizer instead of UISwipeGetureRecognizer
//	2. UIViewControllers.navigationItems needs a header to display
//

#import "CXStackNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+Stack.h"

@interface CXStackNavigationController ()
@property(nonatomic, retain) UISwipeGestureRecognizer * swipeGestureRecognizer;
@property(nonatomic, retain) UIViewController * rootViewController;
@property(nonatomic, retain) NSMutableDictionary * containViews;

- (UIViewController*) topIntermediateViewController;

- (CGRect) frameForRootView;
- (CGRect) frameForTopIntermediateViews;
- (CGRect) frameForTopView;

@end

@implementation CXStackNavigationController
@synthesize viewControllers = _viewControllers;
@synthesize rootViewController = _rootViewController;
@synthesize swipeGestureRecognizer = _swipeGestureRecognizer;
@synthesize containViews = _containViews;
@synthesize shadowColor = _shadowColor;
@synthesize shadowRadius = _shadowRadius;

static BOOL isiOS5OrHigher = NO;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
	for (int i = 0; i < ((int)[self.viewControllers count])-2; ++i) {
		UIViewController * aViewcController = [self.viewControllers objectAtIndex:i];
        
        if (aViewcController.isViewLoaded) {
            [aViewcController.view removeFromSuperview];
            aViewcController.view = nil;
            [aViewcController viewDidUnload];
            
            [self clearContainerForViewController:aViewcController];
        }
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.swipeGestureRecognizer = nil;
    
	for (int i = 0; i < [self.viewControllers count]; ++i) {
		UIViewController * aViewcController = [self.viewControllers objectAtIndex:i];
		[aViewcController.view removeFromSuperview];
		aViewcController.view = nil;
		[aViewcController viewDidUnload];
        
        [self clearContainerForViewController:aViewcController];
	}
	[self.rootViewController.view removeFromSuperview];
	self.rootViewController.view = nil;
	[self.rootViewController viewDidUnload];
}

- (void) dealloc {
	self.swipeGestureRecognizer = nil;
    [self popToRootViewControllerWithAnimation:SLIDE_NONE];
    self.rootViewController = nil;
	
	self.viewControllers = nil;
    
    self.containViews = nil;

    self.shadowColor = nil;
    
    [super dealloc];
}


#pragma mark - View lifecycle

- (id) init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id) initWithRootViewController:(UIViewController *)rootViewController_ {
    self = [super initWithNibName:nil bundle:nil];
    if (self != nil) {
        self.rootViewController = rootViewController_;
		self.rootViewController.stackNavigationController = self;
        self.viewControllers = [NSMutableArray array];
        self.containViews = [NSMutableDictionary dictionary];
        
        isiOS5OrHigher = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0);
        
        self.shadowColor = [UIColor grayColor];
        self.shadowRadius = 4.f;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
	
    self.rootViewController.view.frame = self.view.bounds;
    [self.rootViewController viewWillAppear:NO];
    [self.view addSubview:self.rootViewController.view];
    [self.rootViewController viewDidAppear:NO];
    
    // reload the topIntermediateController.view
    UIViewController * topIntermediateController = [self topIntermediateViewController];
    [topIntermediateController viewWillAppear:NO];
    [topIntermediateController viewWillBecomeTopIntermediate:NO];
    
    UIView * container = [self containerForViewController:topIntermediateController];
    [container setFrame:[self frameForTopIntermediateViews]];
    [topIntermediateController.view setFrame:container.bounds];
    [self.view addSubview:container];
    [container addSubview:topIntermediateController.view];
    
    [topIntermediateController viewDidBecomeTopIntermediate:NO];
    [topIntermediateController viewDidAppear:NO];
    
    // reload the topViewController.view
    UIViewController * topViewController = [self topViewController];
    [topViewController viewWillAppear:NO];
    [topViewController viewWillBecomeTop:NO];
    
    container = [self containerForViewController:topViewController];
    [container setFrame:[self frameForTopView]];
    [topViewController.view setFrame:container.bounds];
    [self.view addSubview:container];
    [container addSubview:topViewController.view];
    
    [topViewController viewDidBecomeTop:NO];
    [topViewController viewDidAppear:NO];
	
	// swipe gesture recognizer
	UISwipeGestureRecognizer * swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureSwipeToRight:)];
	swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
	[self.view addGestureRecognizer:swipeGesture];
	self.swipeGestureRecognizer = swipeGesture;
	[swipeGesture release];
	// read the Known Issues for gesture.delegate methods if implement with other recgonizers;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	self.rootViewController.view.frame = self.view.bounds;
    
    // Release any cached data, images, etc that aren't in use.
	for (int i = 0; i < ((int)[self.viewControllers count])-2; ++i) {
		UIViewController * aViewcController = [self.viewControllers objectAtIndex:i];
        
        if (aViewcController.isViewLoaded) {
            [aViewcController.view removeFromSuperview];
            aViewcController.view = nil;
            [aViewcController viewDidUnload];
            [self clearContainerForViewController:aViewcController];
        }
	}
    
	for (int i = 0; i < ((int)[self.viewControllers count])-1; ++i) {
		UIViewController * aViewcController = [self.viewControllers objectAtIndex:i];
        if (!aViewcController.isViewLoaded) continue;
        
        UIView * v = [self containerForViewController:aViewcController];
		CGRect rect = v.frame;
		rect.size.height = self.view.bounds.size.height;
        v.frame = rect;
	}
    
    [[self containerForViewController:self.topViewController] setFrame:[self frameForTopView]];
    [self updateStackShadowsIfNeeded];
}

////////////////////////////////////
// container views
////////////////////////////////////

- (UIView*) containerForViewController:(UIViewController*)viewController {
    if (viewController == nil)
        return nil;
    
    UIView * v = [self.containViews objectForKey:[NSValue valueWithPointer:viewController]];
    if (v != nil) return v;
    
    v = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [self.containViews setObject:v forKey:[NSValue valueWithPointer:viewController]];
    
    return v;
}

- (void) clearContainerForViewController:(UIViewController*)viewController {
    if (viewController == nil) return;
    
    NSValue * key = [NSValue valueWithPointer:viewController];
    UIView * v = [self.containViews objectForKey:key];
    [v removeFromSuperview];
    [self.containViews removeObjectForKey:key];
}

////////////////////////////////////
// swipe events
////////////////////////////////////

// @Override
- (UIViewController*) swipeToRightTest {
    UIViewController * v = [super swipeToRightTest];
    if (v == self) {
        // no modalviewcontroller, or modaviewcontroller does not consume swipe events
        for (int i = [self.viewControllers count] - 1; i >= 0 ; --i) {
            v = [[self.viewControllers objectAtIndex:i] swipeToRightTest];
            if (v != nil) { return v; }
        }
        v = nil;
    }
    return v;
}

// @Override
- (void) handleSwipeToRightEvent {
    UIViewController * v = [self swipeToRightTest];
    
    if (v && (v != self)) [v handleSwipeToRightEvent];
}

- (void) handleGestureSwipeToRight:(UISwipeGestureRecognizer*)gesture {
    [self handleSwipeToRightEvent];
}

////////////////////////////////////
// frames
////////////////////////////////////

- (CGRect) frameForRootView {
    return CGRectMake(-1, -1, 242, self.view.bounds.size.height);
}

- (CGRect) frameForTopIntermediateViews {
	int shift = [self.viewControllers count] * 3;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        return CGRectMake(54+shift, 0, 528, self.view.bounds.size.height);
    else
        return CGRectMake(54+shift, 0, 528, self.view.bounds.size.height);
}

- (CGRect) frameForTopView {
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && ([self.viewControllers count] == 1) )     // landscape && first view controller
        return CGRectMake(240, 0, 528, self.view.bounds.size.height);
    else
        return CGRectMake(self.view.bounds.size.width-528, 0, 528, self.view.bounds.size.height);
}

////////////////////////////////////////
// customized stack views
////////////////////////////////////////

- (void) updateStackShadowForViewController:(UIViewController*)aViewController {
	/*
	 * Create a fancy shadow aroung the viewController.
	 *
	 * Note: UIBezierPath needed because shadows are evil. If you don't use the path, you might not
	 * not notice a difference at first, but the keen eye will (even on an iPhone 4S) observe that
	 * the interface rotation _WILL_ lag slightly and feel less fluid than with the path.
	 */
    UIView * v = [self containerForViewController:aViewController];
	UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:v.bounds];
	v.layer.masksToBounds = NO;
	v.layer.shadowColor = [UIColor grayColor].CGColor;
	v.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	v.layer.shadowOpacity = 1.0f;
	v.layer.shadowRadius = self.shadowRadius;
	v.layer.shadowPath = shadowPath.CGPath;
}

- (void) updateStackShadowsIfNeeded {
	[self updateStackShadowForViewController:[self topViewController]];
	[self updateStackShadowForViewController:[self topIntermediateViewController]];
}

////////////////////////////////////////
// view controllers;
////////////////////////////////////////

- (UIViewController*) topIntermediateViewController {
	if ([self.viewControllers count] <= 1) return nil;
	return [self.viewControllers objectAtIndex:[self.viewControllers count]-2];
}

- (UIViewController*) topViewController {
    if ([self.viewControllers count] == 0) return nil;
    return [self.viewControllers lastObject];
}


////////////////////////////////////////
// push and pop
////////////////////////////////////////

static const CGFloat animationDuration = 0.3f;
static const CGFloat animationEndAlpha = 0.5f;

- (void) pushViewController:(UIViewController*)detailedViewController animated:(BOOL)animated {
    [self pushViewController:detailedViewController byDismissingViewControllersBeyond:nil animated:animated];
}

- (void) pushViewController:(UIViewController*)detailedViewController byDismissingViewControllersBeyond:(UIViewController*)parentViewController animated:(BOOL)animated {
        
    detailedViewController.stackNavigationController = self;
    
	// viewWillDisappear
	UIViewController * prevTopIntermediateViewController = [[self topIntermediateViewController] retain];
	UIViewController * prevTopViewController = [[self topViewController] retain];
	
    BOOL isReplacingTop = (parentViewController != nil && parentViewController == prevTopIntermediateViewController); // special handling for replacement of topviewcontroller
    
    // poping view controllers beyong the parentviewcontroller
    [self popToViewController:parentViewController withAnimation:(animated ? SLIDE_VERTICAL : SLIDE_NONE)];
        
    if (isReplacingTop) {
        // do nothing here
        [prevTopViewController viewWillResignTop:animated];
        [prevTopViewController viewWillDisappearWithiOS5Fix:animated];
    }
    else if ([self.viewControllers containsObject:prevTopIntermediateViewController]) {  // a simple push without pop anything
        [prevTopIntermediateViewController viewWillResignTopIntermediate:NO];
        [prevTopIntermediateViewController viewWillDisappearWithiOS5Fix:NO];
    }
    else {  // prev top intermediate was poped;
        [prevTopIntermediateViewController release], prevTopIntermediateViewController = nil;
    }
    
	// viewWillBecomeTop
    CGRect newRect = [self frameForTopView];
    newRect.origin.x = self.view.bounds.size.width;
    
    UIView * newTopContainerView = [self containerForViewController:detailedViewController];
    newTopContainerView.frame = newRect;
    detailedViewController.view.frame = newTopContainerView.bounds;
	
    [detailedViewController viewWillAppearWithiOS5Fix:animated];
	[detailedViewController viewWillBecomeTop:animated];
	
	// add as subview
    [self.view addSubview:newTopContainerView];
    [newTopContainerView addSubview:detailedViewController.view];
    
    // add to viewControllers
    [self.viewControllers addObject:detailedViewController];
	
    ////////// animations ////////////
    if (animated) {
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             // new frame for prev top View
                             [self containerForViewController:self.topIntermediateViewController].frame = [self frameForTopIntermediateViews];
                             
                             // set frame for new top view
                             newTopContainerView.frame = [self frameForTopView];
                             
                             if (isReplacingTop) {
                                 UIView * v = [self containerForViewController:prevTopViewController];
                                 CGRect newRect = v.frame;
                                 newRect.origin.y = self.view.bounds.size.height;
                                 v.frame = newRect;
                             }
                         } completion:^(BOOL finished) {
                             if (isReplacingTop) {
                                 [prevTopViewController viewDidResignTop:animated];
                                 [prevTopViewController viewDidDisappearWithiOS5Fix:animated];
                                 [prevTopViewController.view removeFromSuperview];
                                 [self clearContainerForViewController:prevTopViewController];
                             }
                             else {
                                 [prevTopIntermediateViewController viewDidResignTopIntermediate:animated];
                                 [prevTopIntermediateViewController viewDidDisappearWithiOS5Fix:animated];
                             }
                             [prevTopViewController release];
                             [prevTopIntermediateViewController release];
                             
                             [detailedViewController viewDidBecomeTop:animated];
                             [detailedViewController viewDidAppearWithiOS5Fix:animated];
                         }];
    }
    else {
        // new frame for prev top View
        [self containerForViewController:self.topIntermediateViewController].frame = [self frameForTopIntermediateViews];
        
        // set frame for new top view
        newTopContainerView.frame = [self frameForTopView];
        
        // viewDidDisappear
        if (isReplacingTop) {
            [prevTopViewController viewDidResignTop:NO];
            [prevTopViewController viewDidDisappearWithiOS5Fix:NO];
            [prevTopViewController.view removeFromSuperview];
            [self clearContainerForViewController:prevTopViewController];
        }
        else {
            [prevTopIntermediateViewController viewDidResignTopIntermediate:NO];
            [prevTopIntermediateViewController viewDidDisappearWithiOS5Fix:NO];
        }
        
        [prevTopViewController release];
        [prevTopIntermediateViewController release];
        
        // viewDidAppear
        [detailedViewController viewDidBecomeTop:animated];
        [detailedViewController viewDidAppearWithiOS5Fix:NO];
	}
    
    ////////// update stack shadows ///////////
    [self updateStackShadowsIfNeeded];
}


- (void) popViewControllerWithAnimation:(SLIDE_ANIMATION)animation {
    if ([self.viewControllers count] == 0) return;
    
    UIViewController * topViewController = [[self topViewController] retain];
    topViewController.stackNavigationController = nil;
    
    [self.viewControllers removeLastObject];
    
	// viewWillDisappear
    [topViewController viewWillResignTop:(animation == SLIDE_NONE ? NO : YES)];
	[topViewController viewWillDisappearWithiOS5Fix:(animation == SLIDE_NONE ? NO : YES)];
	
    if (animation == SLIDE_NONE) {
        [topViewController.view removeFromSuperview];
		// viewDidDisappear
        [topViewController viewDidResignTop:NO];
		[topViewController viewDidDisappearWithiOS5Fix:NO];
		
        [self clearContainerForViewController:topViewController];
        
        [topViewController release];
        
        //		only when slide to the right we reframe the second top view
        //        UIViewController * secondTopViewController = [self topViewController];
        //        if (secondTopViewController)
        //            secondTopViewController.view.frame = [self frameForTopView];
    }
    else {
        CGRect newRect = [self containerForViewController:topViewController].frame;
        if(animation == SLIDE_VERTICAL) newRect.origin.y = self.view.bounds.size.height;
        else                            newRect.origin.x = self.view.bounds.size.width;
        
        UIViewController * newTopViewController = [self topViewController];
        
        if (newTopViewController && (animation == SLIDE_HORIZONAL)) {	// only when slide to the right we reframe the new top view
            [newTopViewController viewWillBecomeTop:YES];
        }
        
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             if (newTopViewController && (animation == SLIDE_HORIZONAL)) {	// only when slide to the right we reframe the new top view
                                 [self containerForViewController:newTopViewController].frame = [self frameForTopView];
                             }
                             [self containerForViewController:topViewController].frame = newRect;
                         } completion:^(BOOL finished) {
                             [topViewController.view removeFromSuperview];
                             [topViewController viewDidResignTop:YES];
                             [topViewController viewDidDisappearWithiOS5Fix:YES];
                             [self clearContainerForViewController:topViewController];
                             [topViewController release];
                             
                             if (newTopViewController && (animation == SLIDE_HORIZONAL)) {	// only when slide to the right we reframe the new top view
                                 [newTopViewController viewDidBecomeTop:YES];
                             }
                         }];
        
		// top intermediate view controller
		// we reframe it here because it might be unloaded during a memory strike;
        
		if (animation == SLIDE_HORIZONAL) {
			UIViewController * topIntermediateViewController = [self topIntermediateViewController];
            UIView * container = [self containerForViewController:topIntermediateViewController];
			[container setFrame:[self frameForTopIntermediateViews]];
			[topIntermediateViewController viewWillAppearWithiOS5Fix:NO];
            [topIntermediateViewController viewWillBecomeTopIntermediate:NO];
			[self.view insertSubview:container belowSubview:[self containerForViewController:newTopViewController]];
            topIntermediateViewController.view.frame = container.bounds;
            [container addSubview:topIntermediateViewController.view];
            [topIntermediateViewController viewDidBecomeTopIntermediate:NO];
			[topIntermediateViewController viewDidAppearWithiOS5Fix:NO];
		}
    }
    
    ////////// update stack shadows ///////////
    [self updateStackShadowsIfNeeded];
}

- (void) popToRootViewControllerWithAnimation:(SLIDE_ANIMATION)animation {
    while ([self.viewControllers count] > 0) {
        [self popViewControllerWithAnimation:animation];
    }
}

- (void) popToViewController:(UIViewController *)viewController withAnimation:(SLIDE_ANIMATION)animation {
    if (viewController == self.rootViewController)
        [self popToRootViewControllerWithAnimation:animation];
    else if ([self.viewControllers containsObject:viewController]) {
        while ([self topViewController] != viewController) {
            [self popViewControllerWithAnimation:animation];
        }
    }
}

@end
