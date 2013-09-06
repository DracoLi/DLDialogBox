//
//  DLAutoTypeLabelBM.m
//  DSDialogBox
//
//  Created by Draco on 2013-09-04.
//  Copyright Draco Li 2013. All rights reserved.
//

#import "DLAutoTypeLabelBM.h"

@interface DLAutoTypeLabelBM ()
@property (nonatomic, strong) NSMutableArray *arrayOfCharacters;
- (void)typingFinished;
@end

@implementation DLAutoTypeLabelBM

- (void)stopTypingAnimation
{
  if ([self numberOfRunningActions] > 0) {
    [self stopAllActions];
    [self unschedule:@selector(finishCheck:)];
    [self typingFinished];
  }
}

- (void)finishTypingAnimation
{
  [self stopTypingAnimation];
  [self setString:self.autoTypeString];
}

- (void)typeText:(NSString*)txt withDelay:(ccTime)d
{
  // Stop any existing typing animations
  [self stopTypingAnimation];
  
  // Construct our strings data
  self.arrayOfCharacters = [[NSMutableArray alloc] init];
  self.autoTypeString = [[NSString alloc] initWithString:txt];
  for (int j=1; j < [txt length]+1; ++j) {
    NSString *substring = [txt substringToIndex:j];
    [_arrayOfCharacters addObject:substring];
  }
  
  // This starts our recursive typing animation
  // We are doing this recursively so that we can change the typing speed
  // while the words are being typed out if we want.
  self.typingDelay = d;
  [self typeWordIndex:0];
  
  // Continously check if our typing animation is finished
  [self schedule:@selector(finishCheck:) interval:1.5];
}

- (void)typeWordIndex:(int)index
{
  // Finish all typing when we are at end of typing index
  if (index == [self.arrayOfCharacters count]) {
    return;
  }
  
  // Sets string to our current word index
  NSString *string = [_arrayOfCharacters objectAtIndex:index];
  [self setString:string];
  
  // Wait and type next letter after a delay
  __weak DLAutoTypeLabelBM *weakSelf = self;
  id recurseBlock = [CCCallBlock actionWithBlock:^() {
    [weakSelf typeWordIndex:index + 1];
  }];
  [self runAction:[CCSequence actions:
                   [CCDelayTime actionWithDuration:self.typingDelay], recurseBlock, nil]];
}

- (void)finishCheck:(ccTime)dt
{
  if ([self numberOfRunningActions] == 0) {
    [self unschedule:@selector(finishCheck:)];
    [self typingFinished];
  }
}

- (void)typingFinished
{
  if ([self.delegate respondsToSelector:@selector(autoTypeLabelBMTypingFinished:)]) {
    [self.delegate autoTypeLabelBMTypingFinished:self];
  }
}

- (void)dealloc {
//  self.delegate = nil;
}


@end
