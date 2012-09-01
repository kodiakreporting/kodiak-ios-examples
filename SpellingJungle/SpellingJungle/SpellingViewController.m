//
//  SpellingViewController.m
//  SpellingJungle
//
//  Created by Ben Gotow on 2/24/12.
//  Copyright (c) 2012 Kodiak Software. All rights reserved.
//
#import "SpellingViewController.h"
#import "SoundManager.h"

@implementation SpellingViewController

@synthesize spellingField;
@synthesize animalImageView;
@synthesize correctnessLabel;
@synthesize continueButton;
@synthesize currentQuestion;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // make the text field the first responder immediately so that the keyboard appears
    [spellingField becomeFirstResponder];
    
    // load all the words that we can ask - they're just the image names in the animals folder
    NSArray * paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"animals"];
    
    _wordIndex = 0;
    _words = [[NSMutableArray alloc] init];
    for (NSString * path in paths)
        [_words addObject: [[path lastPathComponent] stringByDeletingPathExtension]];
    
    // begin the first question
    [self displayNewWord];
    
    // open a new Kodiak session
    [[KodiakReportingManager sharedManager] startActivitySession:@"activity_test_1"];
}

- (void)viewDidUnload
{
    [self setSpellingField:nil];
    [self setAnimalImageView:nil];
    [super viewDidUnload];
}

- (IBAction)checkAnswerTapped:(id)sender 
{
    // Get the expected word and the student's response
    NSString * expectedWord = [[_words objectAtIndex: _wordIndex] lowercaseString];
    NSString * studentWord = [[spellingField text] lowercaseString];

    // Be sure to ignore any whitespace or newlines in the student's answer
    studentWord = [studentWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // If their answer is empty, they haven't typed a single letter and we won't
    // let them continue. Just play the animal name again.
    if ([studentWord length] == 0) {
        [animalImageView play];
        return;
    }
    
    BOOL correct = [expectedWord isEqualToString: studentWord];
    if (correct) {
        // play the good job sound and move on to the next question
        [[SoundManager sharedManager] playSoundWithIdentifier:@"fanfare"];
        _answeredCorrectly ++;
        
        // turn the text green to indicate a correct answer
        [spellingField setTextColor: [UIColor greenColor]];
        [self performSelector:@selector(displayNewWord) withObject:nil afterDelay:1];
        
    } else {
        // play the fail noise and the "Try again" audio
        [[SoundManager sharedManager] playSoundWithIdentifier:@"fail"];
        [[SoundManager sharedManager] playSoundWithIdentifier:@"notquite"];
        _answeredWrong ++;
        
        // turn the text red to indicate an incorrect answer
        [spellingField setTextColor: [UIColor redColor]];
        
        [self performSelector:@selector(displayCorrectWord) withObject:nil afterDelay:1];
        [self performSelector:@selector(displayNewWord) withObject:nil afterDelay:3.3];
    }
    
    // Save the student's answer to the KodiakQuestionEvent and submit it
    [currentQuestion answered:studentWord withCorrectness:correct];
    [[KodiakReportingManager sharedManager] pushEvent: currentQuestion];
    self.currentQuestion = nil;
    
    // update the status label in the top right so that it shows the fraction of correct answers
    NSString * correctness = [NSString stringWithFormat:@"%d / %d", _answeredCorrectly, _answeredWrong + _answeredCorrectly];
    [correctnessLabel setText: correctness];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.3];
    [continueButton setAlpha: 0.5];
    [continueButton setUserInteractionEnabled: NO];
    [UIView commitAnimations];
}

- (IBAction)exitTapped:(id)sender 
{   
    // end the Kodiak session
    [[KodiakReportingManager sharedManager] endActivitySession];
    
    [self dismissModalViewControllerAnimated: YES];
}

- (void)dealloc 
{
    [_words release];
    [spellingField release];
    [animalImageView release];
    [correctnessLabel release];
    [currentQuestion release];
    [super dealloc];
}

#pragma mark Question / Answer Logic

- (void)displayCorrectWord
{
    [spellingField setTextColor: [UIColor blackColor]];
    [spellingField setText: [[_words objectAtIndex: _wordIndex] capitalizedString]];
}

- (void)displayNewWord
{
    _wordIndex++;
    if (_wordIndex >= [_words count]) {
        // They've finished the game! Tell the main ViewController to give them a trophy and we'll be
        // dismissed. Normally, there would be a singleton or something responsible for tracking achievements
        // but we're being lazy...
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AwardTrophy" object:nil];
        return;
    }
    
    // Get the word and update the animal view (a custom class) so that it shows
    // the image for the new word.
    NSString * word = [_words objectAtIndex: _wordIndex];
    [animalImageView setWord: word];
    
    // clear their text field so they can type a new answer
    [spellingField setText: @""];
    [spellingField setTextColor: [UIColor blackColor]];
    
    // Play the "Spell" and then the <word> audio clips
    [[SoundManager sharedManager] playSoundWithIdentifier:@"spellprompt"];    
    [animalImageView performSelector:@selector(play) withObject:nil afterDelay:1.2];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.3];
    [continueButton setAlpha: 1];
    [continueButton setUserInteractionEnabled: YES];
    [UIView commitAnimations];
    
    // Create a new KodiakQuestionEvent to represent the question that we've just displayed.
    // We need to create one now and then mark it as answered later so that Kodiak can
    // track how long it took the student to provide an answer:
    NSString * question = [NSString stringWithFormat:@"Spell %@", word];
    self.currentQuestion = [KodiakQuestionEvent eventForQuestion:question withCorrectAnswer:word];
}

#pragma mark Text Field Delegate Functions

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Prevent the user from typing spaces and newlines
    if ([text rangeOfString:@"\n"].location != NSNotFound)
        return NO;
    if ([text rangeOfString:@" "].location != NSNotFound)
        return NO;
    return YES;
}

@end
