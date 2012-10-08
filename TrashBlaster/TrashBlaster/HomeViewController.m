//
//  ViewController.m
//  TrashBlaster
//
//  Created by Ben Gotow on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "SoundManager.h"
#import "GameViewController.h"

@implementation HomeViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[SoundManager sharedManager] init];
    
    // get the Kodiak button and attach it to our view
    KodiakButton * b = [[KodiakReportingManager sharedManager] kodiakButtonWithType: KodiakButtonTypeBig];
    [b setFrameOrigin: CGPointMake(670,630)];
    [b setTheme:KodiakButtonThemeLight];
    [self.view addSubview: b];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // announce that we're the home view controller for the app
    [[KodiakReportingManager sharedManager] homeViewControllerDidAppear: self];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)startGame:(id)sender
{
    GameViewController * c = [[GameViewController alloc] init];
    [c setModalTransitionStyle: UIModalTransitionStyleCrossDissolve];
    [c setModalPresentationStyle: UIModalPresentationFullScreen];
    [self presentModalViewController:c animated:YES];
    [c autorelease];
}


@end
