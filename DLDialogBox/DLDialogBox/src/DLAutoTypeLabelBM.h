//
//  DLAutoTypeLabelBM.h
//  DSDialogBox
//
//  Created by Draco on 2013-09-04.
//  Copyright Draco Li 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define kTypingSpeedSuperMegaFast 450
#define kTypingSpeedSuperFast     200
#define kTypingSpeedFast          100
#define kTypingSpeedNormal        60
#define kTypingSpeedSlow          35

@class DLAutoTypeLabelBM;
@protocol DLAutoTypeLabelBMDelegate
@optional

/**
 * Called when typing animation for the string is finished.
 */
- (void)autoTypeLabelBMTypingFinished:(DLAutoTypeLabelBM *)sender;

/**
 * Called whenever a single character is typed;
 */
- (void)autoTypeLabelBMCharacterTyped:(DLAutoTypeLabelBM *)sender;

@end

/**
 * Strings displayed with this class will be animated as if its being typed.
 */
@interface DLAutoTypeLabelBM : CCLabelBMFont
@property (nonatomic, weak) NSObject<DLAutoTypeLabelBMDelegate> *delegate;


/**
 * Typing speed in terms of characters to be typed per second
 *
 * Since typingSpeed is evaluated after every typed character, changing this
 * while the label is being typed will speed up or slow down the current typing speed.
 *
 *
 * You can use our provided speed constants for differents speeds:
 * - `kTypingSpeedSuperMegaFast`
 * - `kTypingSpeedSuperFast`
 * - `kTypingSpeedFast`
 * - `kTypingSpeedNormal`
 * - `kTypingSpeedSlow`
 */
@property (nonatomic) CGFloat typingSpeed;

/**
 * The string this label is about to type.
 */
@property (nonatomic, copy) NSString *autoTypeString;

/**
 * Returns YES if text is currently being typed.
 */
@property (nonatomic, readonly) BOOL currentlyTyping;

/**
 * When called the current typing animation will stop and the label will display
 * whatever has been typed so far. This will not trigger typing finished delegate method.
 * 
 * This method does not do anything if our label is not currently typing.
 */
- (void)stopTypingAnimation;

/**
 * When called, the current typing animation will stop and the label will display
 * the full text that is meant to be typed immediately.
 *
 * If <currentlyTyping> is NO then this method would not inform the delegate but
 * will make sure that the displayed text is the final text to display.
 */
- (void)finishTypingAnimation;

/**
 * Type in some text with a delay for every character typed.
 */
- (void)typeText:(NSString*)txt typingSpeed:(CGFloat)speed;

@end
