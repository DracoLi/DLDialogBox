//
//  DLDialogBoxPresets.m
//  DLDialogBox
//
//  Created by Draco on 2013-09-11.
//  Copyright (c) 2013 Draco Li. All rights reserved.
//

#import "DLDialogPresets.h"

@implementation DLDialogPresets

+ (DLDialogBoxCustomizer *)dialogCustomizerOfType:(DialogBoxPreset)type
{
  DLDialogBoxCustomizer *customizer = [DLDialogBoxCustomizer defaultCustomizer];
  
  if (type == kDialogBoxCustomizerWithAnimations) {
    customizer.onEnterDialogAnimation = ^(DLDialogBox *dialog) {
      
    };
  }
}

@end
