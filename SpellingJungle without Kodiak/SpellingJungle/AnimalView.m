//
//  AnimalView.m
//  SpellingJungle
//
//  Created by Ben Gotow on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AnimalView.h"
#import "SoundManager.h"

@implementation AnimalView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [[self layer] setShadowOffset:CGSizeMake(0, 4)];
        [[self layer] setShadowRadius: 3];
        [[self layer] setShadowColor: [[UIColor blackColor] CGColor]];
        [[self layer] setShadowOpacity: 0.7];
     
        [self addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setWord:(NSString *)w
{
    [word release];
    word = [w retain];
    
    NSString * path = [[NSBundle mainBundle] pathForResource:word ofType:@"png" inDirectory:@"animals"];
    [self setImage:[UIImage imageWithContentsOfFile: path] forState:UIControlStateNormal];
}

- (void)play
{
    [[SoundManager sharedManager] playSoundWithIdentifier: word];
}

@end
