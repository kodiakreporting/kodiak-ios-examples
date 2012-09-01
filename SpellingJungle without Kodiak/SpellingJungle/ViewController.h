//
//  ViewController.h
//  SpellingJungle
//
//  Created by Ben Gotow on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    int     _studentTrophyCount;
}

@property (retain, nonatomic) IBOutlet UILabel *trophyCountLabel;
@property (retain, nonatomic) IBOutlet UILabel *trophyDescriptionLabel;

- (void)viewDidLoad;
- (void)viewDidUnload;
- (void)dealloc;

- (void)awardTrophy:(NSNotification*)notif;
- (void)updateTrophyUI;

- (IBAction)startSpellingActivity:(id)sender;
- (IBAction)startUnscrambleActivity:(id)sender;

@end
