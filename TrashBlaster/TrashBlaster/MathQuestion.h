//
//  MathQuestion.h
//  TrashBlaster
//
//  Created by Ben Gotow on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KodiakReporting/KodiakReporting.h>

#define FUNCTION_ADD 0
#define FUNCTION_SUBTRACT 1
#define FUNCTION_MULTIPLY 2
#define FUNCTION_DIVIDE 3

@interface MathQuestion : NSObject{
        
    int a;
    int b;
    int function;
    int answer;
    int studentAnswer;
    int difficulty;
    NSTimeInterval duration;
}

@property (nonatomic, assign) int a;
@property (nonatomic, assign) int b;
@property (nonatomic, assign) int function;
@property (nonatomic, assign) int answer;
@property (nonatomic, assign) int studentAnswer;
@property (nonatomic, assign) int difficulty;
@property (nonatomic, assign) NSTimeInterval duration;

- (id)initWithDifficultyLevel:(int)dl;
- (NSString*)stringValue;

- (KodiakQuestionEvent*)kodiakEvent;

@end
