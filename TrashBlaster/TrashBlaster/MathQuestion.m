//
//  MathQuestion.m
//  TrashBlaster
//
//  Created by Ben Gotow on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MathQuestion.h"

@implementation MathQuestion

@synthesize a,b,function,answer, studentAnswer, duration, difficulty;

- (id)initWithDifficultyLevel:(int)dl
{
    self = [super init];
    if (self){
        float r = (rand() % 1000) / 1000.0f;
        int operandMax = 4 + (dl % 5) * 5;
        
        a = rand() % operandMax + 1;
        b = rand() % operandMax + 1;
        
        if (dl < 5) {
            function = FUNCTION_ADD;
        } else if (dl < 10) { 
            if (r < 0.5)
                function = FUNCTION_ADD;
            else
                function = FUNCTION_SUBTRACT;
            
        } else if (dl < 15) { 
            function = FUNCTION_MULTIPLY;
            
        } else { 
            if (r < 0.5)
                function = FUNCTION_MULTIPLY;
            else
                function = FUNCTION_DIVIDE;
        } 
         
        if (function == FUNCTION_ADD)
            answer = a + b;
        else if (function == FUNCTION_SUBTRACT)
            answer = a - b;
        else if (function == FUNCTION_MULTIPLY)
            answer = a * b;
        else if (function == FUNCTION_DIVIDE)
            answer = a / b;
        difficulty = dl;
    }
    return self;
    
}

- (NSString*)stringValue
{
    if (function == FUNCTION_ADD)
        return [NSString stringWithFormat:@"%d + %d = ?", a, b];
    else if (function == FUNCTION_SUBTRACT)
        return [NSString stringWithFormat:@"%d - %d = ?", a, b];
    else if (function == FUNCTION_MULTIPLY)
        return [NSString stringWithFormat:@"%d x %d = ?", a, b];
    else if (function == FUNCTION_DIVIDE)
        return [NSString stringWithFormat:@"%d / %d = ?", a, b];
    else
        return @"Unknown";
}

- (KodiakQuestionEvent*)kodiakEvent
{
    NSString * answerString = [NSString stringWithFormat:@"%d", answer];
    NSString * studentAnswerString = [NSString stringWithFormat:@"%d", studentAnswer];
    
    KodiakQuestionEvent * e = [KodiakQuestionEvent eventForQuestion:[self stringValue] withCorrectAnswer:answerString withDifficulty:difficulty];
    [e setTimestamp: [NSDate date]];
    [e setSecondsTaken: duration];
    [e setStudentAnswerString: studentAnswerString];
    return e;
}


@end
