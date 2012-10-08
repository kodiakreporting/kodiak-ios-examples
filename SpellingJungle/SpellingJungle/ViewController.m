//
//  ViewController.m
//  SpellingJungle
//
//  Created by Ben Gotow on 2/24/12.
//  Copyright (c) 2012 Kodiak Software. All rights reserved.
//

#import <KodiakReporting/KodiakReporting.h>
#import "ViewController.h"
#import "SpellingViewController.h"
#import "UnscrambleViewController.h"
#import "NiceWorkViewController.h"
#import "SoundManager.h"

#define METADATA_TROPHY_COUNT_KEY    @"trophies"

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

    // Our app gives students trophies each time they finish playing, and these 
    // are stored on Kodiak's servers so the student can access them from any device
    // they're using in school or at home.
    
    // Update the trophy UI to show the trophies of whoever is signed in by default
    [self updateTrophyUI];
    
    // Register for a notification when someone new signs in so we can update our UI
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTrophyUI) name:KODIAK_STUDENT_CHANGED object:nil];
    
    // Configure Kodiak with an API key
    [[KodiakReportingManager sharedManager] setAPIKey: @"1a9da573260e68f2a03b2cc3c60d6f6595c6aae8"];
    
    // Get a new instance of a KodiakButton
    KodiakButton * btn = [[KodiakReportingManager sharedManager] kodiakButtonWithType:KodiakButtonTypeThin];
    
    // Move the button to the bottom of our view and make it full width. We'll
    // do a bit of math to compute the correct frame.
    
    // Note: The KodiakButtonTypeThin button type must be at least 300px wide and 48px high.
    CGSize viewSize = self.view.frame.size;
    [btn setFrame:CGRectMake(0, viewSize.height - [btn frame].size.height, viewSize.width, [btn frame].size.height)];
    [btn setTheme: KodiakButtonThemeBlue];
    
    // Attach the button to our view so it appears onscreen
    [self.view addSubview: btn];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Tell Kodiak that the home screen of the app has been shown. If a parent or teacher has setup Kodiak,
    // and Kodiak hasn't prompted the user to select a student account recently, this will display a login
    // prompt asking the student to select their account. 
    [[KodiakReportingManager sharedManager] homeViewControllerDidAppear: self];
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
    
    // Get the current student object from Kodiak and create a mutable version of the
    // metadata that we can adjust and update.
    KodiakStudent * student = [[KodiakReportingManager sharedManager] currentStudent];
    NSMutableDictionary * mutableMetadata = [NSMutableDictionary dictionaryWithDictionary: [student metadata]];

    int existingTrophyCount = [[mutableMetadata objectForKey:METADATA_TROPHY_COUNT_KEY] intValue]; 
    existingTrophyCount ++;
    
    // Put the new trophy count into the metadata dictionary and then sync it
    // back to the Kodiak server by calling setMetadata:.
    [mutableMetadata setObject:[NSNumber numberWithInt: existingTrophyCount] forKey:METADATA_TROPHY_COUNT_KEY];
    [student setMetadata: mutableMetadata];
    
    // Update our UI
    [self updateTrophyUI];
}

- (void)updateTrophyUI
{
    // Get the current student that is signed into Kodiak
    KodiakStudent * student = [[KodiakReportingManager sharedManager] currentStudent];

    // Grab the metadata dictionary which has been synced with the cloud
    NSDictionary * syncedMetadata = [student metadata];

    // Pull out the trophy count that we saved in the dictionary
    int trophyCount = [[syncedMetadata objectForKey:METADATA_TROPHY_COUNT_KEY] intValue];
    
    // Update the interface to show the correct trophy count
    NSString * t = [NSString stringWithFormat:@"You have %d trophies! Earn more by playing.", trophyCount];
    [_trophyCountLabel setText: [NSString stringWithFormat:@"%d", trophyCount]];
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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

@end
