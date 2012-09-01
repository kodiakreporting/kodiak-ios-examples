//
//  TrashItem.h
//  TrashBlaster
//
//  Created by Ben Gotow on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseItem.h"

@interface TrashItem : BaseItem
{
    int image;
    int value;
    
    UIButton * trash;
    UILabel * valueLabel;
    UIImageView * explosion;
    
    BOOL exploding;
    int explosionFrameNumber;
        
    int redTime;
}

@property (nonatomic, assign) int value;
@property (nonatomic, assign) BOOL exploding;
@property (nonatomic, assign) int redTime;


- (id)initWithValue:(int)v;
- (UIImage*)trashImageAtIndex:(int)ii;
- (void)buttonTapped;
- (void)update;

@end
