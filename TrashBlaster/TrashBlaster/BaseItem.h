//
//  BaseItem.h
//  TrashBlaster
//
//  Created by Ben Gotow on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseItem : UIView
{
    double vx;
    double vy;
    double x;
    double y;
    double spinRate;
    double spin;
    
    UIButton * innerButton;
    NSString * clickNotif;
}

@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;
@property (nonatomic, assign) double spinRate;

- (id)initWithImage:(UIImage*)i andOnclickNotification:(NSString*)notif;
- (void)setX:(double)nx Y:(double)ny VX:(double)nvx VY:(double)nvy;
- (void)setX:(double)nx Y:(double)ny;
- (void)update;
@end
