//
//  DLAutoTypeLabelBM.h
//  DSDialogBox
//
//  Created by Draco on 2013-09-04.
//  Copyright Draco Li 2013. All rights reserved.
//

#import "DLChoiceDialog.h"
#import "CCSprite+GLBoxes.h"
#import "DLSelectableLabel.h"
#import "CCScale9Sprite.h"

@implementation DLChoiceDialogCustomizer

+ (DLChoiceDialogCustomizer *)defaultCustomizer
{
  DLChoiceDialogCustomizer *customizer = [[DLChoiceDialogCustomizer alloc] init];
  
  // Look
  customizer.backgroundColor = ccc4(0, 0, 0, 0.8*255);
  customizer.fntFile = @"demo_fnt.fnt";
  customizer.contentInsets = UIEdgeInsetsMake(5, 5, 5, 5);
  customizer.spacingBetweenChoices = 5.0;
  customizer.labelCustomizer = [DLSelectableLabelCustomizer defaultCustomizer];
  
  // Functionalities
  customizer.preselectEnabled = YES;
  customizer.swallowAllTouches = NO;
  
  return customizer;
}

@end

@interface DLChoiceDialog ()
@property (nonatomic, strong) CCNode *bgSprite;
@property (nonatomic, copy) NSArray *labels;

- (void)updateChoiceDialogUI;
@end

@implementation DLChoiceDialog

- (void)dealloc
{
  for (DLSelectableLabel *label in self.labels) {
    label.delegate = nil;
  }
  [self.customizer removeObserver:self forKeyPath:@"preselectEnabled"];
  [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

+ (id)dialogWithChoices:(NSArray *)choices
{
  return [[self alloc] initWithChoices:choices
                      dialogCustomizer:[DLChoiceDialogCustomizer defaultCustomizer]];
}

+ (id)dialogWithChoices:(NSArray *)choices
       dialogCustomizer:(DLChoiceDialogCustomizer *)dialogCustomizer
{
  return [[self alloc] initWithChoices:choices
                      dialogCustomizer:dialogCustomizer];
}


- (id)initWithChoices:(NSArray *)choices
     dialogCustomizer:(DLChoiceDialogCustomizer *)dialogCustomizer
{
  if (self = [super init])
  {
    _customizer = dialogCustomizer;
    
    // Observe for swallowAllTouches changes
    [self.customizer addObserver:self
                      forKeyPath:@"preselectEnabled"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
    
    // This generates our labels and then update UI according to them
    self.choices = choices;
    
    // Listen for touch events
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self
                                                              priority:kChoiceDialogDefaultTouchPriority
                                                       swallowsTouches:YES];
  }
  
  return self;
}


#pragma mark - Property setter overrides

- (void)setCustomizer:(DLChoiceDialogCustomizer *)customizer
{
  if (_customizer != customizer) {
    _customizer = customizer;
    
    // Update UI of content only if have content generated after setting choices
    if (self.labels && self.labels.count > 0) {
      [self updateChoiceDialogUI];
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
    _customizer.labelCustomizer.preselectEnabled = _customizer.preselectEnabled;
    NSMutableArray *allLabels = [NSMutableArray arrayWithCapacity:_choices.count];
    for (int i = 0; i < _choices.count; i++) {
      NSString *choice = [_choices objectAtIndex:i];
      
      DLSelectableLabel *label = [[DLSelectableLabel alloc]
                                  initWithText:choice
                                  fntFile:_customizer.fntFile
                                  cutomizer:_customizer.labelCustomizer];
      label.anchorPoint = ccp(0, 1); // top left corner is anchor
      label.delegate = self;
      label.tag = i;
      [self addChild:label z:1];
      [allLabels addObject:label];
    }
    self.labels = [allLabels copy];
    
    NSAssert([(DLSelectableLabel *)[self.labels objectAtIndex:1] tag] == 1, @"Index for labels must be correct");
    
    // Update all choice labels on screen according to current customizer
    [self updateChoiceDialogUI];
  }
}

#pragma mark - Public methods

- (void)selectChoiceAtIndex:(NSUInteger)index skipPreselect:(BOOL)skipPreselect
{
  DLSelectableLabel *targetLabel = [self.labels objectAtIndex:index];
  if (targetLabel.customizer.preselectEnabled && skipPreselect) {
    [targetLabel selectWithoutPreselect];
  }else {
    [targetLabel select];
  }
}


#pragma mark - Private methods

- (void)updateChoiceDialogUI
{
  if (!self.labels || self.labels.count == 0) {
    return;
  }
  
  // First update all label styling and find out largest label width
  CGFloat largestLabelWidth = .0f;
  for (DLSelectableLabel *label in self.labels)
  {
    // Update label styling (does nothing if customizer is same)
    label.customizer = self.customizer.labelCustomizer;
    
    // Find the largest label width
    CGFloat labelWidth = label.contentSize.width;
    if (labelWidth > largestLabelWidth) {
      largestLabelWidth = labelWidth;
    }
  }
  
  // Update choice dialog contentSize
  NSUInteger totalChoices = _choices.count;
  DLSelectableLabel *oneLabel = [self.labels objectAtIndex:0];
  UIEdgeInsets contentInsets = _customizer.contentInsets;
  CGFloat totalHeight = contentInsets.top + contentInsets.bottom + \
                        totalChoices * oneLabel.contentSize.height +
                        _customizer.spacingBetweenChoices * (totalChoices - 1);
  CGFloat totalWidth = largestLabelWidth + contentInsets.left + contentInsets.right;
  self.contentSize = CGSizeMake(totalWidth, totalHeight);
  
  // Position all labels and adjust to common largest width
  CGFloat heightOffset = totalHeight - contentInsets.top;
  for (int i = 0; i < _choices.count; i++)
  {
    DLSelectableLabel *label = [self.labels objectAtIndex:i];
    
    // Normalize width of all choice labels
    // Change all label width to match the largest label width
    [label setWidth:largestLabelWidth];
    
    // Reposition all labels
    label.position = ccp(contentInsets.left, heightOffset);
    
    // Set the y position of the next label
    heightOffset = heightOffset - label.contentSize.height - _customizer.spacingBetweenChoices;
  }
  
  // Remove any existing background sprite
  if (_bgSprite) {
    [_bgSprite removeFromParentAndCleanup:YES];
  }
  
  // Update dialog background
  if (_customizer.backgroundSpriteFrameName)
  {
    _bgSprite = [CCScale9Sprite spriteWithSpriteFrameName:_customizer.backgroundSpriteFrameName];
    [_bgSprite setContentSize:self.contentSize];
  }
  else if (_customizer.backgroundSpriteFile)
  {
    _bgSprite = [CCScale9Sprite spriteWithFile:_customizer.backgroundSpriteFile];
    [_bgSprite setContentSize:self.contentSize];
  }
  else {
    // If no border just create choice dialog background
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
  
  // Inform delegate
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(choiceDialogLabelPreselected:choiceText:choiceIndex:)]) {
    [self.delegate choiceDialogLabelPreselected:self
                                     choiceText:sender.text.string
                                    choiceIndex:sender.tag];
  }
}

- (void)selectableLabelSelected:(DLSelectableLabel *)sender
{
  // Inform delegate
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
  if (self.customizer.swallowAllTouches) {
    return YES;
  }
  return NO;
}


#pragma mark - Property Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  // Allows preselectEnabled to be changed even after the dialog is initialized
  if (self.customizer == object &&
      [keyPath isEqualToString:@"preselectEnabled"] && self.labels)
  {
    // Update preselect of all labels
    for (DLSelectableLabel *label in self.labels) {
      label.customizer.preselectEnabled = self.customizer.preselectEnabled;
    }
  }
}

@end
