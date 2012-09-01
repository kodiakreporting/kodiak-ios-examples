//
//  UnscrambleViewController.m
//  SpellingJungle
//
//  Created by Ben Gotow on 2/24/12.
//  Copyright (c) 2012 Kodiak Software. All rights reserved.
//

#import <KodiakReporting/KodiakReporting.h>
#import "UnscrambleViewController.h"
#import "SoundManager.h"

#define LETTER_BUTTON_LETTER_0_TAG      100


@implementation UnscrambleViewController

@synthesize animalImageView, doneButton, scoreLabel, currentQuestion;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // put together a list of all the words we'll ask them - for now,
    // let's just use the animal image names (in the /animals folder) as the words
    NSArray * paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"animals"];
    
    _words = [[NSMutableArray alloc] init];
    for (NSString * path in paths) {
        // get the word from the file path
        NSString * word = [[path lastPathComponent] stringByDeletingPathExtension];

        // this is just a demo, and it doesn't work very well with the longer words, like 
        // rhinocerous. Let's just remove them and work with the nice shorter words.
        if ([word length] < 8)
            [_words addObject: word];
    }
    
    // initialize storage
    _letterViews = [[NSMutableArray alloc] init];
    _letterSpotViews = [[NSMutableArray alloc] init];
    _unusedLetterViews = [[NSMutableArray alloc] init];
    _unusedLetterSpotViews = [[NSMutableArray alloc] init];
    _currentWordIndex = 0;
    
    // open a new Kodiak session
    [[KodiakReportingManager sharedManager] startActivitySession:@"activity_test_2"];
    
    // start the game! put the first unscramble question onscreen
    [self startNewQuestion];
}


- (void)viewDidUnload
{
    [self setAnimalImageView:nil];
    [super viewDidUnload];
}

- (void)dealloc 
{
    self.currentQuestion = nil;
    
    [_letterViews release];
    [_unusedLetterViews release];
    [_letterSpotViews release];
    [_unusedLetterSpotViews release];
    [animalImageView release];
    [super dealloc];
}

#pragma mark Drag and Drop

- (void)letterTapDown:(UIButton*)b withEvent:(UIEvent *)ev
{
    UITouch * t = [[ev touchesForView:b] anyObject];
    
    // save the offset of the user's finger within the button so that we can keep this offset
    // constant as they drag. 
    _touchOffsetWithinLetter = [t locationInView: b];
    
    // save the current position of the button so that we can return the button to this position
    // if the user doesn't drop it into one of the letter spots.
    _letterInitialCenter = [b center];
    _displacedLetter = nil;
    
    // bring the dragging tile to the front so it goes over all the other letters as you drag.
    [self.view bringSubviewToFront: b];
    
    // make the dragged tile semitransparent
    [b setAlpha: 0.5];
    
    // play the click sound. Audio feedback is great for kids.
    [[SoundManager sharedManager] playSoundWithIdentifier:@"pickup"];
}

- (void)letterDragged:(UIButton *)b withEvent:(UIEvent *)ev 
{
    UITouch * t = [[ev touchesForView:b] anyObject];
    CGPoint p = [t locationInView: self.view];
    CGRect f = [b frame];
    
    // adjust the button's position to account for the drag, applying the touch offset so that it doesn't
    // have any initial jerk when they touch down on it.
    f.origin = CGPointMake(p.x - _touchOffsetWithinLetter.x, p.y - _touchOffsetWithinLetter.y);
    [b setFrame: f];
    
    // has the letter been lowered into the bottom tray? If it's within 40px of one of the 
    // letter positions, let's snap-to-fit. The logic here is a bit complicated because we want to 
    // "displace" (or move out of the way) any letter that is already in the well that we snap-to-fit into.
    // - If the user moves on to another spot, we'll slide that displaced letter back.
    // - If the user lets go of the letter while in this spot, the displaced letter just stays above the spot.
    BOOL inSpot = NO;
    for (UIView * v in _letterSpotViews) {
        if (sqrtf(powf(b.center.x - v.center.x, 2) + powf(b.center.y - v.center.y, 2)) < 40) {
            [b setCenter: v.center];
            inSpot = YES;
        }
    }
    
    if (inSpot == YES) {
        // is there another button in this spot besides us? If there is, we want to move it 
        // out of the way. 
        UIButton * newDisplacedLetter = nil;
        for (UIButton * other in _letterViews) {
            if ((other != b) && (other.center.x == b.center.x) && (other.center.y == b.center.y))
                newDisplacedLetter = other;
        }
        
        if (newDisplacedLetter && (newDisplacedLetter != _displacedLetter)) {
            if (_displacedLetter)
                [self restoreDisplacedLetter];
            [self displaceLetter: newDisplacedLetter];
        }
        
    } else {
        if (_displacedLetter)
            [self restoreDisplacedLetter];
    }
}

- (void)letterTapUp:(UIButton*)b
{
    BOOL inSpot = NO;
    [b setAlpha: 1.0];
    
    [[SoundManager sharedManager] playSoundWithIdentifier:@"place"];
    
    // Run the snap-to-fit analysis again. We need to know whether the tile has been placed.
    for (UIView * v in _letterSpotViews) {
        if (sqrtf(powf(b.center.x - v.center.x, 2)+powf(b.center.y - v.center.y, 2)) < 40) {
            [b setCenter: v.center];
            inSpot = YES;
        }
    }
    
    // if we displaced a letter from it's spot and the user didn't end up putting this letter in that
    // spot, go ahead and put the displaced letter back where it was.
    if ((_displacedLetter) && (_displacedLetter.center.x != b.center.x))
        [self restoreDisplacedLetter];
        
    if (inSpot == NO) {
        // The user has let go of the letter, but it's not snapped-to-fit in any of the letter spots.
        // Let's animate the button going back to where it was when the drag started. We want to move it
        // at constant speed, so we do a little math here to get the duration of the animation 
        float dist = sqrtf(powf(b.center.x - _letterInitialCenter.x, 2)+powf(b.center.y - _letterInitialCenter.y, 2));
        float speed = 1.0 / 400.0; // sec/px
        
        [UIView beginAnimations: nil context:nil];
        [UIView setAnimationDuration: dist * speed]; // sec/px * px
        [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
        [b setCenter: _letterInitialCenter];
        [UIView commitAnimations];
    }
    
    // highlight the done button if they have filled all of letter spots 
    [doneButton setSelected: ([[self getSpelledWord: NULL] length] == [_letterViews count])];
}

- (void)displaceLetter:(UIButton*)b
{
    // Shift the letter up and out of the letter spot it's currently occupying so that
    // another letter can be dragged and drop into that space.
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.25];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
    [b setCenter: CGPointMake(b.center.x, b.center.y - 60)];
    _displacedLetter = b;
    [UIView commitAnimations];
}

- (void)restoreDisplacedLetter
{
    // shift the displaced letter back down into it's slot and forget about it.
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.25];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
    [_displacedLetter setCenter: CGPointMake(_displacedLetter.center.x, _displacedLetter.center.y + 60)];
    [UIView commitAnimations];
    _displacedLetter = nil;
}

- (NSString*)getSpelledWord:(int*)incorrect
{
    // Let's see what they've dragged into the tray. This is a bit tricky, and we'll also
    // keep track of how many letters are in the wrong positions to make grading easy.
    NSMutableString * studentAnswer = [NSMutableString string];
    int incorrectLetters = 0;
    
    for (int ii = 0; ii < [_letterSpotViews count]; ii++) {
        UIView * spot = [_letterSpotViews objectAtIndex: ii];
        UIButton * letterTile = nil;
        
        // See if there's a letter view on top of this spot: 
        for (int x = 0; x < [_letterViews count]; x++) {
            UIButton * l = [_letterViews objectAtIndex: x];
            if (l.center.x == spot.center.x) {
                letterTile = l;
                break;
            }
        }
        
        // Cool! The user has placed a letter in this spot. Append the letter
        // to our studentAnswer string and see if it was correct.
        if (letterTile != nil) {
            NSString * letterString = [letterTile titleForState: UIControlStateNormal];
            [studentAnswer appendString: [letterString lowercaseString]];
            
            // is the letter in the right place? Since we assigned each letter a tag,
            // we know what position in the array it should have been in. Look at the 
            // tile that should be in this spot and see if it has the same letter on it
            UIButton * correctLetterTile = (UIButton*)[self.view viewWithTag:LETTER_BUTTON_LETTER_0_TAG + ii];
            NSString * correctLetterString = [correctLetterTile titleForState: UIControlStateNormal];
    
            // Ahh bummer... the letter here is not the correct one. Fail ++
            if ([letterString isEqualToString: correctLetterString] == NO)
                incorrectLetters += 1;
        }
    }
    
    if (incorrect != NULL)
        *incorrect = incorrectLetters;
    return studentAnswer;
}

- (void)startNewQuestion
{
    if (_currentWordIndex >= [_words count]) {
        // They've finished the game! Tell the main ViewController to give them a trophy and we'll be
        // dismissed. Normally, there would be a singleton or something responsible for tracking achievements
        // but we're being lazy...
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AwardTrophy" object:nil];
        return;
    }

    // enable the "Done" button again (we disable it between questions so student's
    // can't double-tap and skip questions
    [doneButton setUserInteractionEnabled: YES];
    
    // Remove and reset all the letters and spots. Note that we just put the letters
    // in an "unused" array rather than destorying and recreating them each time.
    for (UIButton * b in _letterViews){
        [b removeFromSuperview];
        [[b titleLabel] setTextColor: [UIColor blackColor]];
    }
    [_unusedLetterViews addObjectsFromArray: _letterViews];
    [_letterViews removeAllObjects];
    
    for (UIButton * b in _letterSpotViews){
        [b removeFromSuperview];
    }
    [_unusedLetterSpotViews addObjectsFromArray: _letterSpotViews];
    [_letterSpotViews removeAllObjects];
    
    NSString * currentWord = [_words objectAtIndex: _currentWordIndex];
    [animalImageView setWord: currentWord];
    [animalImageView play];
    
    // Iterate over the word and populate the letter views array with
    // the tile buttons for the new word.
    for (int ii = 0; ii < [currentWord length]; ii++) {
        NSString * letter = [currentWord substringWithRange:NSMakeRange(ii, 1)];

        if ([_unusedLetterViews count] == 0)
            [_unusedLetterViews addObject: [self newDraggableLetterButton]];
        
        if ([_unusedLetterSpotViews count] == 0)
            [_unusedLetterSpotViews addObject: [self newLetterSpotView]];
        
        // initialize the draggable letter
        UIButton * letterButton = [_unusedLetterViews lastObject];
        [_letterViews addObject: letterButton];
        [_unusedLetterViews removeLastObject];
        [letterButton setTitle:[letter uppercaseString] forState:UIControlStateNormal];
        [letterButton setTag: LETTER_BUTTON_LETTER_0_TAG + ii];
        
        // initialize the spot where the letter will be dragged to
        UIButton * letterSpot = [_unusedLetterSpotViews lastObject];
        [_letterSpotViews addObject: letterSpot];
        [_unusedLetterSpotViews removeLastObject];
    }
    
    // scramble the order of the buttons in the _letterViews array so they aren't
    // placed on screen in order!
    for (int pass = 0; pass < 10; pass++) {
        int srcIndex = (rand() * pass) % [_letterViews count];
        [_letterViews exchangeObjectAtIndex:0 withObjectAtIndex:srcIndex];
    }
    
    // layout the spot views at the bottom of the screen - the row of empty spots where you can place
    // the letters when you drag them. Note that the dragging code makes the letter buttons
    // snap to fit on top of these guys, and we do them first so the letter buttons are layered on top.
    int spotXSpacing = fmaxf(self.view.frame.size.width / ([_letterSpotViews count] + 1), 40);
    float spotY = self.view.frame.size.height - 120;
    
    for (int ii = 0; ii < [_letterSpotViews count]; ii++) {
        UIView * spot = [_letterSpotViews objectAtIndex: ii];
        [spot setCenter: CGPointMake((self.view.frame.size.width - spotXSpacing * ([_letterSpotViews count] - 1)) / 2 + spotXSpacing * ii, spotY)];
        [self.view addSubview: spot];
    }
    
    // now we have all the buttons setup, let's place them onscreen. We'll place them in
    // rows a set distance below the animal view, and center them in their rows.
    int buttonsPerRow = ([_letterViews count] > 5) ? 4 : 5;
    int buttonXSpacing = self.view.frame.size.width / (buttonsPerRow + 1);
    int buttonYSpacing = 50;
    int buttonYTop = [animalImageView frame].origin.y + [animalImageView frame].size.height + 5;
    
    for (int ii = 0; ii < [_letterViews count]; ii++) {
        UIButton * button = [_letterViews objectAtIndex: ii];
        int row = floor(ii / buttonsPerRow);
        int itemsInRow = fmin(buttonsPerRow, [_letterViews count] - row * buttonsPerRow);
        int indexInRow = ii % buttonsPerRow;
        
        CGPoint p = CGPointMake(((buttonsPerRow - itemsInRow) * buttonYSpacing) / 2 + buttonXSpacing * (1+indexInRow), buttonYTop + buttonYSpacing * row);
        [button setCenter: p];
        [self.view addSubview: button];
    }
    
    // Let's create a KodiakQuestionEvent to represent this question. We need to do this
    // now so Kodiak can automatically track the amount of time the student spends answering this question.
    // If you want to create a bunch of KodiakQuestionEvents at once and present them one
    // by one, use [KodiakQuestionEvent asked] function.
    NSString * question = [NSString stringWithFormat:@"Arrange the letters to spell %@", currentWord];
    self.currentQuestion = [KodiakQuestionEvent eventForQuestion:question withCorrectAnswer:currentWord];
}

#pragma mark Interface Builder Actions

- (IBAction)checkAnswerTapped:(id)sender
{
    // disable the done button while we play a bit of animation
    [doneButton setUserInteractionEnabled: NO];
    [doneButton setSelected: NO];
    
    int studentIncorrectLetters = 0;
    NSString * studentAnswer = [self getSpelledWord: &studentIncorrectLetters];
     
    // and see what the correct word was
    NSString * correctAnswer = [_words objectAtIndex: _currentWordIndex];
    
    // figure out how many letters were either in the wrong place or not used at all
    // Note that we divide by two because any misplaced letter means two letters are in 
    // the wrong place. (ie instead of ei is two incorrect)
    int totalIncorrect = studentIncorrectLetters / 2.0f + ([correctAnswer length] - [studentAnswer length]);
    
    // compute a "correctness" score based on how many letters off
    // the student was and add something to the student's score. 
    double correctness = 1 - (double)totalIncorrect / (double)[correctAnswer length];
    _score += 10 * correctness;
    
    // compare the answers...
    UIColor * newLetterColor = nil;
    NSTimeInterval newLetterDelay = 0;
    
    if ([studentAnswer isEqualToString: correctAnswer]) {
        // hell yea. They got it right!
        [[SoundManager sharedManager] playSoundWithIdentifier:@"fanfare"];
        // play the animal name another time, just for kicks
        [animalImageView play];
        
        newLetterColor = [UIColor greenColor];
        newLetterDelay = 1.3;
        
    } else {
        [[SoundManager sharedManager] playSoundWithIdentifier:@"fail"];
        [[SoundManager sharedManager] playSoundWithIdentifier:@"notquite"];
        newLetterColor = [UIColor redColor];
        newLetterDelay = 4;
        
        // queue up an animation to reorder all of the letters into the right order
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelay: 0.8];
        [UIView setAnimationDuration: 0.6];
        for (int ii = 0; ii < [_letterViews count]; ii++) {
            UIView * spot = [_letterSpotViews objectAtIndex: ii];
            UIView * button = [self.view viewWithTag: LETTER_BUTTON_LETTER_0_TAG + ii];
            button.center = spot.center;
        }
        [UIView commitAnimations];
    }
    
    // turn all the letters to the new letter color
    for (UIButton * b in _letterViews)
        [[b titleLabel] setTextColor: newLetterColor];

    // update the status label showing the percent correct
    NSString * scoreText = [NSString stringWithFormat:@"Points: %d", (int)roundf(_score)];
    [scoreLabel setText: scoreText];

    // start a new question with enough of a delay to let the animations play out
    _currentWordIndex ++;
    [self performSelector:@selector(startNewQuestion) withObject:nil afterDelay: newLetterDelay];
}

- (IBAction)exitTapped:(id)sender 
{
    // End the Kodiak session
    [[KodiakReportingManager sharedManager] endActivitySession];
    
    [self dismissModalViewControllerAnimated: YES];
}

#pragma mark Convenience Functions for Creating Views

- (UIButton*)newDraggableLetterButton
{
    // initialize and return a new UIButton with the wooden tile style applied
    UIButton * b = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [[b titleLabel] setFont:[UIFont boldSystemFontOfSize: 20]];
    [[b titleLabel] setTextColor: [UIColor blackColor]];
    [[b titleLabel] setTextAlignment: UITextAlignmentCenter];
    [b setBackgroundImage:[UIImage imageNamed:@"letter_button.png"] forState:UIControlStateNormal];
    [b addTarget:self action:@selector(letterTapDown:withEvent:) forControlEvents: UIControlEventTouchDown];
    [b addTarget:self action:@selector(letterDragged:withEvent:) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
    [b addTarget:self action:@selector(letterTapUp:) forControlEvents:UIControlEventTouchUpInside];
    return [b autorelease];
}

- (UIView*)newLetterSpotView
{
    // initialize and return a new UIImageView that is a little well where a tile can be placed.
    UIImageView * v = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [v setImage: [UIImage imageNamed:@"letter_spot.png"]];
    return [v autorelease];
}

@end
