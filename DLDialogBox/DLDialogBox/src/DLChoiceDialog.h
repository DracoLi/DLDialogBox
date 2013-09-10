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

#define kChoiceDialogDefaultTouchPriority 1

@interface DLChoiceDialogCustomizer : NSObject

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
 * Defaults to a transparent color (`ccc4(0,0,0,0)`) if not specified.
 *
 * You can create a `ccColor4B` via `ccc4(red, blue, green, alpha)`.
 * Note that all color values are from 0-255.
 */
@property (nonatomic) ccColor4B backgroundColor;

/**
 * The font file used to style the choice labels
 *
 * Default to the fnt file packaged with the demo. You must change this if 
 * you are not including that demo font file.
 */
@property (nonatomic, copy) NSString *fntFile;

/**
 * This determines the offset between the choice dialog's choice content and
 * the choice dialog itself.
 */
@property (nonatomic) CGPoint contentOffset;

/**
 * As the name implies, this determines the distance between the choice labels. 
 */
@property (nonatomic) CGFloat paddingBetweenChoices;

/**
 * Stores customization properties for labels inside choice dialog
 */
@property (nonatomic, strong) DLSelectableLabelCustomizer *labelCustomizer;

/**
 * Returns the default customizer used by DLChoiceDialog
 */
+ (DLChoiceDialogCustomizer *)defaultCustomizer;

@end

@class DLChoiceDialog, DLSelectableLabelCustomizer;
@protocol DLChoiceDialogDelegate <NSObject>
@optional
- (void)choiceDialogLabelSelected:(DLChoiceDialog *)sender
                       choiceText:(NSString *)text
                      choiceIndex:(NSUInteger)index;
@end

@interface DLChoiceDialog : CCNode <DLSelectableLabelDelegate, CCTouchOneByOneDelegate>

@property (nonatomic, weak) id<DLChoiceDialogDelegate> delegate;

/**
 * Array of strings that contains the choices for this choice dialog
 */
@property (nonatomic, copy) NSArray *choices;

/**
 * Defaults to YES
 *
 * If set to YES, labels inside the dialog will have a preselect state.
 * Thus the user must tap on a label twice to select it.
 */
@property (nonatomic) BOOL preselectEnabled;

/**
 * Defaults to NO
 *
 * If set to true the choice dialog will swallow all touches.
 * Setting this to YES essentially disables all touch inputs aside from this dialog.
 *
 * Defaults to NO since its likely you still want your user to tap on things like
 * the menu button etc. However setting this to YES allows you to easily disable
 * user interaction (ie walking) so it is still pretty useful.
 */
@property (nonatomic) BOOL swallowAllTouches;

/**
 * Stores customization for the choice dialog.
 *
 * Note that changing this will essentially redraw everything inside the choice
 * dialog, so please don't change this refrequently.
 */
@property (nonatomic, strong) DLChoiceDialogCustomizer *customizer;

/**
 * Initialization related.
 *
 * Use the first initializer if you want some control over look and feel but
 * do not have any custom images for your dialog.
 *
 * Use the second initializer if you are fine with the default look and want to
 * just get the choice dialog up and running and ready to rock.
 *
 * Use the third initializer if you want to control the full look and feel of
 * your choice dialog.
 */
+ (id)dialogWithChoices:(NSArray *)choices
                fntFile:(NSString *)fntFile
        backgroundColor:(ccColor4B)color
          contentOffset:(CGPoint)offset
  paddingBetweenChoices:(CGFloat)padding;
+ (id)dialogWithChoices:(NSArray *)choices
       dialogCustomizer:(DLChoiceDialogCustomizer *)dialogCustomizer;
+ (id)dialogWithChoices:(NSArray *)choices;
- (id)initWithChoices:(NSArray *)choices
     dialogCustomizer:(DLChoiceDialogCustomizer *)dialogCustomizer;


/**
 * Programatically select a choice.
 * The delegate will be notified of the selection.
 *
 * Will preselect the label if preselectEnabled is YES and the choice is not preselected.
 */
- (void)selectChoiceAtIndex:(NSUInteger)index;

@end
