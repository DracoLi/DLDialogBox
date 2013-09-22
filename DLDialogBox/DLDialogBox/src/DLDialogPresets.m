//
//  DLDialogBoxPresets.m
//  DLDialogBox
//
//  Created by Draco on 2013-09-11.
//  Copyright (c) 2013 Draco Li. All rights reserved.
//

#import "DLDialogPresets.h"

#define kDefaultShowAnimationSpeed 0.4
#define kDefaultHideAnimationSpeed 0.3


@interface DLDialogPresets ()
@property (nonatomic, strong) DLDialogBoxCustomizer *dialogCustomizer;

+ (DLDialogPresets *)sharedInstance;

// Preset helpers
+ (DLDialogBoxCustomizer *)addHandIndicatorWithCustomAnimation:(DLDialogBoxCustomizer *)baseCustomizer;
+ (DLDialogBoxCustomizer *)onlyOutsidePortraitAnimation:(DLDialogBoxCustomizer *)customizer
                                                   fade:(BOOL)fade
                                           showDuration:(ccTime)showDuration
                                           hideDuration:(ccTime)hideDuration;
@end

@implementation DLDialogPresets


#pragma mark - Public methods

+ (DLDialogBoxCustomizer *)dialogCustomizerOfType:(DialogBoxCustomizerPreset)type
{
  DLDialogBoxCustomizer *customizer = [DLDialogBoxCustomizer defaultCustomizer];
  return [self dialogCustomizerOfType:type withBaseCustomizer:customizer];
}


+ (DLDialogBoxCustomizer *)dialogCustomizerOfTypes:(NSArray *)types
{
  return [self dialogCustomizerOfTypes:types
                    withBaseCustomizer:[DLDialogBoxCustomizer defaultCustomizer]];
}

+ (DLDialogBoxCustomizer *)dialogCustomizerOfTypes:(NSArray *)types
                                withBaseCustomizer:(DLDialogBoxCustomizer *)customizer
{
  for (NSNumber *type in types) {
    customizer = [self dialogCustomizerOfType:[type intValue] withBaseCustomizer:customizer];
  }
  return customizer;
}


+ (DLDialogBoxCustomizer *)dialogCustomizerOfType:(DialogBoxCustomizerPreset)type
                               withBaseCustomizer:(DLDialogBoxCustomizer *)customizer
{
  /// Animations
  
  // Animation with only the outside portrait - only slides it in
  if (type == kCustomizerWithOutsidePortraitSlideAnimation)
  {
    customizer = [self onlyOutsidePortraitAnimation:customizer
                                               fade:NO
                                       showDuration:kDefaultShowAnimationSpeed
                                       hideDuration:kDefaultHideAnimationSpeed];
  }
  
  // Animation with only the outside portrait - slides and fades it in
  else if (type == kCustomizerWithOutsidePortraitFadeAndSlideAnimation)
  {
    customizer = [self onlyOutsidePortraitAnimation:customizer
                                               fade:YES
                                       showDuration:0.4 hideDuration:0.3];
  }
  
  // Custom animation for the whole package - Dialog content, port, and choice dialog!
  else if (type == kCustomizerWithFadeAndSlideAnimationFromBottom)
  {
    CGFloat slideDistance = customizer.dialogSize.height / 2;
    customizer.showAnimation = [DLDialogBoxCustomizer
                                customShowAnimationWithSlideDistance:slideDistance
                                fadeIn:YES duration:kDefaultShowAnimationSpeed];
    customizer.hideAnimation = [DLDialogBoxCustomizer
                                customHideAnimationWithSlideDistance:slideDistance
                                fadeOut:YES duration:kDefaultHideAnimationSpeed];
  }
  else if (type == kCustomizerWithFadeAndSlideAnimationFromTop)
  {
    CGFloat slideDistance = customizer.dialogSize.height / 2 * -1;
    customizer.showAnimation = [DLDialogBoxCustomizer
                                customShowAnimationWithSlideDistance:slideDistance
                                fadeIn:YES duration:kDefaultShowAnimationSpeed];
    customizer.hideAnimation = [DLDialogBoxCustomizer
                                customHideAnimationWithSlideDistance:slideDistance
                                fadeOut:YES duration:kDefaultHideAnimationSpeed];
  }
  
  
  //// Positions
  
  else if (type == kCustomizerWithDialogOnTop)
  {
    CGPoint anchor = customizer.dialogAnchorPoint;
    CGPoint oriPosition = customizer.dialogPosition;
    CGFloat newY = [[CCDirector sharedDirector] winSize].height + \
                   (anchor.y - 1) * customizer.dialogSize.height;
    customizer.dialogPosition = ccp(oriPosition.x, newY);
  }
  
  else if (type == kCustomizerWithDialogOnBottom)
  {
    CGPoint anchor = customizer.dialogAnchorPoint;
    CGPoint oriPosition = customizer.dialogPosition;
    CGFloat newY = anchor.y * customizer.dialogSize.height;
    customizer.dialogPosition = ccp(oriPosition.x, newY);
  }
  
  else if (type == kCustomizerWithDialogInMiddle)
  {
    CGPoint anchor = customizer.dialogAnchorPoint;
    CGPoint oriPosition = customizer.dialogPosition;
    CGFloat newY = ([[CCDirector sharedDirector] winSize].height - customizer.dialogSize.height) / 2.0 \
                    + anchor.y * customizer.dialogSize.height;
    customizer.dialogPosition = ccp(oriPosition.x, newY);
  }
  
  else if (type == kCustomizerWithDialogCenterAligned)
  {
    CGPoint anchor = customizer.dialogAnchorPoint;
    CGPoint oriPosition = customizer.dialogPosition;
    CGFloat newX = ([[CCDirector sharedDirector] winSize].width - customizer.dialogSize.width) / 2.0 \
                   + anchor.x * customizer.dialogSize.width;
    customizer.dialogPosition = ccp(newX, oriPosition.y);
  }
  
  else if (type == kCustomizerWithDialogLeftAligned)
  {
    CGPoint anchor = customizer.dialogAnchorPoint;
    CGPoint oriPosition = customizer.dialogPosition;
    CGFloat newX = anchor.x * customizer.dialogSize.width;
    customizer.dialogPosition = ccp(newX, oriPosition.y);
  }
  
  else if (type == kCustomizerWithDialogRightAligned)
  {
    CGPoint anchor = customizer.dialogAnchorPoint;
    CGPoint oriPosition = customizer.dialogPosition;
    CGFloat newX = [[CCDirector sharedDirector] winSize].width + \
                   (anchor.x - 1) * customizer.dialogSize.width;
    customizer.dialogPosition = ccp(newX, oriPosition.y);
  }
  
  
  //// UI Customizations
  
  // Make the dialog look fancy!
  else if (type == kCustomizerWithFancyUI)
  {
    [self addDLDialogBoxPresetResources];
    
    // Custom border and font
    customizer.backgroundSpriteFrameName = @"fancy_border.png";
    customizer = [self addHandIndicatorWithCustomAnimation:customizer];
    if (customizer.portraitInsideDialog) {
      customizer.portraitInsets = UIEdgeInsetsMake(8, 8, 8, customizer.portraitInsets.right);
      customizer.dialogTextInsets = UIEdgeInsetsMake(15,
                                                     customizer.dialogTextInsets.left,
                                                     15,
                                                     customizer.dialogTextInsets.right);
    }else {
      customizer.dialogTextInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    }
    
    // Custom choice dialog
    DLChoiceDialogCustomizer *choiceCustomizer = customizer.choiceDialogCustomizer;
    choiceCustomizer.backgroundSpriteFrameName = @"fancy_border.png";
    choiceCustomizer.labelCustomizer.preSelectedBackgroundColor = ccc4(119, 86, 26, 255);
    choiceCustomizer.contentInsets = UIEdgeInsetsMake(15, 8, 15, 7);
  }
  
  // Make the dialog look clean with a nice white!
  else if (type == kCustomizerWithWhiteUI)
  {
    [self addDLDialogBoxPresetResources];
    
    ccColor4B bgColor = ccc4(232, 228, 215, 255);
    NSString *fntFile = @"gill-sans-17.fnt";
    
    // Custom border and font
    customizer.backgroundColor = bgColor;
    customizer.fntFile = fntFile;
    customizer.pageFinishedIndicator = [CCSprite spriteWithSpriteFrameName:@"arrow_cursor_black.png"];
    
    // Custom choice dialog
    DLChoiceDialogCustomizer *choiceCustomizer = customizer.choiceDialogCustomizer;
    choiceCustomizer.backgroundColor = bgColor;
    choiceCustomizer.fntFile = fntFile;
    choiceCustomizer.labelCustomizer.preSelectedBackgroundColor = ccc4(181, 165, 91, 255);
    choiceCustomizer.labelCustomizer.selectedBackgroundColor = ccc4(246, 167, 97, 255);
  }
  
  else if (type == kCustomizerWithEightBitUI)
  {
    [self addDLDialogBoxPresetResources];
    NSString *bg = @"plain_border.png";
    NSString *fnt = @"start-16.fnt";

    // Custom border and font
    customizer.backgroundSpriteFrameName = bg;
    customizer.fntFile = fnt;
    customizer.choiceDialogCustomizer.fntFile = fnt;
    
    if (customizer.portraitInsideDialog) {
      customizer.portraitInsets = UIEdgeInsetsMake(5, 5, 5, customizer.portraitInsets.right);
    }
    customizer.dialogTextInsets = UIEdgeInsetsMake(15, 10, 15, 10);
    
    // Custom choice dialog
    DLChoiceDialogCustomizer *choiceCustomizer = customizer.choiceDialogCustomizer;
    choiceCustomizer.backgroundSpriteFrameName = bg;
    choiceCustomizer.contentInsets = UIEdgeInsetsMake(10, 5, 10, 5);
    choiceCustomizer.labelCustomizer.textInsets = UIEdgeInsetsMake(9, 10, 5, 10);
  }
  
  
  //// Sounds
  
  else if (type == kCustomizerWithRetroSounds)
  {
    customizer.textPageStartedSoundFileName = @"text_page.wav";
    customizer.choiceDialogCustomizer.preselectSoundFileName = @"preselected.wav";
    customizer.choiceDialogCustomizer.selectedSoundFileName = @"selected.wav";
  }
  
  
  //// All-in-one
  
  else if (type == kCustomizerDracoSpecial)
  {
    
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


+ (void)addDLDialogBoxPresetResources
{
  NSString *fileName = @"dldialogbox_preset_resources.plist";
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:fileName];
}

#pragma mark - Preset Helpers

+ (DLDialogBoxCustomizer *)onlyOutsidePortraitAnimation:(DLDialogBoxCustomizer *)customizer
                                                   fade:(BOOL)fade
                                           showDuration:(ccTime)showDuration
                                           hideDuration:(ccTime)hideDuration
{
  customizer.showAnimation = ^(DLDialogBox *dialog) {
    [dialog animateOutsidePortraitInWithFadeIn:fade
                                      distance:dialog.portrait.contentSize.width
                                      duration:showDuration];
  };
  customizer.hideAnimation = ^(DLDialogBox *dialog) {
    [dialog animateOutsidePortraitOutWithFadeOut:fade
                                        distance:dialog.portrait.contentSize.width
                                        duration:hideDuration];
  };
  return customizer;
}

+ (DLDialogBoxCustomizer *)addHandIndicatorWithCustomAnimation:(DLDialogBoxCustomizer *)baseCustomizer
{
  baseCustomizer.pageFinishedIndicator = [CCSprite spriteWithSpriteFrameName:@"hand_indicator.png"];
  baseCustomizer.pageFinishedIndicatorAnimation = ^(DLDialogBox *dialog) {
    CCSprite *indicator = dialog.customizer.pageFinishedIndicator;
    indicator.position = ccpSub(indicator.position, CGPointMake(0, 1));
    id moveBack = [CCMoveBy actionWithDuration:0.2 position:CGPointMake(0, 5)];
    id moveReverse = [moveBack reverse];
    [indicator runAction:[CCRepeatForever actionWithAction:
                          [CCSequence actions:moveBack, moveReverse, nil]]];
  };
  return baseCustomizer;
}

@end
