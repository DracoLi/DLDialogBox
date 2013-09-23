//
//  DLDialogBoxPresets.h
//  DLDialogBox
//
//  Created by Draco on 2013-09-11.
//  Copyright (c) 2013 Draco Li. All rights reserved.
//

#import "DLDialogBox.h"

/**
 * Available presets that you can use for [DLDialogPresets customizeDialogWithPresets:baseCustomizer:].
 *
 * You can use multiple presets to customize your dialog box customizer.
 *
 * @see [DLDialogPresets customizeDialogWithPresets:baseCustomizer:]
 */
typedef NS_ENUM(NSInteger, DialogBoxCustomizerPreset) {
  
  
  /// @name Animations
  
  /**
   * Animates only outside portrait - slides in.
   */
  kCustomizerWithOutsidePortraitSlideAnimation = 0,
  
  /**
   * Animate only outside portrait - fade and slide in.
   */
  kCustomizerWithOutsidePortraitFadeAndSlideAnimation,
  
  /**
   * Animate everything with fade and top to bottom slide.
   */
  kCustomizerWithFadeAndSlideAnimationFromTop,
  
  /**
   * Animate everything with fade and slide assuming dialog is placed on top.
   */
  kCustomizerWithFadeAndSlideAnimationFromBottom,
  
  
  /// @name Positions
  
  /**
   * Position the dialog on top of the screen.
   */
  kCustomizerWithDialogOnTop,
  
  /**
   * Position the dialog on bottom of the screen.
   */
  kCustomizerWithDialogOnBottom,
  
  /**
   * Position the dialog in the middle of the screen.
   */
  kCustomizerWithDialogInMiddle,
  
  /**
   * Position the dialog by the left side of the screen.
   */
  kCustomizerWithDialogLeftAligned,
  
  /**
   * Position the dialog by the right side of the screen.
   */
  kCustomizerWithDialogRightAligned,
  
  /**
   * Position the dialog by in the middle horizontally.
   */
  kCustomizerWithDialogCenterAligned,
  
  
  /// @name UI Customizations
  
  /**
   * A super fancy UI made for the queen.
   */
  kCustomizerWithFancyUI,
  
  /**
   * A super white UI that will make you feel dirty.
   */
  kCustomizerWithWhiteUI,
  
  /**
   * A ugly eight bit UI from the past.
   */
  kCustomizerWithEightBitUI,
  
  
  /// @name Sounds
  
  /**
   * Retro sounds for the win.
   */
  kCustomizerWithRetroSounds
  
};


/**
 * Use this class to get access to some awesome DLDialogBox customizations
 * premade by Draco.
 *
 * See README for screenshots of some of these presets.
 *
 * ---
 *
 * To use the presets, you first need to get a basic customizer.
 *
 * ```
 *  DLDialogBoxCustomizer *customizer = [DLDialogBoxCustomizer defaultCustomizer];
 * ```
 *
 * Then you call `customizeDialogWithPresets` with an array of presets that
 * you want to apply to your customizer. The order of the presets matters since
 * some presets may use an existing property on the customizer.
 *
 * Usage Example:
 *
 * ```
 * DLDialogBoxCustomizer *customizer = [DLDialogBoxCustomizer defaultCustomizer];
 *
 * // Customize the customizer before going through our default presets
 * customizer.dialogSize = ccp(300, 200);
 * customizer.portraitInsideDialog = YES;
 *
 * // Apply some presets
 * customizer = [DLDialogPresets customizeDialogWithPresets:
 *                  @[@(kCustomizerWithDialogOnBottom),
 *                  @(kCustomizerWithDialogCenterAligned),
 *                  @(kCustomizerWithFadeAndSlideAnimationFromBottom),
 *                  @(kCustomizerWithEightBitUI)] baseCustomizer:customizer];
 * ```
 *
 * ---
 *
 * You can also use this class to manage your own single <DLDialogBoxCusotmizer>
 * instance that you can use on all your dialogs to make sure that they all
 * follow a consistent theme.
 *
 * From example:
 *
 * ```
 *     // Create a basic customizer
 *     DLDialogBoxCustomizer *customizer = [DLDialogBoxCustomizer defaultCustomizer];
 *     
 *     // Customize the customizer
 *     // ...
 *
 *     // Set it as the default customizer
 *     [DLDialogPresets setSharedCustomizer:customizer];
 *
 *     // Get the default customizer
 *     [DLDialogPresets sharedCustomizer]
 * ```
 */
@interface DLDialogPresets : NSObject

/**
 * Returns a <DLDialogBoxCustomizer> with the specified presets applied in order.
 *
 * Refer to <DLDialogPresets> for available presets.
 *
 * @param presets     An array of presets. The constants need to be wrapped in NSNumber.
 * @param customizer  The base customizer
 */
+ (DLDialogBoxCustomizer *)customizeDialogWithPresets:(NSArray *)presets
                                       baseCustomizer:(DLDialogBoxCustomizer *)customizer;

/**
 * Returns a <DLDialogBoxCustomizer> with the specified preset applied in order.
 *
 * @param preset      A preset constant wrapped in NSNumber.
 * @param customizer  The base customizer
 */
+ (DLDialogBoxCustomizer *)customizeDialogWithPreset:(DialogBoxCustomizerPreset)preset
                                   baseCustomizer:(DLDialogBoxCustomizer *)customizer;

/**
 * Get the shared customizer set by <setSharedCustomizer:>.
 *
 * @see setSharedCustomizer:
 */
+ (DLDialogBoxCustomizer *)sharedCustomizer;

/**
 * Sets the shared customizer that you can get easily throughout your app 
 * via <sharedCustomizer>.
 *
 * @see sharedCustomizer
 * @param customizer The customizer to set as default
 */
+ (void)setSharedCustomizer:(DLDialogBoxCustomizer *)customizer;

/**
 * Adds the resources used by <DLDialogPresets> into the shared `CCSpriteFrameCache`.
 *
 * After this is called, you will be able to use the resources attached
 * with the DLDialogBox project via `[CCSprite spriteWithSpriteFrameName]`.
 */
+ (void)addDLDialogBoxPresetResources;

@end
