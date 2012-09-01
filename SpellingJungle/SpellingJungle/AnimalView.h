//
//  AnimalView.h
//  SpellingJungle
//
//  Created by Ben Gotow on 2/27/12.
//  Copyright (c) 2012 Kodiak Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface AnimalView : UIButton
{
    NSString * word;
}

- (void)setWord:(NSString *)w;
- (void)play;

@end
