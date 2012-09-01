//
//  UnscrambleViewController.h
//  SpellingJungle
//
//  Created by Ben Gotow on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimalView.h"

@interface UnscrambleViewController : UIViewController
{
    NSMutableArray *            _words;
    int                         _currentWordIndex;
    double                      _score;
    
    
    // Used for the drag and drop letter display:
    NSMutableArray *            _letterViews;
    NSMutableArray *            _unusedLetterViews;
    
    NSMutableArray *            _letterSpotViews;
    NSMutableArray *            _unusedLetterSpotViews;
    
    CGPoint                     _letterInitialCenter;
    CGPoint                     _touchOffsetWithinLetter;
    UIButton *                  _displacedLetter;
}   

@property (retain, nonatomic) IBOutlet UILabel * scoreLabel;
@property (retain, nonatomic) IBOutlet AnimalView * animalImageView;
@property (retain, nonatomic) IBOutlet UIButton * doneButton;

- (void)viewDidLoad;
- (void)viewDidUnload;
- (void)dealloc;

#pragma mark Drag and Drop

- (void)letterTapDown:(UIButton*)b withEvent:(UIEvent *)ev;
- (void)letterDragged:(UIButton *)b withEvent:(UIEvent *)ev;
- (void)letterTapUp:(UIButton*)b;

- (void)displaceLetter:(UIButton*)b;
- (void)restoreDisplacedLetter;
- (NSString*)getSpelledWord:(int*)incorrect;
- (void)startNewQuestion;

#pragma mark Interface Builder Actions

- (IBAction)checkAnswerTapped:(id)sender;
- (IBAction)exitTapped:(id)sender;

#pragma mark Convenience Functions for Creating Views

- (UIButton*)newDraggableLetterButton;
- (UIView*)newLetterSpotView;

@end
