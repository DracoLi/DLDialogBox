//
//  DLAutoTypeLabelBM.h
//  DSDialogBox
//
//  Created by Draco on 2013-09-04.
//  Copyright Draco Li 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define kSelectableLabelTouchPriority 0

@interface DLSelectableLabelCustomizer : NSObject

/**
 * Specifies the color for the label's normal state
 */
@property (nonatomic) ccColor4B backgroundColor;

/**
 * Specifies a custom color for the label's preselected state
 */
@property (nonatomic) ccColor4B preSelectedBackgroundColor;

/**
 * Specifies a custom color for the label's selected state
 */
@property (nonatomic) ccColor4B selectedBackgroundColor;

/**
 * Specifies the offset between the label's string and the label.
 * The larger the string offset the more spacing there are between the label string
 * and the label itself.
 */
@property (nonatomic) CGPoint stringOffset;

/**
 * Returns the default customizer used by DLSelectedLabel
 */
+ (DLSelectableLabelCustomizer *)defaultCustomizer;

@end

@class DLSelectableLabel;
@protocol DLSelectableLabelDelegate <NSObject>
@optional
- (void)selectableLabelPreselected:(DLSelectableLabel *)sender;
- (void)selectableLabelSelected:(DLSelectableLabel *)sender;
@end

@interface DLSelectableLabel : CCNode <CCTouchOneByOneDelegate>

@property (nonatomic, weak) id<DLSelectableLabelDelegate> delegate;
@property (nonatomic, strong) CCLabelBMFont *text;
@property (nonatomic, strong) CCSprite *bgSprite;

/**
 * When set to YES, the label's background will change to reflect the label
 * being preselected and the delegate will be notified.
 *
 * This BOOL will do nothing if preselectEnabled is set to NO
 *
 * Default is NO
 */
@property (nonatomic) BOOL preselected;

/**
 * When set to YES, the label's background will change to reflect the label
 * being selected and the delegate will be notified.
 *
 * Default is NO
 */
@property (nonatomic) BOOL selected;

/**
 * If enabled this label will automatically be deselected if tapped outside.
 * Default is NO
 */
@property (nonatomic) BOOL deselectOnOutsideTap;

/**
 * When set to YES, tapping the label the first time will result in the label
 * being preselected. When preselect the delegate will be notified and the label's
 * background will change to the preselected background (if it is set).
 *
 * Enable preselect may result in a better user experience since its easy
 * for the user to accidentally tap on an unwanted label.
 *
 * Default is YES
 */
@property (nonatomic) BOOL preselectEnabled;

/**
 * The customizer is used to customize the look of the label
 */
@property (nonatomic, strong) DLSelectableLabelCustomizer *customizer;

/**
 * Bunch of initialization methods
 *
 * When a customizer is not provided, DLSelectableLabel will use the default
 * customizer provided by the Customizer Class.
 */
+ (id)labelWithText:(NSString *)text
            fntFile:(NSString *)fntFile;
- (id)initWithText:(NSString *)text
           fntFile:(NSString *)fntFile;
+ (id)labelWithText:(NSString *)text
            fntFile:(NSString *)fntFile
          cutomizer:(DLSelectableLabelCustomizer *)customizer;
- (id)initWithText:(NSString *)text
           fntFile:(NSString *)fntFile
          cutomizer:(DLSelectableLabelCustomizer *)customizer;

/**
 * Called to select the current label.
 *
 * If preselectEnabled is YES and this label is not select and not preselected
 * then calling select will preselect this label
 *
 * If this label is preselected or not select but preselectEnabled is NO, then
 * calling this method will select the label
 */
- (void)select;

/**
 * Deselect reverts the label to the default state. Not selected or preselected
 */
- (void)deselect;

@end
