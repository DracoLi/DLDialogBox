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

#define kChoicePickerDefaultTouchPriority 1

@interface DLChoicePickerCustomizer : NSObject

/**
 * A sprite file name, left cap width, and top cap width is used
 * together into order to generate the border for the choice picker.
 * The border sprite file will be stretched to accommodate the content inside.
 *
 * Please refer to readme for examples on how to use a custom border image
 */
@property (nonatomic, copy) NSString *borderSpriteFileName;
@property (nonatomic) CGFloat borderLeftCapWidth;
@property (nonatomic) CGFloat borderTopCapWidth;


/**
 * This determines the inner background color for our picker.
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
 * This determines the offset between the choice picker's choice content and
 * the picker dialog it self.
 */
@property (nonatomic) CGPoint contentOffset;

/**
 * As the name implies, this determines the distance between the choice labels. 
 */
@property (nonatomic) CGFloat paddingBetweenChoices;

/**
 * Stores customization properties for labels inside choice picker
 */
@property (nonatomic, strong) DLSelectableLabelCustomizer *labelCustomizer;

/**
 * Returns the default customizer used by DLChoicePicker
 */
+ (DLChoicePickerCustomizer *)defaultCustomizer;

@end

@class DLChoicePicker, DLSelectableLabelCustomizer;
@protocol DLChoicePickerDelegate <NSObject>
@optional
- (void)choiceDialogLabelSelected:(DLChoicePicker *)sender
                       choiceText:(NSString *)text
                      choiceIndex:(NSUInteger)index;
@end

@interface DLChoicePicker : CCNode <DLSelectableLabelDelegate, CCTouchOneByOneDelegate>

@property (nonatomic, weak) id<DLChoicePickerDelegate> delegate;

/**
 * Array of strings that contains the choices for this choice picker
 */
@property (nonatomic, copy) NSArray *choices;

/**
 * If set to YES, labels inside the picker will have a preselect state.
 * Thus the user must tap on a label twice to select it.
 *
 * Defaults to YES
 */
@property (nonatomic) BOOL preselectEnabled;

/**
 * If set to true the choice picker will swallow all touches.
 * Setting this to YES essentially disables all touch inputs aside from this picker.
 *
 * Default to NO, since its likely you still want your user to tap on things like
 * the menu button etc. However setting this to YES allows you to easily disable
 * user interaction (ie walking) so it is still pretty useful.
 */
@property (nonatomic) BOOL swallowAllTouches;

/**
 * Stores customization for the choice picker.
 *
 * Note that changing this will essentially redraw everything inside the choice
 * picker, so please don't change this refrequently.
 */
@property (nonatomic, strong) DLChoicePickerCustomizer *customizer;

/**
 * Initialization related.
 *
 * Use the first initializer if you want some control over look and feel but
 * do not have any custom images for your picker.
 *
 * Use the second initializer if you are fine with the default look and want to
 * just get the choice picker up and running and ready to rock.
 *
 * Use the third initializer if you want to control the full look and feel of
 * your choice picker.
 */
+ (id)pickerWithChoices:(NSArray *)choices
                fntFile:(NSString *)fntFile
        backgroundColor:(ccColor4B)color
          contentOffset:(CGPoint)offset
  paddingBetweenChoices:(CGFloat)padding;
+ (id)pickerWithChoices:(NSArray *)choices
       pickerCustomizer:(DLChoicePickerCustomizer *)pickerCustomizer;
+ (id)pickerWithChoices:(NSArray *)choices;
- (id)initWithChoices:(NSArray *)choices
     pickerCustomizer:(DLChoicePickerCustomizer *)pickerCustomizer;


/**
 * Programatically select a choice.
 * The delegate will be notified of the selection.
 *
 * Will preselect the label if preselectEnabled is YES and the choice is not preselected.
 */
- (void)selectChoiceAtIndex:(NSUInteger)index;

@end
