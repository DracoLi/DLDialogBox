//
//  DLDialogBoxPresets.h
//  DLDialogBox
//
//  Created by Draco on 2013-09-11.
//  Copyright (c) 2013 Draco Li. All rights reserved.
//

#import "DLDialogBox.h"

typedef enum {
  
  //// Animations
  
  // Animates only outside portrait - slides in
  kDialogBoxWithOutsidePortraitSlideAnimation = 0,
  
  // Animate only outside portrait - fade and slide in
  kDialogBoxWithOutsidePortraitFadeAndSlideAnimation,
  
  // Animate everything with fade and slide assuming dialog is placed on bottom
  kDialogBoxWithFadeAndSlideAnimationAssumingOnScreenBottom,
  
  // Animate everything with fade and slide assuming dialog is placed on top
  kDialogBoxWithFadeAndSlideAnimationAssumingOnScreenTop,
  
  
  //// UI Customizations
  
  kDialogBoxCustomizerWithFancyUI,
  kDialogBoxCustomizerWithModernUI,
  kDialogBoxCustomizerWithWhiteUI,
  
  
  //// All-in-one
  
  kDialogBoxCustomizerDracoSpecial
  
} DialogBoxPreset;


/**
 * Use this class to get access to some awesome DLDialogBox customizers made by Draco.
 * See README for screenshots of some of these presets.
 *
 * You can also use this class to manage your own single <DLDialogBoxCusotmizer>
 * that you can use on all your dialogs to make sure that they all follow a
 * consistent theme.
 *
 * From example:
 *     // Do a bunch 
 *
 */
@interface DLDialogPresets : NSObject

/**
 * Returns one of my <DLDialogBoxCustomizer> presets.
 *
 * Available Presets:
 *
 * - kDialogBoxCustomizerWithBasicAnimations
 * - kDialogBoxCustomizerWithFancyUI
 */
+ (DLDialogBoxCustomizer *)dialogCustomizerOfType:(DialogBoxPreset)type;

/**
 *
 */
+ (DLDialogBoxCustomizer *)dialogCustomizerOfType:(DialogBoxPreset)type
                               withBaseCustomizer:(DLDialogBoxCustomizer *)baseCusomizer;

/**
 * Get the shared customizer set by <setSharedCustomizer>.
 *
 * @see setSharedCustomizer
 */
+ (DLDialogBoxCustomizer *)sharedCustomizer;

/**
 * Sets the shared customizer that you can get easily throughout your app 
 * via <sharedCustomizer>.
 *
 * @see sharedCustomizer
 */
+ (void)setSharedCustomizer:(DLDialogBoxCustomizer *)customizer;

@end
