//
//  CRCountdown.m
//  roaa
//
//  Created by mac on 2019-10-07.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "CRCountdown.h"

@interface CRCountdown()

@property NSTimer *timer;
@property NSTimer *updateTimer;
@property (readwrite) NSTimeInterval interval;
@property (copy) CRCountdownCompletion completion;
@property (copy) CRCountdownUpdate update;

@end

@implementation CRCountdown

- (void)startCountdownWithInterval:(NSTimeInterval)interval ticks:(NSUInteger)ticks completion:(CRCountdownCompletion)completion update:(CRCountdownUpdate)update {
  self.completion = completion;
  self.update = update;
  self.interval = interval;
  self.timer = [NSTimer scheduledTimerWithTimeInterval:(interval * ticks) target:self selector:@selector(countdownComplete:) userInfo:nil repeats:NO];
  if (self.update) {
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(countdownUpdate:) userInfo:nil repeats:YES];
  }
}

- (void)stopCountdown {
  [self.updateTimer invalidate];
  [self.timer invalidate];
}

- (NSUInteger)ticksRemaining {
  if (self.timer.isValid) {
    NSTimeInterval timeRemaining = [self.timer.fireDate timeIntervalSinceDate:[NSDate date]];
    return timeRemaining / self.interval;
  } else {
    return 0;
  }
}

- (void)countdownUpdate:(NSTimer *)timer {
  if (self.update) {
    self.update(self.ticksRemaining);
    NSString *s = [NSString stringWithFormat:@"%lu", (unsigned long)self.ticksRemaining];
  }
}

- (void)countdownComplete:(NSTimer *)timer {
  [self.updateTimer invalidate];
  if (self.completion) {
    self.completion();
  }
  
  self.update = nil;
  self.completion = nil;
}

@end


