//
//  GameViewController.m
//  TrashBlaster
//
//  Created by Ben Gotow on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <KodiakReporting/KodiakReporting.h>

#import "GameViewController.h"
#import "MathQuestion.h"
#import "SoundManager.h"

#define TRASH_ON_SCREEN 7

@implementation GameViewController

@synthesize endGameButton;
@synthesize percentCorrectLabel;
@synthesize timeRemainingLabel;
@synthesize currentQuestionLabel;
@synthesize containerView, starPower;
@synthesize gameTransitionView, sky;
@synthesize gameTransitionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // prime some questions
    upcomingQuestions = [[NSMutableArray alloc] initWithCapacity: 10];
    answeredQuestions = [[NSMutableArray alloc] init];
    flyingStars = [[NSMutableArray alloc] init];
    items = [[NSMutableArray alloc] initWithCapacity: 10];
    numberOfQuestionsCompleted = 0;
    numberOfQuestionsCompletedInWave = 0;
    updateTimer = nil;
    
    // load the difficulty level
    difficultyLevel = [[NSUserDefaults standardUserDefaults] integerForKey: @"difficultyLevel"];
    
    srand(time(NULL));
    for (int ii = 0; ii < TRASH_ON_SCREEN; ii ++){
        [self addQuestion: YES];
    }
    
    // start a gameplay animation timer
    [self startNextQuestion];
    
    // register for notifications of the user tapping things
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userTappedStar:) name:@"StarClicked" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userTappedExtra:) name:@"ExtraClicked" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userTappedTrash:) name:@"TrashBlasted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDestroyedTrash:) name:@"TrashDestroyed" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setInteger:difficultyLevel forKey:@"difficultyLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[SoundManager sharedManager] stopMusic];
    [self stopGameTimer];
    
    [[KodiakReportingManager sharedManager] endActivitySession];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[SoundManager sharedManager] startMusic];
    [self startGameTimer];
    
    // tell Kodiak to start taking pictures of us
    [[KodiakReportingManager sharedManager] startActivitySession:@"activity_test_1"];
}

- (void)viewDidUnload
{
    // unregister from notifications
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [self setEndGameButton:nil];
    [self setPercentCorrectLabel:nil];
    [self setTimeRemainingLabel:nil];
    [self setCurrentQuestionLabel:nil];
    [self setContainerView:nil];
    [super viewDidUnload];
}

- (void)startGameTimer
{
    // start an update loop
    [updateTimer invalidate];
    [updateTimer release];
    updateTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 / 25.0 target:self selector:@selector(update) userInfo:nil repeats:YES] retain];
}

- (void)stopGameTimer
{
    [updateTimer invalidate];
    [updateTimer release];
    updateTimer = nil;   
}

- (void)addQuestion:(BOOL)onscreen
{
    MathQuestion * q = [[[MathQuestion alloc] initWithDifficultyLevel: difficultyLevel] autorelease];
    [upcomingQuestions addObject: q];
    
    // create a new trash item to represent the answer
    TrashItem * t = [[[TrashItem alloc] initWithValue: [q answer]] autorelease];
    [self addItem: t onscreen: onscreen];
    
    // should we add a random astronaut or something fun?
    if (rand() % 20 == 5){
        UIImage * i = [UIImage imageNamed:[NSString stringWithFormat:@"extra_%d", (random() % 2) + 1]];
        BaseItem * a = [[[BaseItem alloc] initWithImage:i andOnclickNotification:@"ExtraClicked"] autorelease];
        [self addItem:a onscreen:NO];
    }
}

- (void)addItem:(BaseItem *)t onscreen: (BOOL)onscreen
{
    if (onscreen){
        int x = rand() % 920;
        int y = rand() % 450;
        float r = (float)(rand() % 8000) / 8000.0f * M_PI * 2;
        float v = 3;
        [t setX: x Y: y VX: cosf(r)*v VY: sinf(r)*v];
    } else {
        float r = (float)(rand() % 8000) / 8000.0f * M_PI * 2;
        float v = 3;
        [t setX: [containerView center].x Y: [containerView center].y VX: cosf(r)*v VY: sinf(r)*v];
        
        [t setTransform: CGAffineTransformMakeScale(0.7, 0.7)];
        [t setAlpha: 0];
        [UIView beginAnimations: nil context:nil];
        [UIView setAnimationDuration: 1];
        [t setTransform: CGAffineTransformMakeScale(1, 1)];
        [t setAlpha: 1];
        [UIView commitAnimations];
        
    }
    [items addObject: t];
    [containerView addSubview: t];
}

- (void)dealloc
{
    // register for notifications of the user tapping things
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [items release];
    [flyingStars release];
    [answeredQuestions release];
    [upcomingQuestions release];
    [updateTimer invalidate];
    [updateTimer release];
    [nextWaveTimer invalidate];
    [nextWaveTimer release];
    [starPowerFlashTimer invalidate];
    [starPowerFlashTimer release];
    
    [super dealloc];
}

- (void)update
{
    for (int ii = [items count] - 1; ii >= 0; ii--)
        [[items objectAtIndex: ii] update];
        
    if ([NSDate timeIntervalSinceReferenceDate] - questionTimeLastUpdate > 1){
        // update the duration thing
        NSDateFormatter *f = [[[NSDateFormatter alloc] init] autorelease];
        [f setDateFormat:@"mm:ss"];
        
        NSString * timeRemaining = [f stringFromDate: [NSDate dateWithTimeIntervalSinceNow:questionStartTime]];
        [timeRemainingLabel setText: [NSString stringWithFormat:@"Wave %d - %@", wave, timeRemaining]];
        questionTimeLastUpdate = [NSDate timeIntervalSinceReferenceDate];
    }
    
    BOOL gameOver = [self decayStarPower];
    if (gameOver == YES){
        [gameTransitionLabel setText: @""];
        [[SoundManager sharedManager] playSoundWithIdentifier:@"power_down"];
        [self startGameTransition:[UIImage imageNamed:@"lose.png"] advanceToNextWave:NO];
    }
}

- (void)userTappedStar:(NSNotification*)sender
{
    BaseItem * star = [sender object];
    [star removeFromSuperview];
    [self.view addSubview: star];
    [flyingStars addObject: star];
    [items removeObject: star];
    
    [[SoundManager sharedManager] playSoundWithIdentifier:@"earn_points"];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.5];
    CGRect f = [star frame];
    f.origin.x = 860;
    f.origin.y = 615;
    [star setFrame:f];
    [star setAlpha: 0.25];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector:@selector(incrementStarPower)];
    [UIView commitAnimations];
}

- (void)incrementStarPower
{
    [self incrementStarPower: 40];
}

- (void)incrementStarPower:(float)amount
{
    if ([flyingStars count] > 0){
        [[flyingStars objectAtIndex: 0] removeFromSuperview];
        [flyingStars removeObjectAtIndex: 0];
    }
    
    CGRect f = [starPower frame];
    f.size.width = fminf(f.size.width + amount, 211);
    
    if (f.size.width > 50){
        [starPowerFlashTimer invalidate];
        [starPowerFlashTimer release];
        starPowerFlashTimer = nil;
        [starPower setImage: [UIImage imageNamed:@"liquid.png"]];
    }
    
    [starPower setFrame: f];
}

- (BOOL)decayStarPower
{
    CGRect f = [starPower frame];
    f.size.width = fmaxf(f.size.width -0.18, 0);
    
    if ((f.size.width <= 80) && ([starPower frame].size.width > 80)){
        [[SoundManager sharedManager] playSoundWithIdentifier:@"warning"]; 
        [starPower setImage: [UIImage imageNamed:@"liquid_red.png"]];
        starPowerFlashTimer = [[NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(flashStarPower) userInfo:nil repeats:YES] retain];
        starPowerFlashCount = 0;
    }
    
    [starPower setFrame: f];
    
    return (f.size.width <= 0);
}

- (void)flashStarPower
{
    UIImage * red = [UIImage imageNamed:@"liquid_red.png"];
    UIImage * blue = [UIImage imageNamed:@"liquid.png"];
    
    if ([[starPower image] isEqual: red])
        [starPower setImage: blue];
    else
        [starPower setImage: red];
        
    starPowerFlashCount ++;
    if (starPowerFlashCount > 10){
        [starPowerFlashTimer invalidate];
        [starPowerFlashTimer release];
        starPowerFlashTimer = nil;
    }
}

- (void)userTappedExtra:(NSNotification*)sender
{
    int i = (random() % 2) + 1; 
    NSString * extraSoundId = [NSString stringWithFormat:@"extra%d", i];
    [[SoundManager sharedManager] playSoundWithIdentifier:extraSoundId];
    BaseItem * a = [sender object];
    [a setSpinRate: -M_PI / 20];
}

- (void)userTappedTrash:(NSNotification*)sender
{
    MathQuestion * question = [upcomingQuestions objectAtIndex: 0];
    TrashItem * primary = [sender object];
    NSMutableArray * matches = [NSMutableArray arrayWithObjects: primary, nil];
    
    // look to see if the user could have intended to hit another item under this one
    CGPoint primaryCenter = [primary center];
    for (TrashItem * other in items){
        if ((primary != other) && ([other isKindOfClass: [TrashItem class]])){
            CGPoint otherCenter = [other center];
            float dist = sqrtf(powf(otherCenter.x - primaryCenter.x, 2) + powf(otherCenter.y - primaryCenter.y, 2));
            if (dist < 100)
                [matches addObject: other];
        }
    }
    
    TrashItem * bestHit = primary;
    
    for (TrashItem * item in matches){
        if ([item value] == [question answer]){
            bestHit = item;
            break;
        }
    }
    
    if ([bestHit value] == [question answer])
        [self userCorrectlyTappedTrash: bestHit];
    else
        [self userIncorrectlyTappedTrash: bestHit];

    // update the HUD to show the correct fraction of the questions gotten right
    [percentCorrectLabel setText:[NSString stringWithFormat: @"Accuracy: %d / %d", numberOfHits, numberOfHits + numberOfMisses]];
}

- (void)userCorrectlyTappedTrash:(TrashItem*)item
{
    MathQuestion * question = [upcomingQuestions objectAtIndex: 0];
    
    // play sound
    int i = (random() % 3) + 1; 
    NSString * bombSoundId = [NSString stringWithFormat:@"bomb%d", i];
    [[SoundManager sharedManager] playSoundWithIdentifier:bombSoundId];
    
    // make the star explode
    [item setExploding: YES];
    
    // mark how long it took the user to answer this question
    NSTimeInterval questionEndTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval duration = questionEndTime - questionStartTime;
    [question setDuration: duration];
    [question setStudentAnswer: [item value]];
    
    // submit the question to Kodiak
    KodiakQuestionEvent * q = [question kodiakEvent];
    [[KodiakReportingManager sharedManager] pushEvent: q];
    
    // should we give the user a star?
    if (random() % 10 > 4){
        BaseItem * a = [[BaseItem alloc] initWithImage:[UIImage imageNamed:@"star"] andOnclickNotification:@"StarClicked"];
        [self addItem:a onscreen:NO];
        [a setX: [item x] Y: [item y]];
        [a autorelease];
    }
    
    numberOfHits ++;
    numberOfQuestionsCompleted ++;
    numberOfQuestionsCompletedInWave ++;
    [upcomingQuestions removeObjectAtIndex: 0];
    
    [self startNextQuestion];
}

- (void)userIncorrectlyTappedTrash:(TrashItem*)item
{
    MathQuestion * question = [upcomingQuestions objectAtIndex: 0];
    
    // submit the incorrect question to Kodiak
    [question setStudentAnswer: [item value]];
    [[KodiakReportingManager sharedManager] pushEvent: [question kodiakEvent]];
        
    [[SoundManager sharedManager] playSoundWithIdentifier:@"buzzer"];
    numberOfMisses ++;
    [item setRedTime: 1];
}

- (void)userDestroyedTrash:(NSNotification*)sender
{
    TrashItem * item = [sender object];
    [items removeObject: item];
    [item removeFromSuperview];
}

- (void)startNextQuestion
{
    [currentQuestionLabel setText: [[upcomingQuestions objectAtIndex: 0] stringValue]];
    questionStartTime = [NSDate timeIntervalSinceReferenceDate];
    [self addQuestion: NO];
    
    if (numberOfQuestionsCompletedInWave > 10)
    {
        // decide if we should make the next wave harder, easier, or the same
        double fractionCorrect = (double)numberOfHits / (double)(numberOfHits + numberOfMisses);
        if (fractionCorrect > 0.75f) {
            [gameTransitionLabel setText:[NSString stringWithFormat:@"%d of %d! Let's try something harder.", numberOfHits, numberOfHits + numberOfMisses]];
            difficultyLevel ++;
        } else if (fractionCorrect < 0.25f) {
            [gameTransitionLabel setText: @"Let's try something a bit easier!"];    
            difficultyLevel = fminf(0, difficultyLevel-1);    
        } else {
            [gameTransitionLabel setText: @"Keep up the good work!"];
        }
    
        [self startGameTransition:[UIImage imageNamed:@"win.png"] advanceToNextWave: YES];
    }
}

- (void)startGameTransition:(UIImage*)transitionImage advanceToNextWave:(BOOL)advance
{
    // we're done!
    [gameTransitionView setImage:transitionImage];
    [gameTransitionView setAlpha: 0];
    [gameTransitionLabel setAlpha: 0];
    [gameTransitionView setHidden: NO];
    [gameTransitionLabel setHidden: NO];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.6];
    [gameTransitionView setAlpha: 1];
    [gameTransitionLabel setAlpha: 1];
    [currentQuestionLabel setAlpha: 0];
    [timeRemainingLabel setAlpha: 0];
    [percentCorrectLabel setAlpha: 0];
    [containerView setAlpha: 0];
    [UIView commitAnimations];
    
    [self stopGameTimer];
    
    if (advance){
        [[SoundManager sharedManager] playSoundWithIdentifier:@"trumpets"];
        nextWaveTimer = [[NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(startNextWave) userInfo:nil repeats:NO] retain];
    }
}

- (void)startNextWave
{
    // remove all the questions
    [upcomingQuestions removeAllObjects];
    [items removeAllObjects];
    for (UIView * v in [containerView subviews])
        [v removeFromSuperview];
    
    for (int ii = 0; ii < TRASH_ON_SCREEN; ii++)
        [self addQuestion: YES];
    [currentQuestionLabel setText: [[upcomingQuestions objectAtIndex: 0] stringValue]];
    questionStartTime = [NSDate timeIntervalSinceReferenceDate];

    [nextWaveTimer release];
    nextWaveTimer = nil;
    [self startGameTimer];
    
    wave++;
    numberOfMisses = 0;
    numberOfHits = 0;
    numberOfQuestionsCompletedInWave = 0;
    [percentCorrectLabel setText:[NSString stringWithFormat: @"Accuracy: %d / %d", numberOfHits, numberOfHits + numberOfMisses]];
    
    // reset star power to it's full capacity
    [self incrementStarPower: 1000];
    
    // choose a new sky background
    [sky setImage: [UIImage imageNamed: [NSString stringWithFormat: @"sky_%d.png", (wave % 11) + 1]]];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.6];
    [gameTransitionView setAlpha: 0];
    [gameTransitionLabel setAlpha: 0];
    [containerView setAlpha: 1];
    [currentQuestionLabel setAlpha: 1];
    [timeRemainingLabel setAlpha: 1];
    [percentCorrectLabel setAlpha: 1];
    [UIView commitAnimations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)endGame:(id)sender 
{
    [self dismissModalViewControllerAnimated: YES];
}



@end
