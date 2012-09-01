//
//  SoundManager.h
//  HexDefense
//
//  Created by Ben Gotow on 2/5/11.
//  Copyright 2011 Foundry376. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "FISoundEngine.h"
#import "FIFactory.h"
#import "FISound.h"


@interface SoundManager : NSObject {

    FIFactory           * soundFactory;
    FISoundEngine       * engine;
    NSMutableDictionary * sounds;
    
    AVAudioPlayer       * backgroundAudioPlayer;
    
    float                 backgroundAudioVolumeIncrement;
    NSTimer             * backgroundAudioTimer;
    
}

+ (SoundManager*)sharedManager;
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (id)retain;
- (unsigned)retainCount;
- (void)release;
- (id)autorelease;
- (id)init;

- (void)startMusic;
- (void)stopMusic;

- (void)playSoundWithIdentifier:(NSString*)i;
- (void)playSoundWithIdentifier:(NSString*)i withVolume:(float)volume;
- (void)playSoundWithIdentifier:(NSString*)i withYPosition:(float)offset withVolume:(float)volume;

@end
