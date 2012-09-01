//
//  SpellingViewController.h
//  SpellingJungle
//
//  Created by Ben Gotow on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimalView.h"

@interface SpellingViewController : UIViewController <UITextViewDelegate>
{
    NSMutableArray * _words;
    int              _wordIndex;
    
    int              _answeredCorrectly;
    int              _answeredWrong;
}

@property (retain, nonatomic) IBOutlet UILabel *correctnessLabel;
@property (retain, nonatomic) IBOutlet UITextView *spellingField;
@property (retain, nonatomic) IBOutlet AnimalView *animalImageView;
@property (retain, nonatomic) IBOutlet UIButton *continueButton;

- (void)viewDidLoad;
- (void)viewDidUnload;
- (IBAction)checkAnswerTapped:(id)sender;
- (IBAction)exitTapped:(id)sender;
- (void)dealloc;

#pragma mark Question / Answer Logic

- (void)displayCorrectWord;
- (void)displayNewWord;

#pragma mark Text Field Delegate Functions

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

@end
