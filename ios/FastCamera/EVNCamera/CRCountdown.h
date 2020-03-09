//
//  CRCountdown.h
//  roaa
//
//  Created by mac on 2019-10-07.
//  Copyright © 2019 Facebook. All rights reserved.
//

typedef void (^CRCountdownCompletion)(void);
typedef void (^CRCountdownUpdate)(NSUInteger);

@interface CRCountdown : NSObject

- (void)startCountdownWithInterval:(NSTimeInterval)interval ticks:(NSUInteger)ticks completion:(CRCountdownCompletion)completion update:(CRCountdownUpdate)update;
@property (readonly) NSUInteger ticksRemaining;
@property (readonly) NSTimeInterval interval;

@end
