//
//  DLAutoTypeLabelBM.h
//  DSDialogBox
//
//  Created by Draco on 2013-09-04.
//  Copyright Draco Li 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class DLAutoTypeLabelBM;
@protocol DLAutoTypeLabelBMDelegate
@optional
- (void)autoTypeLabelBMTypingFinished:(DLAutoTypeLabelBM *)sender;
@end

@interface DLAutoTypeLabelBM : CCLabelBMFont
@property (nonatomic, weak) NSObject<DLAutoTypeLabelBMDelegate> *delegate;


/**
 * The delay between each word typed.
 *
 * Changing this while the label is being typed will speed up or slow down the 
 * current typing speed.
 */
@property (nonatomic) ccTime typingDelay;

/**
 * The string this label is about to type.
 */
@property (nonatomic, copy) NSString *autoTypeString;

/**
 * When called the current typing animation will stop and the label will display
 * whatever has been typed so far. Will trigger tying finished delegate method
 * 
 * This method does not do anything if our label is not currently typing.
 */
- (void)stopTypingAnimation;

/**
 * When called, the current typing animation will stop and the label will display
 * the full text that is meant to be typed immediately.
 */
- (void)finishTypingAnimation;

/**
 * Type in some text with a delay for every character typed
 */
- (void)typeText:(NSString*)txt withDelay:(ccTime)d;

@end
