//
//  TestStackNavigationAppDelegate.h
//  TestStackNavigation
//
//  Created by Xingzhi C. on 9/16/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface testNavigationAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController * navigationController;
@end

