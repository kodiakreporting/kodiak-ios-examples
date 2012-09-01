//
//  TrashItem.m
//  TrashBlaster
//
//  Created by Ben Gotow on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TrashItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation BaseItem

@synthesize spinRate;
@synthesize x,y;

- (id)initWithImage:(UIImage*)i andOnclickNotification:(NSString*)notif
{
    CGRect f = CGRectMake(0, 0, [i size].width, [i size].height);
    self = [super initWithFrame: f];
    if (self){
        innerButton = [[UIButton alloc] initWithFrame: f];
        [innerButton addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
        [innerButton setImage:i forState:UIControlStateNormal];
        [self addSubview: innerButton];
        
        spinRate = M_PI / 100.0;
        clickNotif = [notif retain];
    }
    return self;
}

- (void)setX:(double)nx Y:(double)ny
{
    x = nx;
    y = ny;
}

- (void)setX:(double)nx Y:(double)ny VX:(double)nvx VY:(double)nvy
{
    x = nx;
    y = ny;
    vx = nvx;
    vy = nvy;
}

- (void)buttonTapped
{
    if (clickNotif != nil){
        [[NSNotificationCenter defaultCenter] postNotificationName:clickNotif object:self];
    }
}

- (void)update
{
    x += vx;
    y += vy;
    spin += spinRate;
    spinRate *= 0.99f;
    
    if (x > 920)
        vx = -vx;
    if (x < 0)
        vx = -vx;
    if (y > 450)
        vy = -vy;
    if (y < 0)
        vy = -vy;
    
    CGRect f = [self frame];
    f.origin.x = x;
    f.origin.y = y;

    [self setFrame: f];
    [innerButton setTransform: CGAffineTransformMakeRotation(spin)];
}
- (void)dealloc
{
    [innerButton release];
    innerButton = nil;
    
    [clickNotif release];
    clickNotif = nil;
    
    [super dealloc];
}
@end
