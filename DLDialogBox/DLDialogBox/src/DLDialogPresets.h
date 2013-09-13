//
//  DLDialogBoxPresets.h
//  DLDialogBox
//
//  Created by Draco on 2013-09-11.
//  Copyright (c) 2013 Draco Li. All rights reserved.
//

#import "DLDialogBox.h"

typedef enum {
  kDialogBoxCustomizerWithAnimations = 0,
  kDialogBoxCustomizerWithFancyUI,
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

+ (DLDialogBoxCustomizer *)dialogCustomizerOfType:(DialogBoxPreset)type;


+ (DLDialogBoxCustomizer *)sharedCustomizer;
+ (void)setSharedCustomizer:(DLDialogBoxCustomizer *)customizer;

@end
