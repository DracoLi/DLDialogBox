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
  customizer.backgroundColor = ccc4(0, 0, 0, 0.8*255);
  customizer.contentOffset = ccp(5, 5);
  customizer.paddingBetweenChoices = 5.0;
  customizer.fntFile = @"demo_fnt.fnt";
  customizer.labelCustomizer = [DLSelectableLabelCustomizer defaultCustomizer];
  return customizer;
}

@end

@interface DLChoicePicker ()
@property (nonatomic, strong) CCNode *bgSprite;
@property (nonatomic, copy) NSArray *labels;

- (void)updateChoicePickerUI;
@end

@implementation DLChoicePicker

- (void)dealloc
{
  for (DLSelectableLabel *label in self.labels) {
    label.delegate = nil;
  }
  [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

+ (id)pickerWithChoices:(NSArray *)choices
                fntFile:(NSString *)fntFile
        backgroundColor:(ccColor4B)color
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

+ (id)pickerWithChoices:(NSArray *)choices
       pickerCustomizer:(DLChoicePickerCustomizer *)pickerCustomizer
{
  return [[self alloc] initWithChoices:choices
                      pickerCustomizer:pickerCustomizer];
}

+ (id)pickerWithChoices:(NSArray *)choices
{
  return [[self alloc] initWithChoices:choices
                      pickerCustomizer:[DLChoicePickerCustomizer defaultCustomizer]];
}

- (id)initWithChoices:(NSArray *)choices
     pickerCustomizer:(DLChoicePickerCustomizer *)pickerCustomizer
{
  if (self = [super init])
  {
    _preselectEnabled = YES;
    _swallowAllTouches = NO;
    
    _customizer = pickerCustomizer;
    
    // This generates our labels and then update UI according to them
    self.choices = choices;
    
    [[[CCDirector sharedDirector] touchDispatcher]
     addTargetedDelegate:self
     priority:kChoicePickerDefaultTouchPriority
     swallowsTouches:YES];
  }
  
  return self;
}


#pragma mark - Property setter overrides

- (void)setCustomizer:(DLChoicePickerCustomizer *)customizer
{
  if (_customizer != customizer) {
    _customizer = customizer;
    
    // Update UI of content only if have content generated after setting choices
    if (self.labels && self.labels.count > 0) {
      [self updateChoicePickerUI];
    }
  }
}

- (void)setChoices:(NSArray *)choices
{
  if (_choices != choices) {
    _choices = choices;
    
    // Remove all existing choice labels
    for (DLSelectableLabel *label in self.labels) {
      [label removeFromParentAndCleanup:YES];
      label.delegate = nil;
    }
    
    // Make choice labels
    NSMutableArray *allLabels = [NSMutableArray arrayWithCapacity:_choices.count];
    for (int i = 0; i < _choices.count; i++) {
      NSString *choice = [_choices objectAtIndex:i];
      
      DLSelectableLabel *label = [[DLSelectableLabel alloc]
                                  initWithText:choice
                                  fntFile:_customizer.fntFile
                                  cutomizer:_customizer.labelCustomizer];
      label.anchorPoint = ccp(0, 1); // top left corner is anchor
      label.preselectEnabled = _preselectEnabled;
      label.delegate = self;
      label.tag = i;
      [self addChild:label z:1];
      [allLabels addObject:label];
    }
    self.labels = [allLabels copy];
    
    // Update all choice labels on screen according to current customizer
    [self updateChoicePickerUI];
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


#pragma mark - Public methods

- (void)selectChoiceAtIndex:(NSUInteger)index
{
  DLSelectableLabel *targetLabel = [self.labels objectAtIndex:index];
  [targetLabel select];
}


#pragma mark - Private methods

- (void)updateChoicePickerUI
{
  if (!self.labels || self.labels.count == 0) {
    return;
  }
  
  // First update all label styling and find out largest label width
  CGFloat largestLabelWidth = .0f;
  for (DLSelectableLabel *label in self.labels)
  {
    // Update label styling
    label.customizer = self.customizer.labelCustomizer;
    
    // Find the largest label width
    CGFloat labelWidth = label.contentSize.width;
    if (labelWidth > largestLabelWidth) {
      largestLabelWidth = labelWidth;
    }
  }
  
  // Update choice picker contentSize
  NSUInteger totalChoices = _choices.count;
  DLSelectableLabel *oneLabel = [self.labels objectAtIndex:0];
  CGFloat totalHeight = _customizer.contentOffset.y * 2 + \
                        totalChoices * oneLabel.contentSize.height +
                        _customizer.paddingBetweenChoices * (totalChoices - 1);
  CGFloat totalWidth = largestLabelWidth + _customizer.contentOffset.y * 2;
  self.contentSize = CGSizeMake(totalWidth, totalHeight);
  
  // Position all labels and adjust to common largest width
  CGFloat heightOffset = totalHeight - _customizer.contentOffset.y;
  for (int i = 0; i < _choices.count; i++)
  {
    DLSelectableLabel *label = [self.labels objectAtIndex:i];
    
    // Normalize width of all choice labels
    // Change all label width to match the largest label width
    [label setWidth:largestLabelWidth];
    
    // Reposition all labels
    label.position = ccp(_customizer.contentOffset.x, heightOffset);
    
    // Set the y position of the next label
    heightOffset = heightOffset - label.contentSize.height - _customizer.paddingBetweenChoices;
  }
  
  // Remove any existing background sprite
  if (_bgSprite) {
    [_bgSprite removeFromParentAndCleanup:YES];
  }
  
  // Update picker background
  if (_customizer.borderSpriteFileName) {
    // If we have border create it along with content background
    CCSpriteScale9 *sprite = [CCSpriteScale9
                              spriteWithFile:_customizer.borderSpriteFileName
                              andLeftCapWidth:_customizer.borderLeftCapWidth
                              andTopCapHeight:_customizer.borderTopCapWidth];
    ccColor4B colors = _customizer.backgroundColor;
    [sprite setColor:ccc3(colors.r, colors.g, colors.b)];
    [sprite setOpacity:colors.a];
    [sprite adaptiveScale9:self.contentSize];
    _bgSprite = sprite;
  }else {
    // If no border just create choice picker background
    _bgSprite = [CCSprite rectangleOfSize:self.contentSize
                                    color:_customizer.backgroundColor];
  }
  _bgSprite.anchorPoint = ccp(0, 0);
  _bgSprite.position = ccp(0, 0);
  [self addChild:_bgSprite z:0];
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
      [self.delegate respondsToSelector:@selector(choiceDialogLabelSelected:choiceText:choiceIndex:)])
  {
    [self.delegate choiceDialogLabelSelected:self
                                  choiceText:sender.text.string
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
