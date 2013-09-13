//
//  DLAutoTypeLabelBM.h
//  DSDialogBox
//
//  Created by Draco on 2013-09-04.
//  Copyright Draco Li 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLSelectableLabel.h"
#import "cocos2d.h"

// A block type that will be used for custom animations 
typedef void(^DLAnimationBlock)(id);

#define kChoiceDialogDefaultTouchPriority -2

/**
 * A DLChoiceDialogCustomizer is used to determine the __look__, __functionalities__,
 * and the __animations__ related to a <DLChoiceDialog>.
 *
 * Every <DLChoiceDialog> must use a dialog customizer. If no customizers are given the
 * dialog box will automatically use the default customizer provided through
 * <defaultCustomizer>.
 *
 * The reason a customizer class is used to store how a dialog box should look,
 * function and animate is because this way you can reuse a single customizer
 * instance on all the DLChoiceDialogs in your game to achieve a consistent look
 * and behaviour.
 */
@interface DLChoiceDialogCustomizer : NSObject

/// @name Customizing look/UI

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
 * __Defaults to a semi-transparent black color (`ccc4(0,0,0,0.8*255)`).__
 */
@property (nonatomic) ccColor4B backgroundColor;

/**
 * The font file used by the dialog for displaying text.
 *
 * __Defaults to the demo fnt file (`demo_fnt.fnt`) attached with the project__
 */
@property (nonatomic, copy) NSString *fntFile;

/**
 * This determines the offset between the choice dialog's choice content and
 * the choice dialog itself.
 *
 * The size of the choice dialog will adjust according to accommodate both the
 * choice content and the offset.
 *
 * __Defaults to (5, 5)__
 */
@property (nonatomic) CGPoint contentOffset;

/**
 * The vertical margin between the choice labels.
 *
 * Setting a positive `paddingBetweenChoices` will result in more spacing
 * between choice labels.
 *
 * __Defaults to 5.0__
 */
@property (nonatomic) CGFloat paddingBetweenChoices;

/**
 * The `DLSelectableLabelCustomizer` for customizing the labels inside the choice dialog.
 *
 * __Defaults to the default DLSelectableLabelCustomizer__
 *
 * @see [DLSelectableLabelCustomizer defaultCustomizer]
 */
@property (nonatomic, strong) DLSelectableLabelCustomizer *labelCustomizer;


/// @name Customizing functionalities

/**
 * If enabled, selecting a choice in a choice dialog will first preselect
 * the choice. The choice will only be selected if selected for the second time.
 *
 * Enabling this will result in less errors when the player is selecting a choice.
 *
 * __Defaults to YES__
 */
@property (nonatomic) BOOL preselectEnabled;

/**
 * If enabled, the choice dialog will swallow all touches. This can essentially
 * disable all touch inputs aside from this dialog.
 *
 * Enabling this is an easy way to disable all other user inputs when selecting a choice.
 * However it is likely that you still want your player to tap on things like the
 * menu button etc, thus `swallowAllTouches` is set to NO by default.
 *
 * Please note that once a DLChoiceDialog has been created, changing this value
 * will not change the behaviour of the DLChoiceDialog since this property, unlike
 * the other fuctionality related properties, is evaluated during DLChoiceDialog
 * creation time.
 *
 * __Defaults to NO__
 */
@property (nonatomic) BOOL swallowAllTouches;

/**
 * Returns the default customizer used by the DLChoiceDialog
 */
+ (DLChoiceDialogCustomizer *)defaultCustomizer;

@end

@class DLChoiceDialog, DLSelectableLabelCustomizer;
@protocol DLChoiceDialogDelegate <NSObject>
@optional

/**
 * Called when a choice is selected in the choice dialog. Preselects does not
 * trigger this callback.
 */
- (void)choiceDialogLabelSelected:(DLChoiceDialog *)sender
                       choiceText:(NSString *)text
                      choiceIndex:(NSUInteger)index;

/**
 * Called only when a choice is preselected in the choice dialog.
 */
- (void)choiceDialogLabelPreselected:(DLChoiceDialog *)sender
                          choiceText:(NSString *)text
                         choiceIndex:(NSUInteger)index;
@end

/**
 * DLChoiceDialog is a dialog that asks for user input from a list of choices.
 *
 * DLChoiceDialog provides a simple way for you to gain user input without
 * writing up much code.
 *
 * A <DLChoiceDialogCustomizer> is used to customize the choice dialog.
 *
 * @see DLDialogBoxCustomizer
 */
@interface DLChoiceDialog : CCNode <DLSelectableLabelDelegate, CCTouchOneByOneDelegate>

@property (nonatomic, weak) id<DLChoiceDialogDelegate> delegate;

/**
 * An array of strings that contains the choices for this choice dialog.
 *
 * Setting this array will actually redraw/reposition the choice dialog's content
 * according to the current customizer.
 *
 * However it is still recommended to not change this array once your choice dialog
 * is created.
 */
@property (nonatomic, copy) NSArray *choices;

/**
 * This customizer is used to customize the UI and functionalities of the choice dialog.
 *
 * Attempting to update any UI related properties in the customizer
 * will not do anything and may break some functionalities.
 *
 * You can however update functionality related properties on the customizer
 * as those are processed whenever they are required.
 *
 * @see DLChoiceDialogCustomizer
 */
@property (nonatomic, strong) DLChoiceDialogCustomizer *customizer;

/**
 * @param choices     An array of choice strings to be displayed
 * @param customizer  A <DLChoiceDialogCustomizer> to customize the choice dialog
 */
- (id)initWithChoices:(NSArray *)choices
     dialogCustomizer:(DLChoiceDialogCustomizer *)dialogCustomizer;

+ (id)dialogWithChoices:(NSArray *)choices;
+ (id)dialogWithChoices:(NSArray *)choices
       dialogCustomizer:(DLChoiceDialogCustomizer *)dialogCustomizer;

/**
 * Programatically selects a choice by passing the index of the choice in the <choices> array.
 *
 * If skipPreselect is set to NO, this method will preselect the label if
 * <preselectEnabled> is set to YES and the targeted choice has not 
 * already been preselected.
 *
 * __Note:__ The delegate will be notified of this selection (maybe be a preselect or select).
 */
- (void)selectChoiceAtIndex:(NSUInteger)index skipPreselect:(BOOL)skipPreselect;

@end
