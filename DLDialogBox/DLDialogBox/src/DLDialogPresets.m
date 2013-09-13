//
//  DLDialogBoxPresets.m
//  DLDialogBox
//
//  Created by Draco on 2013-09-11.
//  Copyright (c) 2013 Draco Li. All rights reserved.
//

#import "DLDialogPresets.h"

#define kPortraitMoveAnimationDuration 0.3
#define kPortraitMoveAnimationEaseRate 0.5
#define kPortraitFadeAnimationDuration 0.2

@interface DLDialogPresets ()
@property (nonatomic, strong) DLDialogPresets *preset;
@property (nonatomic, strong) DLDialogBoxCustomizer *dialogCustomizer;

+ (DLDialogPresets *)sharedInstance;
@end

@implementation DLDialogPresets

+ (DLDialogBoxCustomizer *)dialogCustomizerOfType:(DialogBoxPreset)type
{
  DLDialogBoxCustomizer *customizer = [DLDialogBoxCustomizer defaultCustomizer];
  
  if (type == kDialogBoxCustomizerWithBasicAnimations)
  {
    // Add custom on enter animation
    customizer.onEnterDialogAnimation = ^(DLDialogBox *dialog) {
      
      // Animate portrait in
      if (dialog.defaultPortraitSprite && !dialog.customizer.portraitInsideDialog)
      {
        CGPoint finalPos = dialog.portrait.position;
        
        // Calculate initial position
        CGPoint startingPos = CGPointZero;
        CGSize portraitSize = dialog.portrait.contentSize;
        if (dialog.customizer.portraitPosition == kDialogPortraitPositionLeft) {
          startingPos = ccpSub(finalPos, CGPointMake(portraitSize.width / 4, 0));
        }else {
          startingPos = ccpAdd(finalPos, CGPointMake(portraitSize.width / 4, 0));
        }
        
        // Animate move and fade in
        dialog.portrait.position = startingPos;
        id move = [CCMoveTo actionWithDuration:kPortraitMoveAnimationDuration
                                      position:finalPos];
        //    id moveEaseOut = [CCEaseOut actionWithAction:move
        //                                            rate:kPortraitMoveAnimationEaseRate];D
        id fadeIn = [CCFadeIn actionWithDuration:kPortraitFadeAnimationDuration];
        [dialog.portrait runAction:[CCSpawn actions:move, fadeIn, nil]];
      }
      
      // Animate dialog content in
      CGPoint finalPos = dialog.dialogContent.position;
      CGPoint startPos = ccpSub(finalPos, CGPointMake(0, -30));
      dialog.dialogContent.position = startPos;
      id fadeIn = [CCFadeIn actionWithDuration:kPortraitFadeAnimationDuration];
      id move = [CCMoveTo actionWithDuration:kPortraitMoveAnimationDuration
                                    position:finalPos];
      [dialog.dialogContent runAction:[CCSpawn actions:move, fadeIn, nil]];
    };
    
    // Add custom on exist animatino
    customizer.onExitDialogAnimation = ^(DLDialogBox *dialog) {
      
      // Animate portrait out
      if (dialog.defaultPortraitSprite && !dialog.customizer.portraitInsideDialog)
      {
        // Calculate final position
        CGPoint finalPos = CGPointZero;
        CGPoint startPos = dialog.portrait.position;
        CGSize portraitSize = dialog.portrait.contentSize;
        if (dialog.customizer.portraitPosition == kDialogPortraitPositionLeft) {
          finalPos = ccpSub(startPos, CGPointMake(portraitSize.width / 4, 0));
        }else {
          finalPos = ccpAdd(startPos, CGPointMake(portraitSize.width / 4, 0));
        }
        
        // Animate move and fade in
        dialog.portrait.position = finalPos;
        id move = [CCMoveTo actionWithDuration:kPortraitMoveAnimationDuration
                                      position:finalPos];
        id fadeOut = [CCFadeOut actionWithDuration:kPortraitFadeAnimationDuration];
        [dialog.portrait runAction:[CCSpawn actions:move, fadeOut, nil]];
      }
      
      // Animate dialog content out
      CGPoint startPos = dialog.dialogContent.position;
      CGPoint finalPos = ccpAdd(startPos, CGPointMake(0, 30));
      id fadeOut = [CCFadeOut actionWithDuration:kPortraitFadeAnimationDuration];
      id move = [CCMoveTo actionWithDuration:kPortraitMoveAnimationDuration
                                    position:finalPos];
      [dialog.dialogContent runAction:[CCSpawn actions:move, fadeOut, nil]];
    };
  }
  else if (type == kDialogBoxCustomizerWithFancyUI)
  {
    
  }
  
  return customizer;
}

+ (DLDialogPresets *)sharedInstance
{
  static DLDialogPresets *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[DLDialogPresets alloc] init];
  });
  return instance;
}

+ (DLDialogBoxCustomizer *)sharedCustomizer
{
  return [[self sharedInstance] dialogCustomizer];
}

+ (void)setSharedCustomizer:(DLDialogBoxCustomizer *)customizer
{
  [[self sharedInstance] setDialogCustomizer:customizer];
}

@end
