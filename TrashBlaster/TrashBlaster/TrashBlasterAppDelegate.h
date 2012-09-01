//
//  HexDefenseAppDelegate.h
//  HexDefense
//
//  Created by Ben Gotow on 1/21/11.
//  Copyright 2011 Foundry376. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@class MainMenuController;

@interface TrashBlasterAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UIImageView * backgroundImage;
    HomeViewController * viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet HomeViewController *viewController;

@end

