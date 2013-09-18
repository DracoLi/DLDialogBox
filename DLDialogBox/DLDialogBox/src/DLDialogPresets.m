//
//  DLDialogBoxPresets.m
//  DLDialogBox
//
//  Created by Draco on 2013-09-11.
//  Copyright (c) 2013 Draco Li. All rights reserved.
//

#import "DLDialogPresets.h"

@interface DLDialogPresets ()
@property (nonatomic, strong) DLDialogBoxCustomizer *dialogCustomizer;

+ (DLDialogPresets *)sharedInstance;

// Customizer presets
+ (DLDialogBoxCustomizer *)customizerWithBasicAnimation;
+ (DLDialogBoxCustomizer *)customizerWithFancyUI;
@end

@implementation DLDialogPresets

+ (DLDialogBoxCustomizer *)dialogCustomizerOfType:(DialogBoxPreset)type
{
  DLDialogBoxCustomizer *customizer = nil;
  
  switch (type) {
    case kDialogBoxCustomizerWithBasicAnimations:
      customizer = [self customizerWithBasicAnimation];
      break;
    case kDialogBoxCustomizerWithFancyUI:
      customizer = [self customizerWithFancyUI];
      break;
    default:
      break;
  }
  
  return customizer;
}

+ (DLDialogBoxCustomizer *)sharedCustomizer
{
  return [[self sharedInstance] dialogCustomizer];
}

+ (void)setSharedCustomizer:(DLDialogBoxCustomizer *)customizer
{
  [[self sharedInstance] setDialogCustomizer:customizer];
}


#pragma mark - Private methods

+ (DLDialogPresets *)sharedInstance
{
  static DLDialogPresets *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[DLDialogPresets alloc] init];
  });
  return instance;
}


#pragma mark - Customizer Presets

+ (DLDialogBoxCustomizer *)customizerWithBasicAnimation
{
  DLDialogBoxCustomizer *customizer = [DLDialogBoxCustomizer defaultCustomizer];
  
  // Add custom on enter animation
  customizer.showAnimation = [DLDialogBoxCustomizer
                              customShowAnimationWithSlideDistance:50
                              fadeIn:YES duration:0.4];
  
  // Add custom on exist animation
  customizer.hideAnimation = [DLDialogBoxCustomizer
                              customHideAnimationWithSlideDistance:50
                              fadeOut:YES duration:0.28];

  return customizer;
}

+ (DLDialogBoxCustomizer *)customizerWithFancyUI
{
  DLDialogBoxCustomizer *customizer = [DLDialogBoxCustomizer defaultCustomizer];
  
  return customizer;
}

@end
