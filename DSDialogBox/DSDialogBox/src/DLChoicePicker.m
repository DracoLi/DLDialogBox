//
//  DLAutoTypeLabelBM.h
//  DSDialogBox
//
//  Created by Draco on 2013-09-04.
//  Copyright Draco Li 2013. All rights reserved.
//

#import "DLChoicePicker.h"
#import "CCSprite+GLBoxes.h"
#import "DLSelectableLabel.h"
#import "CCSpriteScale9.h"

@implementation DLChoicePickerCustomizer

+ (DLChoicePickerCustomizer *)defaultCustomizer
{
  DLChoicePickerCustomizer *customizer = [[DLChoicePickerCustomizer alloc] init];
  customizer.borderSpriteFileName = @"dialog_border.png";
  customizer.borderLeftCapWidth = 32.0;
  customizer.borderTopCapWidth = 32.0;
  
  customizer.backgroundColor = ccc4f(0, 0, 0, 0.8);
  customizer.contentOffset = ccp(5, 5);
  customizer.fntFile = @"demo_fnt.fnt";
  customizer.labelCustomizer = [DLSelectableLabelCustomizer defaultCustomizer];
  return customizer;
}

@end

@interface DLChoicePicker ()
@property (nonatomic, strong) CCSprite *bgSprite;
@property (nonatomic, strong) CCSpriteScale9 *borderSprite;
@property (nonatomic, copy) NSArray *labels;

- (void)updateAllChoiceLabels;
@end

@implementation DLChoicePicker

- (void)dealloc
{
  for (DLSelectableLabel *label in self.labels) {
    label.delegate = nil;
  }
}

+ (id)dialogWithChoices:(NSArray *)choices
                fntFile:(NSString *)fntFile
        backgroundColor:(ccColor4F)color
          contentOffset:(CGPoint)offset
  paddingBetweenChoices:(CGFloat)padding
{
  DLChoicePickerCustomizer *customizer = [DLChoicePickerCustomizer defaultCustomizer];
  customizer.fntFile = fntFile;
  customizer.backgroundColor = color;
  customizer.contentOffset = offset;
  customizer.paddingBetweenChoices = padding;
  return [[self alloc] initWithChoices:choices
                      pickerCustomizer:customizer];
}

+ (id)dialogWithChoices:(NSArray *)choices
       pickerCustomizer:(DLChoicePickerCustomizer *)pickerCustomizer
{
  return [[self alloc] initWithChoices:choices
                      pickerCustomizer:pickerCustomizer];
}

+ (id)dialogWithChoices:(NSArray *)choices
{
  return [[self alloc] initWithChoices:choices
                      pickerCustomizer:[DLChoicePickerCustomizer defaultCustomizer]];
}

- (id)initWithChoices:(NSArray *)choices
     pickerCustomizer:(DLChoicePickerCustomizer *)pickerCustomizer
{
  if (self = [super init])
  {
    _choices = choices;
    
    _preselectEnabled = YES;
    
    // This creates the choice labels, set picker size and creates the background
    // for our choice picker.
    [self setPickerCustomizer:pickerCustomizer];
  }
  
  return self;
}


#pragma mark - Property setter overrides

- (void)setPickerCustomizer:(DLChoicePickerCustomizer *)pickerCustomizer
{
  if (_pickerCustomizer != pickerCustomizer) {
    _pickerCustomizer = pickerCustomizer;
    
    // Remove all existing backgrounds
    if (_borderSprite) {
      [_borderSprite removeFromParentAndCleanup:YES];
    }
    
    if (_bgSprite) {
      [_bgSprite removeFromParentAndCleanup:YES];
    }
    
    // Update picker choices position
    [self updateAllChoiceLabels];
    
    // Calculate and set the content size of our picker
    // Must do this after creating pickers since we will be using the size of the pickers
    DLSelectableLabel *oneLabel = [self.labels objectAtIndex:0];
    NSUInteger labelsCount = [self.labels count];
    CGFloat pickerHeight = _pickerCustomizer.contentOffset.y * 2 \
                           + labelsCount * oneLabel.contentSize.height \
                           + _pickerCustomizer.paddingBetweenChoices * (labelsCount - 1);
    CGFloat pickerWidth = oneLabel.contentSize.width * pickerCustomizer.contentOffset.x * 2;
    CGSize pickerSize = CGSizeMake(pickerWidth, pickerHeight);
    self.contentSize = pickerSize;
    
    // Update picker background
    if (pickerCustomizer.borderSpriteFileName)
    {
      // If we have border create it along with content background
      CCSpriteScale9 *border = [CCSpriteScale9
                                spriteWithFile:pickerCustomizer.borderSpriteFileName
                                andLeftCapWidth:pickerCustomizer.borderLeftCapWidth
                                andTopCapHeight:pickerCustomizer.borderTopCapWidth];
      ccColor4F colors = pickerCustomizer.backgroundColor;
      [border setColor:ccc3(colors.r, colors.g, colors.b)];
      [border setOpacity:colors.a];
      border.anchorPoint = ccp(0, 0);
      border.position = ccp(0, 0);
      _borderSprite = border;
      [self addChild:_borderSprite z:0];
    }
    else
    {
      // If no border just create choice picker background
      _bgSprite = [CCSprite rectangleOfSize:pickerSize color:pickerCustomizer.backgroundColor];
      _bgSprite.anchorPoint = ccp(0, 0);
      _bgSprite.position = ccp(0, 0);
      [self addChild:_bgSprite z:0];
    }
  }
}

- (void)setChoices:(NSArray *)choices
{
  if (_choices != choices) {
    _choices = choices;
    
    // Update all choice labels to reflect new choices
    [self updateAllChoiceLabels];
  }
}

- (void)setPreselectEnabled:(BOOL)preselectEnabled
{
  if (_preselectEnabled != preselectEnabled) {
    _preselectEnabled = preselectEnabled;
    
    // Look through all existing labels to update preselect property
    for (DLSelectableLabel *label in self.labels) {
      label.preselectEnabled = _preselectEnabled;
    }
  }
}

- (void)setSwallowAllTouches:(BOOL)swallowAllTouches
{
  if (_swallowAllTouches != swallowAllTouches) {
    
    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
    if (_swallowAllTouches) {
      [dispatcher addTargetedDelegate:self
                             priority:kChoicePickerDefaultTouchPriority
                      swallowsTouches:YES];
    }else {
      [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    }
  }
}


#pragma mark - Public methods

- (void)selectChoiceAtIndex:(NSUInteger)index
{
  DLSelectableLabel *targetLabel = [self.labels objectAtIndex:index];
  [targetLabel select];
}


#pragma mark - Private methods

- (void)updateAllChoiceLabels
{
  // Remove all existing choice labels
  for (DLSelectableLabel *label in self.labels) {
    [label removeFromParentAndCleanup:YES];
    label.delegate = nil;
  }
  
  // Create and add choices labels
  CGFloat heightOffset = _pickerCustomizer.contentOffset.y;
  NSMutableArray *allLabels = [NSMutableArray arrayWithCapacity:_choices.count];
  for (NSString *choice in _choices) {
    DLSelectableLabel *label = [[DLSelectableLabel alloc]
                                initWithText:choice
                                fntFile:_pickerCustomizer.fntFile
                                cutomizer:_pickerCustomizer.labelCustomizer];
    label.anchorPoint = ccp(0, 1); // top left corner at anchor
    label.position = ccp(_pickerCustomizer.contentOffset.x, heightOffset);
    label.preselectEnabled = _preselectEnabled;
    label.delegate = self;
    [self addChild:label z:1];
    [allLabels addObject:label];
    
    // Set the y position of the next label
    heightOffset = heightOffset + label.contentSize.height + _pickerCustomizer.paddingBetweenChoices;
  }
  self.labels = [allLabels copy];
}

#pragma mark - DSSelectableLabel Delegate

- (void)selectableLabelPreselected:(DLSelectableLabel *)sender
{
  // When a label is preselected in a dialog, we deselect all other labels
  for (DLSelectableLabel *label in self.labels) {
    if (![label isEqual:sender]) {
      [label deselect];
    }
  }
}

- (void)selectableLabelSelected:(DLSelectableLabel *)sender
{
  CCLOG(@"dialog confirmed with value: %@, index: %i",
        sender.text.string, sender.tag);
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(choiceDialogLabelSelected:labelText:choiceIndex:)])
  {
    [self.delegate choiceDialogLabelSelected:self
                                   labelText:sender.text.string
                                 choiceIndex:sender.tag];
  }
}

#pragma mark - CCTouchOneByOneDelegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
  if (self.swallowAllTouches) {
    return YES;
  }
  return NO;
}

@end
