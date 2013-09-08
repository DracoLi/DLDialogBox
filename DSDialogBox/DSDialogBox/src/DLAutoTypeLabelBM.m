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
@property (nonatomic, copy) NSString *adjustedTypedString;

- (void)typingFinished;
- (void)typeWordAtIndex:(int)index;
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
  [self setString:self.autoTypeString];
  [self stopTypingAnimation];
}

- (void)typeText:(NSString*)txt withDelay:(ccTime)d
{
  // Stop any existing typing animations
  [self stopTypingAnimation];
  
  // Construct our strings data
  self.arrayOfCharacters = [[NSMutableArray alloc] init];
  self.autoTypeString = [[NSString alloc] initWithString:txt];
  NSUInteger newlineCount = 0;
  for (int j=1; j < [txt length]+1; ++j) {
    NSString *substring = [txt substringToIndex:j];
    if ([substring characterAtIndex:substring.length - 1] == '\n') {
      newlineCount++;
    }
    [_arrayOfCharacters addObject:substring];
  }
  
  /**
   * This is to fix the bug where CCLabelBMFont will not type the trailling characters
   * if \n is present within the text.
   *
   * Thus if there are 3 \n in the text, then CCLabelBMFont will not type the last
   * 3 characters.
   *
   * This is pretty dumb so this is a hack to fix this by appending some whitespace
   * at the end of the to our typed string so we can type all the characters we were
   * supposed to. 
   *
   * Typing animation would not take longer though since we are adding the same 
   * number of whitespaces to the end of the string as there are newlines,
   * the animation will look just like that we are typing character by character.
   */
  for (int i = 0; i < newlineCount; i++) {
    NSString *lastString = [_arrayOfCharacters lastObject];
    NSString *newString = [lastString stringByAppendingString:@" "];
    [_arrayOfCharacters addObject:newString];
  }
  
  self.adjustedTypedString = [_arrayOfCharacters lastObject];
  
  // This starts our recursive typing animation
  // We are doing this recursively so that we can change the typing speed
  // while the words are being typed out if we want.
  self.typingDelay = d;
  [self typeWordAtIndex:0];
}

- (void)typeWordAtIndex:(int)index
{
  // Finish all typing when we are at end of typing index
  if (index == [self.arrayOfCharacters count]) {
    [self setString:self.adjustedTypedString];
    [self typingFinished];
    return;
  }
  
  // Sets string to our current word index
  NSString *string = [_arrayOfCharacters objectAtIndex:index];
  [self setString:string];
  
  // Wait and type next letter after a delay
  __weak DLAutoTypeLabelBM *weakSelf = self;
  id recurseBlock = [CCCallBlock actionWithBlock:^() {
    [weakSelf typeWordAtIndex:index + 1];
  }];
  [self runAction:[CCSequence actions:
                   [CCDelayTime actionWithDuration:self.typingDelay], recurseBlock, nil]];
}

- (void)typingFinished
{
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(autoTypeLabelBMTypingFinished:)]) {
    [self.delegate autoTypeLabelBMTypingFinished:self];
  }
}

- (void)dealloc {
  self.delegate = nil;
}


@end
