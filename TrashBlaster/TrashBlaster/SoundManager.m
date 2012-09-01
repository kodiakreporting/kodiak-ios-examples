//
//  SoundManager.m
//  HexDefense
//
//  Created by Ben Gotow on 2/5/11.
//  Copyright 2011 Foundry376. All rights reserved.
//

#import "SoundManager.h"

@implementation SoundManager

static SoundManager * sharedManager;

#pragma mark Singleton Implementation

+ (SoundManager*)sharedManager
{
    @synchronized(self) {
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
        }
    }
    return sharedManager;
}
 
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedManager == nil) {
            sharedManager = [super allocWithZone:zone];
            return sharedManager;
        }
    }
    return nil;
}
 
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
 
- (id)retain
{
    return self;
}
 
- (unsigned)retainCount
{
    //denotes an object that cannot be released
    return UINT_MAX;
}
 
- (void)release
{
    //do nothing
}
 
- (id)autorelease
{
    return self;
}

- (id)init
{
    if (self = [super init]){
        soundFactory = [[FIFactory alloc] init];
        engine = [[soundFactory buildSoundEngine] retain];
        [engine activateAudioSessionWithCategory: AVAudioSessionCategoryPlayback];
        [engine openAudioDevice];
        
        // find all the sounds and read them in
        sounds = [[NSMutableDictionary alloc] init];
        
        NSString * resources =[[NSBundle mainBundle] resourcePath];
        NSArray * contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resources error:nil];
        
        for (NSString * item in contents) {
            NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
            if ([[item pathExtension] isEqualToString:@"wav"]){
                [sounds setObject:[soundFactory loadSoundNamed: item maxPolyphony: 3] forKey:[item stringByDeletingPathExtension]];
            }
            [pool release];
        }
        
        // load the background tunes
        NSString * soundPath = [[NSBundle mainBundle] pathForResource:@"background" ofType:@"mp3"];
        backgroundAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath: soundPath] error:nil];
        // set it up to loop indefinitely until stoppedq
        [backgroundAudioPlayer setNumberOfLoops: -1];
    }
    return self;
}

- (void)startMusic
{
    [backgroundAudioPlayer setVolume: 0.1];
    [backgroundAudioPlayer play];
    
    backgroundAudioVolumeIncrement = 0.03;
    
    if (!backgroundAudioTimer)
        backgroundAudioTimer = [[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(adjustMusicVolume) userInfo:nil repeats:YES] retain];
}

- (void)stopMusic
{
    backgroundAudioVolumeIncrement = -0.03;

    if (!backgroundAudioTimer)
        backgroundAudioTimer = [[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(adjustMusicVolume) userInfo:nil repeats:YES] retain];
}

- (void)adjustMusicVolume
{
    float v = [backgroundAudioPlayer volume];
    v += backgroundAudioVolumeIncrement;
    v = fmaxf(0, fminf(0.4,v));
    
    [backgroundAudioPlayer setVolume: v];
    
    if ((v >= 0.4) || (v <= 0)) {
        [backgroundAudioTimer invalidate];
        [backgroundAudioTimer release];
        backgroundAudioTimer = nil;
        
        if (v <= 0)
            [backgroundAudioPlayer stop];
        backgroundAudioVolumeIncrement = 0;
    }
}

- (void)playSoundWithIdentifier:(NSString*)i
{
    [self playSoundWithIdentifier:i withYPosition:0 withVolume:1];
}
     
- (void)playSoundWithIdentifier:(NSString*)i withVolume:(float)volume
{
    [self playSoundWithIdentifier:i withYPosition:0 withVolume:volume];
}

- (void)playSoundWithIdentifier:(NSString*)i withYPosition:(float)offset withVolume:(float)volume
{
    FISound * f = [sounds objectForKey: i];
    [f setGain: 0.2];
    [f setPosition: CGPointMake(offset, 0)];
    
    if (f) [f play];
    else
        NSLog(@"Play request for invalid sound: %@", i);
}

@end
