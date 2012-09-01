//
//  TrashItem.m
//  TrashBlaster
//
//  Created by Ben Gotow on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TrashItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation TrashItem

@synthesize value, exploding, redTime;

- (id)initWithValue:(int)v
{
    // pick a random image
    image = random() % 11 + 1;
    UIImage * randomImage = [UIImage imageNamed: [NSString stringWithFormat:@"%d.png", image]];
    
    CGRect buttonFrame = CGRectMake(0, 0, [randomImage size].width, [randomImage size].height);
    CGRect labelFrame = CGRectMake(0, [randomImage size].height-12, [randomImage size].width, 36);
    CGRect frame = CGRectMake(0, 0, [randomImage size].width, [randomImage size].height + labelFrame.size.height);
    CGRect explosionFrame = CGRectMake((frame.size.width - 256)/2, (frame.size.height - 192)/2, 256, 192);
    
    self = [super initWithFrame: frame];
    if (self) {
        value = v;
        
        [self setClipsToBounds: NO];
        
        trash = [[UIButton alloc] initWithFrame: buttonFrame];
        [trash setImage: randomImage forState:UIControlStateNormal];
        [trash addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: trash];
        
        explosionFrameNumber = 0;
        explosion = [[UIImageView alloc] initWithFrame: explosionFrame];
        [explosion setHidden: YES];
        [self addSubview: explosion];
         
        valueLabel = [[UILabel alloc] initWithFrame: labelFrame];
        [valueLabel setTextAlignment: UITextAlignmentCenter];
        [valueLabel setTextColor: [UIColor whiteColor]];
        [valueLabel setFont: [UIFont boldSystemFontOfSize: 36]];
        [valueLabel setBackgroundColor:[UIColor clearColor]];
        [valueLabel setText: [NSString stringWithFormat:@"%d", v]];
        [self addSubview: valueLabel];
        
        [[valueLabel layer] setShadowOffset: CGSizeMake(0, 3)];
        [[valueLabel layer] setShadowOpacity: 0.6];
        [[valueLabel layer] setShadowRadius: 5];
    }
    return self;
}

- (UIImage*)trashImageAtIndex:(int)ii
{
    return [UIImage imageNamed: [NSString stringWithFormat:@"s%2d_%d.png", ii, ii]];
}

- (void)buttonTapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TrashBlasted" object: self];
}

- (void)update
{
    [super update];

    if (exploding){
        [explosion setHidden: NO];
        [explosion setImage: [self trashImageAtIndex: explosionFrameNumber]];
        explosionFrameNumber ++;
        
        float alpha = fmaxf(0,(1 - explosionFrameNumber / 15.0));
        [valueLabel setAlpha: alpha];
        [trash setAlpha: alpha];

        if (explosionFrameNumber == 31){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TrashDestroyed" object: self];
            // self is now nil
            return;
        }
    }

    if (redTime > 0){
        if (redTime < 40){
            redTime ++;
            UIImage * i = [UIImage imageNamed: [NSString stringWithFormat:@"r%d.png", image]];
            [trash setImage:i forState:UIControlStateNormal];
        } else {
            redTime = 0;
            UIImage * i = [UIImage imageNamed: [NSString stringWithFormat:@"%d.png", image]];
            [trash setImage:i forState:UIControlStateNormal];
        }
    }
}

- (void)dealloc
{
    [valueLabel release];
    valueLabel = nil;
    [trash release];
    trash = nil;
    [explosion release];
    explosion = nil;
    
    [super dealloc];
}
@end
