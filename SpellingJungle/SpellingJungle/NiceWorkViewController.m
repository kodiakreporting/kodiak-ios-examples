//
//  NiceWorkViewController.m
//  SpellingJungle
//
//  Created by Ben Gotow on 2/27/12.
//  Copyright (c) 2012 Kodiak Software. All rights reserved.
//

#import "NiceWorkViewController.h"
#import "SoundManager.h"

@interface NiceWorkViewController ()

@end

@implementation NiceWorkViewController
@synthesize slidingBackgroundView;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[SoundManager sharedManager] playSoundWithIdentifier:@"fanfare"];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration: 5];
    [slidingBackgroundView setFrame: CGRectMake(0, 0, 500, 800)];
    [UIView commitAnimations];
}

- (void)viewDidUnload
{
    [self setSlidingBackgroundView:nil];
    [super viewDidUnload];
}

- (void)dealloc 
{
    [slidingBackgroundView release];
    [super dealloc];
}

- (IBAction)continueTapped:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
