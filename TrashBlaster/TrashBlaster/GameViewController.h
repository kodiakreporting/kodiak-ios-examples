//
//  GameViewController.h
//  TrashBlaster
//
//  Created by Ben Gotow on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseItem.h"
#import "TrashItem.h"

@interface GameViewController : UIViewController
{
    NSMutableArray * items;
    NSMutableArray * flyingStars;
    NSMutableArray * upcomingQuestions;
    NSMutableArray * answeredQuestions;
    
    NSTimeInterval questionStartTime;
    NSTimeInterval questionTimeLastUpdate;
    
    NSTimer * updateTimer;
    NSTimer * nextWaveTimer;
    
    NSTimer * starPowerFlashTimer;
    int starPowerFlashCount;
    
    int numberOfHits;
    int numberOfMisses;
    
    int numberOfQuestionsCompleted;
    int numberOfQuestionsCompletedInWave;

    int wave;
    int difficultyLevel;
}

@property (assign, nonatomic) IBOutlet UIImageView * sky;
@property (assign, nonatomic) IBOutlet UIImageView * starPower;
@property (assign, nonatomic) IBOutlet UIButton *endGameButton;
@property (assign, nonatomic) IBOutlet UILabel *percentCorrectLabel;
@property (assign, nonatomic) IBOutlet UILabel *timeRemainingLabel;
@property (assign, nonatomic) IBOutlet UILabel *currentQuestionLabel;
@property (assign, nonatomic) IBOutlet UIImageView *gameTransitionView;
@property (assign, nonatomic) IBOutlet UILabel *gameTransitionLabel;
@property (assign, nonatomic) IBOutlet UIView *containerView;

- (IBAction)endGame:(id)sender;

- (void)update;

- (void)startGameTimer;
- (void)stopGameTimer;

- (void)incrementStarPower;
- (void)incrementStarPower:(float)amount;
- (BOOL)decayStarPower;

- (void)addQuestion:(BOOL)onscreen;
- (void)addItem:(BaseItem *)t onscreen: (BOOL)onscreen;

- (void)userCorrectlyTappedTrash:(TrashItem*)correct;
- (void)userIncorrectlyTappedTrash:(TrashItem*)item;
- (void)userDestroyedTrash:(NSNotification*)sender;

- (void)startNextQuestion;
- (void)startNextWave;
- (void)startGameTransition:(UIImage*)transitionImage advanceToNextWave:(BOOL)advance;

@end
