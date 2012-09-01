//
//  ViewController.m
//  SpellingJungle
//
//  Created by Ben Gotow on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "SpellingViewController.h"
#import "UnscrambleViewController.h"
#import "NiceWorkViewController.h"
#import "SoundManager.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize trophyCountLabel = _trophyCountLabel;
@synthesize trophyDescriptionLabel = _trophyDescriptionLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Start background music
    [[SoundManager sharedManager] startMusic];
    
    // Listen for a notification coming back from the activities when they're done.
    // Right now we give a "trophy" to the user every time they play.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(awardTrophy:) name:@"AwardTrophy" object:nil];

    // Load the number of saved trophies from NSUserDefaults
    _studentTrophyCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"studentTrophyCount"];    
    [self updateTrophyUI];
}

- (void)viewDidUnload 
{
    [self setTrophyCountLabel:nil];
    [self setTrophyDescriptionLabel:nil];
    [super viewDidUnload];
}

- (void)dealloc 
{
    [_trophyCountLabel release];
    [_trophyDescriptionLabel release];
    [super dealloc];
}


- (void)awardTrophy:(NSNotification*)notif
{
    // Whenever the user plays all the way through an activity, they get a trophy.
    // This isn't really a great game mechanic, but I want to demo storing information
    // about student's achievements with Kodiak, so we'll just pretend a bit.
    
    // Dismiss the game activity
    [self dismissModalViewControllerAnimated: NO];
    
    // Immediately show the "Nice work" view
    NiceWorkViewController * c = [[NiceWorkViewController alloc] init];
    [self presentModalViewController:c animated:NO];
    [c release];
    
    // Increment the trophy count. This is _really_ ghetto and your app would most
    // likely have different kinds of trophies or achievements, or at least keep them
    // in some organized dictionary or something! :-)
    _studentTrophyCount ++;
    [self updateTrophyUI];
    
    // Write the change to NSUserDefaults so it's saved between launches
    [[NSUserDefaults standardUserDefaults] setInteger:_studentTrophyCount forKey:@"studentTrophyCount"];
    
}

- (void)updateTrophyUI
{
    NSString * t = [NSString stringWithFormat:@"You have %d trophies! Earn more by playing.", _studentTrophyCount];

    [_trophyCountLabel setText: [NSString stringWithFormat:@"%d", _studentTrophyCount]];
    [_trophyDescriptionLabel setText: t];
}

- (IBAction)startSpellingActivity:(id)sender 
{
    // Start the spelling activity
    SpellingViewController * c = [[SpellingViewController alloc] init];
    [self presentModalViewController:c animated:YES];
    [c release];
}

- (IBAction)startUnscrambleActivity:(id)sender 
{
    // Start the text unscrambling activity
    UnscrambleViewController * c = [[UnscrambleViewController alloc] init];
    [self presentModalViewController:c animated:YES];
    [c release];
}

@end
