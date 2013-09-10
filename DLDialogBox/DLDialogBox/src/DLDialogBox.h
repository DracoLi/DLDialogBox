//
//  DSChatBox.h
//  sunny
//
//  Created by Draco on 2013-09-01.
//  Copyright 2013 Draco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DLAutoTypeLabelBM.h"
#import "DLChoiceDialog.h"

#define kDialogHeightSmall  55
#define kDialogHeightNormal 90
#define kDialogHeightLarge  130

typedef enum {
  kDialogPortraitPositionLeft = 0,
  kDialogPortraitPositionRight
} DialogPortraitPosition;

/**
 * DLDialogBoxCustomizer Stores customization properties for how a <DLDialogBox> 
 * should be displayed.
 *
 * Each <DLDialogBox> must use a customizer, if no customizers are given the
 * dialog box will automatically use the default customizer provided through
 * <defaultCustomizer>.
 */
@interface DLDialogBoxCustomizer : NSObject

/**
 * The size of dialog box (not including the portrait if its outside).
 *
 * __Default is (current device width, kDialogHeightNormal)__
 *
 * The default dialog size will make a dialog what stretches accross the device
 * and can roughly accommodates 3 rows of text in landscape mode.
 *
 * Please note that DLDialogBox does not automatically scale the dialog's height
 * according to the content so you must make sure to set the <dialogSize> to a large
 * enough value so that the dialog box can accommodate all your text.
 * 
 * We provided some height constants for you to use:
 *
 * - `kDialogHeightSmall` accommodates about 1-2 lines of text
 * - `kDialogHeightNormal` accommodates about 3-4 lines of text and is the default height
 * - `kDialogHeightLarge` accommodates about 4-5 lines of text
 */
@property (nonatomic) CGSize dialogSize;

/**
 * The file name of a stretchable sprite image that will be used as
 * the background image for the dialog box.
 *
 * If the `backgroundSpriteFrameName` is also provided, then this value will be ignored.
 *
 * Please refer to the usage documentation on how the sprite image should be made.
 */
@property (nonatomic, copy) NSString *backgroundSpriteFile;

/**
 * The sprite frame name of a stretchable sprite image that will be used as
 * the background image for the dialog box.
 *
 * If a `backgroundSpriteFile` is also provided, then only this value will be used.
 *
 * Please refer to usage documentation on how the sprite image should be made.
 */
@property (nonatomic, copy) NSString *backgroundSpriteFrameName;

/**
 * If a sprite is not provided as the dialog's background, this property will be
 * used as the background color of the dialog box.
 *
 * You can create a `ccColor4B` via `ccc4(red, blue, green, alpha)`.
 * Note that all color values are from 0-255.
 *
 * __Defaults to a semi-transparent black color (`ccc4(0,0,0,204)`).__
 */
@property (nonatomic) ccColor4B backgroundColor;

/**
 * The sprite to be used by the dialog box after a page of text is displayed.
 *
 * Currently custom animation for this sprite is not supported.
 * By default this sprite will blink continously after the dialog texts are typed.
 *
 * Also by default DLDialogBox will position this sprite at the bottom right corner
 * using the same offset as the `dialogTextOffset` of this customizer.
 *
 * Override this sprite's position after setting the customizer on a DLDialogBox
 * to adjust the extact position of this indicator sprite.
 *
 * __By default `defaultCustomizer` sets this sprite to an arrow cursor sprite
 * attached with the project.__
 */
@property (nonatomic, strong) CCSprite *pageFinishedIndicator;

/**
 * The speed per blink for the page finished indicator sprite.
 *
 * Higher value means it will take longer per blink.
 *
 * Example: 0.5 will result in a blink every half second.
 *
 * __Default is 1.0 for 1 second per blink.__
 */
@property (nonatomic) ccTime speedPerPageFinishedIndicatorBlink;

/**
 * The offset between the dialog text and the top left edge of the dialog box.
 *
 * If the dialog box has an inner portrait on the left side of the dialog,
 * then this offset corresponds to the spacing between the dialog text and the
 * inner portrait (y offest is still the space bewtween the text and the top of
 * the dialog box).
 *
 * Please note that this value is also used as the default offset between the 
 * `pageFinishedIndicator` and the bottom right of the dialog box.
 *
 * __Defaults to (10, 10)__
 */
@property (nonatomic) CGPoint dialogTextOffset;

/**
 * Position of the portrait in the dialog box.
 *
 * This value can be `kDialogPortraitPositionLeft` or `kDialogPortraitPositionRight`
 *
 * __Defaults to `kDialogPortraitPositionRight`__
 */
@property (nonatomic) DialogPortraitPosition portraitPosition;

/**
 * The padding between the portrait and the edge of the dialog box.
 *
 * If <portaitInsideDialog> is NO, then this value specifies the offset between
 * the portrait and the bottom edge of the dialog box depending on the <portraitPosition>.
 *
 * If <portaitInsideDialog> is YES, then this value specifies the offset between
 * the portrait and the top edge of the dialog box depending on the <portraitPosition>.
 *
 * __Defaults to (0, 0)__
 */
@property (nonatomic) CGPoint portraitOffset;

/**
 * If set to YES, the dialog's portrait will appear inside the dialog box.
 *
 * By default the portrait will be placed outside of the dialog box so you
 * can use a big beautiful portrait that is just super fabulous. 
 *
 * However if `portaitInsideDialog` is set to YES, then the portrait will instead
 * be placed inside the dialog and `portraitOffset` will be the spacing
 * between the portrait and the top left edge of the dialog box.
 *
 * __Defaults to NO__
 */
@property (nonatomic) BOOL portaitInsideDialog;

/**
 * When enabled the dialog's portrait will be animated if `portraitInsdeDialog` is set to NO.
 *
 * When <portaitInsideDialog> is NO (thus the portrait is outside the dialog),
 * setting this value to YES will result in the portrait being animated in when the
 * dialog is displayed on screen.
 *
 * For more advanced users, you can animate the portrait property of the DialogBox
 * directly if you want some other cool animation.
 *
 * __Defaults to YES__
 */
@property (nonatomic) BOOL animateOutsidePortraitIn;

/**
 * The font file used by the dialog for displaying text.
 *
 * This font file is also used by the choice dialog if the font file for
 * `choiceDialogCustomizer` is not set.
 *
 * __Defaults to the demo fnt file (`demo_fnt.fnt`) attached with the project__
 */
@property (nonatomic, copy) NSString *fntFile;

/**
 * The `DLChoiceDialogCustomizer` for the dialog box's choice dialog.
 *
 * __Defaults to the default DLChoiceDialogCustomizer__
 *
 * @see [DLChoiceDialogCustomizer defaultCustomizer]
 */
@property (nonatomic, strong) DLChoiceDialogCustomizer *choiceDialogCustomizer;

/**
 * Returns a default customizer for the dialog box
 */
+ (DLDialogBoxCustomizer *)defaultCustomizer;

@end

@class DLDialogBox;

@protocol DLDialogBoxDelegate <NSObject>
@optional

/**
 * Called after all the text has been displayed by the dialog box.
 *
 * If the dialog box needs to open a choice dialog after the last text then
 * this is called after the choice dialog is displayed, not
 * after a choice has been selected.
 */
- (void)dialogBoxAllTextFinished:(DLDialogBox *)sender;

/**
 * Called when the current diaplayed text section is finished.
 */
- (void)dialogBoxCurrentTextPageFinished:(DLDialogBox *)sender;

/**
 * Called when a choice is selected for this dialog box
 */
- (void)dialogBoxChoiceSelected:(DLDialogBox *)sender
                     choiceText:(NSString *)text
                    choiceIndex:(NSUInteger)index;
@end

@class DSCharater;

@interface DLDialogBox : CCNode
<DLAutoTypeLabelBMDelegate, DLChoiceDialogDelegate, CCTouchOneByOneDelegate>

@property (nonatomic, weak) id<DLDialogBoxDelegate> delegate;

/**
 * This is used to customize the look and feel of the dialog box.
 *
 * Setting this will immediately redraw child nodes to reflect the new look.
 */
@property (nonatomic, strong) DLDialogBoxCustomizer *customizer;

/**
 * Choices for the dialog box's choice dialog.
 *
 * When this is set the dialog box will show the choice dialog after the last
 * text page is displayed.
 */
@property (nonatomic, copy) NSArray *choices;

/**
 * The choice dialog to display at the last text page if choices are provided.
 *
 * You can customizer the choice dialog by overriding its choice dialog customizer
 *
 * The choice dialog is only created when the choices array is set.
 */
@property (nonatomic, strong) DLChoiceDialog *choiceDialog;


/**
 * This is used to override the defaultPortraitSprite you can can provide
 * some different sprite for certain pages.
 *
 * The key (page) should be > 0
 *
 * Usage:
 * - The key of the dictionary will be the page number.
 * - The value of the dictionary can be two types:
 *  
 *  Type 1:
 *    If the value belongs to the CCSprite class then this sprite will be used
 *    as the portrait sprite for the page indicated by the key.
 *      Example: `{"4": [a cool sprite]}`
 *
 *  Type 2:
 *    If the value belonds to NSString, then this string will be used by
 *    `[CCSprite spriteWithSpriteFrameName:]` to create the sprite to be used
 *    as the sprite image for the page indicated by the key.
 *      Example: `{"2": "draco_smiling.png"}`
 *
 */
@property (nonatomic, copy) NSDictionary *customPortraitForPages;

/**
 * Current page of the text that we are displaying.
 * Current page is one once the dialog starts typing its first words.
 *
 * When the dialog has not typed anything, current page is 0.
 *
 * Note this is readonly
 */
@property (nonatomic, readonly) NSUInteger currentTextPage;

/**
 * The portrait sprite to display by default. 
 *
 * If nil, no portrait will be displayed for the dialog box.
 *
 * You can customize the portrait posittions through the ChoiceDialogCustomizer
 */
@property (nonatomic, strong) CCSprite *defaultPortraitSprite;

/**
 * An array of text to display. The dialog box will display one text per page.
 */
@property (nonatomic, strong) NSMutableArray *textArray;

/**
 * When set all text page content will start with this prependText.
 *
 * A good use of this will be adding the character name before all dialog text.
 * For example setting prependText to "Draco: " will result in all text displayed
 * by the dialog box to start with "Draco: [content]" as if its me saying it :)
 */
@property (nonatomic, copy) NSString *prependText;

/**
 * Defaults to YES.
 *
 * If set to YES, then tapping will first result in the current page be
 * immediately displayed without going through the typing animation.
 *
 * If the page is already finished then tapping will go to the next page
 */
@property (nonatomic) BOOL tapToFinishCurrentPage;

/**
 * Defaults to YES
 *
 * When set, the dialog box will handle all tap inputs on the screen.
 * Since tap will go to the next page or finish current page.
 */
@property (nonatomic) BOOL handleTapInputs;

/**
 * Defaults to NO
 *
 * When set to YES, the dialog box will handle only tap inputs within the dialog
 * box, thus the player can only advance to next page by tapping inside the
 * dialog box. This dialog box does not include the portrait when its outside
 * of the dialog box.
 */
@property (nonatomic) BOOL handleOnlyTapInputsInDialogBox;

/**
 * Defaults to 0.2
 *
 * This controls the delay between each character typed by the dialog box.
 */
@property (nonatomic) ccTime typingDelay;

/**
 * Defaults to YES
 *
 * When enabled, the dialog box will automatically close on tap after the 
 * dialog is finished displaying its final content if no choices are needed.
 *
 * When there are choices to be displayed at the end, the dialog will close
 * automatically after a choice is selected.
 */
@property (nonatomic) BOOL closeWhenDialogFinished;

/**
 * This portrait that is being displayed by the dialog box
 *
 * The defaultPortraitSprite is not displayed, only this sprite is displayed.
 * This sprite only uses the texture of the defaultPortraitSprite.
 *
 * This is exposed publicly so that you can customize it (like giving it a
 * custom onEnter animation) however you like.
 */
@property (nonatomic, strong) CCSprite *portrait;

/**
 * This is set to YES when the dialogbox has finished typing the current page.
 */
@property (nonatomic, readonly) BOOL currentPageTyped;

/**
 * Initializers.
 *
 * The default DialogBox customizer is used if none is provided
 */
+ (id)dialogWithTextArray:(NSArray *)texts
          defaultPortrait:(CCSprite *)portrait;
+ (id)dialogWithTextArray:(NSArray *)texts
          defaultPortrait:(CCSprite *)portrait
               customizer:(DLDialogBoxCustomizer *)customizer;
+ (id)dialogWithTextArray:(NSArray *)texts
                  choices:(NSArray *)choices
          defaultPortrait:(CCSprite *)portrait;
+ (id)dialogWithTextArray:(NSArray *)texts
          defaultPortrait:(CCSprite *)portrait
                  choices:(NSArray *)choices
               customizer:(DLDialogBoxCustomizer *)customizer;
- (id)initWithTextArray:(NSArray *)texts
        defaultPortrait:(CCSprite *)portrait
                choices:(NSArray *)choices
             customizer:(DLDialogBoxCustomizer *)customizer;

/**
 * This method essentially calls `finishCurrentPage` if current page is still
 * being animated. Else if the typing animation is finished, then `advanceToNextPage`
 * will be called.
 *
 *  Example ussage: Make a custom next button that the player can use to skip
 *  the typing animation or go to the next page if page has already finished displaying.
 */
- (void)finishCurrentPageOrAdvance;

/**
 * Finish the current page immediately, skipping any typing animations.
 */
- (void)finishCurrentPage;

/**
 * Finish the current page immediately and display the next page content
 */
- (void)advanceToNextPage;

/**
 * Update this dialog's portrait with the texture of the passed in sprite.
 */
- (void)updatePortraitTextureWithSprite:(CCSprite *)sprite;

/**
 * Shows the choice dialog immediately if one is created.
 *
 * Note that the choice dialog is actually added tho the same parent that this
 * dialog box is added to. Thus you should set the choiceDialog's position
 * manually right after setting choices.
 * 
 * The choice Dialog is created when choices are set.
 */
- (void)showChoiceDialog;

/**
 * Remove any displayed choice dialog and then perform any cleanup
 */
- (void)removeChoiceDialogAndCleanUp;

/**
 * Remove this dialog from the parent and clean up
 */
- (void)removeDialogBoxAndCleanUp;

@end
