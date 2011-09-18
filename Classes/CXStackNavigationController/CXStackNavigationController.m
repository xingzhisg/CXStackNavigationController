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
//	3. shadow effects isn't perfect, especially for UITableViewController (when scroll it down).
//
//  Possible enhancement
//  1. bouncing effects can be implemented via a UIPanGestureRecognizer instead of UISwipeGetureRecognizer
//	2. UIViewControllers.navigationItems needs a header to display
//

#import "CXStackNavigationController.h"
#import "UIViewController+Stack.h"

@interface CXStackNavigationController ()
@property(nonatomic, retain) UIViewController * rootViewController;

- (UIViewController*) topIntermediateViewController;

- (CGRect) frameForRootView;
- (CGRect) frameForTopIntermediateViews;
- (CGRect) frameForTopView;

@end

@implementation CXStackNavigationController
@synthesize viewControllers = _viewControllers;
@synthesize rootViewController = _rootViewController;
@synthesize swipeGestureRecognizer = _swipeGestureRecognizer;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
	for (int i = 0; i < ((int)[self.viewControllers count])-2; ++i) {
		UIViewController * aViewcController = [self.viewControllers objectAtIndex:i];
		[aViewcController.view removeFromSuperview];
		aViewcController.view = nil;
		[aViewcController viewDidUnload];
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
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
	
    self.rootViewController.view.frame = self.view.bounds;// [self frameForRootView];
    [self.view addSubview:self.rootViewController.view];
	
	// reload the topViewController.view
	UIViewController * topViewController = [self topViewController];
	[topViewController.view setFrame:[self frameForTopView]];
	[self.view addSubview:topViewController.view];
	
	// reload the topIntermediateController.view
	UIViewController * topIntermediateController = [self topIntermediateViewController];
	[topIntermediateController.view setFrame:[self frameForTopIntermediateViews]];
	[self.view insertSubview:topIntermediateController.view belowSubview:topViewController.view];
	
	// swipe gesture recognizer
	UISwipeGestureRecognizer * swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
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
	for (int i = 0; i < ((int)[self.viewControllers count])-1; ++i) {
		UIViewController * aViewcController = [self.viewControllers objectAtIndex:i];
		CGRect rect = aViewcController.view.frame;
		rect.size.height = self.view.bounds.size.height;
		aViewcController.view.frame = rect;
	}
	[[self topViewController].view setFrame:[self frameForTopView]];
}

////////////////////////////////////
// swipe events
////////////////////////////////////

- (void) handleSwipe:(UISwipeGestureRecognizer*)gesture {
//	NSLog(@"swipe right detected");
	[self popViewControllerWithAnimation:SLIDE_HORIZONAL];
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

#define LEFT_SHADOW_TAG 142857142

- (void) updateStackShadowForViewController:(UIViewController*)aViewController {
	[[aViewController view] setClipsToBounds:NO];
	UIImageView * shadowView = (UIImageView*) [[aViewController view] viewWithTag:LEFT_SHADOW_TAG];
	if (!shadowView) {
		UIImageView * shadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow_left.png"]];
		shadowView.frame = CGRectMake(-8, 0, 8, [aViewController view].frame.size.height);
		shadowView.contentMode = UIViewContentModeScaleToFill;
		shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		shadowView.tag = LEFT_SHADOW_TAG;
		[aViewController.view addSubview:shadowView];
		[shadowView release];
	}
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

- (void) pushViewController:(UIViewController*)detailedViewController animated:(BOOL)animated {
    [self pushViewController:detailedViewController byDismissingViewControllersBeyond:nil animated:animated];
}

- (void) pushViewController:(UIViewController*)detailedViewController byDismissingViewControllersBeyond:(UIViewController*)parentViewController animated:(BOOL)animated {
    detailedViewController.stackNavigationController = self;
    
    CGRect newRect = [self frameForTopView];	
    newRect.origin.x = self.view.bounds.size.width;
    detailedViewController.view.frame = newRect;
	
	// viewWillDisappear
	UIViewController * prevTopIntermediateViewController = [self topIntermediateViewController];
	[prevTopIntermediateViewController viewWillDisappear:NO];
	
	// viewWillAppear
	[detailedViewController viewWillAppear:animated];
	
	// add as subview
    [self.view addSubview:detailedViewController.view];
	
    // poping view controllers beyong the parentviewcontroller
    [self popToViewController:parentViewController withAnimation:(animated ? SLIDE_VERTICAL : SLIDE_NONE)];
	
    // add to viewControllers
    [self.viewControllers addObject:detailedViewController];
	
    ////////// animations ////////////
    if (animated) {
        [UIView beginAnimations:@"slide_in" context:nil];
        [UIView setAnimationDuration:0.4f];
    }
    // new frame for prev top View
	[self topIntermediateViewController].view.frame = [self frameForTopIntermediateViews];
	
    // set frame for new top view
    detailedViewController.view.frame = [self frameForTopView];   
	
    if (animated) {
        [UIView commitAnimations];
    }
	
	// viewDidDisappear
	[prevTopIntermediateViewController performSelector:@selector(viewDidDisappear:) withObject:(animated ? self : nil) afterDelay:(animated ? 0.41 : 0.01)];
    
	// viewDidAppear
	[detailedViewController performSelector:@selector(viewDidAppear:) withObject:(animated ? self : nil) afterDelay:(animated ? 0.41 : 0.01)];
	
    ////////// update stack shadows ///////////
    [self updateStackShadowsIfNeeded];
}


- (void) popViewControllerWithAnimation:(SLIDE_ANIMATION)animation {
    if ([self.viewControllers count] == 0) return;
    
    UIViewController * topViewController = [[self topViewController] retain];
    topViewController.stackNavigationController = nil;
    
    [self.viewControllers removeLastObject];
    
	// viewWillDisappear
	[topViewController viewWillDisappear:(animation == SLIDE_NONE ? NO : YES)];
	
    if (animation == SLIDE_NONE) {
        [topViewController.view removeFromSuperview];
        [topViewController release];
		
		// viewDidDisappear
		[topViewController viewDidDisappear:NO];
		
//		only when slide to the right we reframe the second top view
//        UIViewController * secondTopViewController = [self topViewController];
//        if (secondTopViewController)
//            secondTopViewController.view.frame = [self frameForTopView];
    }
    else {
        CGRect newRect = topViewController.view.frame;
        if(animation == SLIDE_VERTICAL) newRect.origin.y = self.view.bounds.size.height;
        else                            newRect.origin.x = self.view.bounds.size.width;
        
        UIViewController * newTopViewController = [self topViewController];
        
        [UIView beginAnimations:@"slide_out" context:topViewController];
        [UIView setAnimationDuration:0.4f];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        if (newTopViewController && (animation == SLIDE_HORIZONAL)) {	// only when slide to the right we reframe the new top view
            newTopViewController.view.frame = [self frameForTopView];
		}
        topViewController.view.frame = newRect;
        [UIView commitAnimations];
		
		// top intermediate view controller
		// we reframe it here because it might be unloaded during a memory strike;

		if (animation == SLIDE_HORIZONAL) {
			UIViewController * topIntermediateViewController = [self topIntermediateViewController];
			[topIntermediateViewController.view setFrame:[self frameForTopIntermediateViews]];
			[topIntermediateViewController viewWillAppear:NO];
			[self.view insertSubview:[self topIntermediateViewController].view belowSubview:newTopViewController.view];
			[topIntermediateViewController viewDidAppear:NO];
		}

    }
    
    ////////// update stack shadows ///////////
    [self updateStackShadowsIfNeeded];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if ([animationID isEqualToString:@"slide_out"] && [finished boolValue]) {
		UIViewController * topViewController = (UIViewController*)context;
		[topViewController.view removeFromSuperview];
		[topViewController viewDidDisappear:YES];
		[topViewController release];
	}
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
