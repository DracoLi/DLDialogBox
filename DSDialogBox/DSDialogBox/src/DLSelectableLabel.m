//
//  DLAutoTypeLabelBM.h
//  DSDialogBox
//
//  Created by Draco on 2013-09-04.
//  Copyright Draco Li 2013. All rights reserved.
//

#import "DLSelectableLabel.h"
#import "CCSprite+GLBoxes.h"

@implementation DLSelectableLabelCustomizer

+ (DLSelectableLabelCustomizer *)defaultCustomizer
{
  DLSelectableLabelCustomizer *customizer = [[DLSelectableLabelCustomizer alloc] init];
  customizer.preSelectedBackgroundColor = ccc4(200, 0, 0, 0.70*255);
  customizer.stringOffset = ccp(10, 5);
  return customizer;
}

@end

@interface DLSelectableLabel ()
@property (nonatomic, strong) CCTexture2D *defaultTexture;
@property (nonatomic, strong) CCTexture2D *preSelectedTexture;
@property (nonatomic, strong) CCTexture2D *selectedTexture;
@end

@implementation DLSelectableLabel

- (void)dealloc
{
  self.delegate = nil;
  [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

+ (id)labelWithText:(NSString *)text
            fntFile:(NSString *)fntFile
{
  return [[self alloc] initWithText:text
                            fntFile:fntFile];
}

+ (id)labelWithText:(NSString *)text
            fntFile:(NSString *)fntFile
          cutomizer:(DLSelectableLabelCustomizer *)customizer
{
  return [[self alloc] initWithText:text
                            fntFile:fntFile
                          cutomizer:customizer];
}

- (id)initWithText:(NSString *)text
           fntFile:(NSString *)fntFile
{
  DLSelectableLabelCustomizer *customizer = [DLSelectableLabelCustomizer defaultCustomizer];
  self = [self initWithText:text
                    fntFile:fntFile
                  cutomizer:customizer];
  return self;
}

- (id)initWithText:(NSString *)text
           fntFile:(NSString *)fntFile
         cutomizer:(DLSelectableLabelCustomizer *)customizer
{
  if (self = [super init])
  {
    // Initial state
    _preselected = NO;
    _selected = NO;
    
    // Add text
    _text = [CCLabelBMFont labelWithString:text fntFile:fntFile];
    _text.anchorPoint = ccp(0, 0);
    [self addChild:_text z:1];
    
    // Setting the customizer will update our textures, label string and text position
    _customizer = customizer;
    
    // Add background
    _bgSprite = [CCSprite spriteWithTexture:self.defaultTexture];
    _bgSprite.anchorPoint = ccp(0, 0);
    _bgSprite.position = ccp(0, 0);
    [self addChild:_bgSprite z:0];
    
    // Add touch responder
    // We only swallow touches on this label
    [[[CCDirector sharedDirector] touchDispatcher]
     addTargetedDelegate:self priority:kSelectableLabelTouchPriority swallowsTouches:YES];
  }
  
  return self;
}

- (void)select
{
  if (self.preselectEnabled) {
    if (!self.preselected) {
      self.preselected = YES;
    }else {
      self.selected = YES;
    }
  }else {
    self.selected = YES;
  }
}

- (void)deselect
{
  self.selected = NO;
  self.preselected = NO;
}

- (void)setCustomizer:(DLSelectableLabelCustomizer *)customizer
{
  if (_customizer != customizer) {
    _customizer = customizer;
    
    // Update label size and text position
    CGSize labelSize = CGSizeMake(_text.contentSize.width + 2 * customizer.stringOffset.x,
                                  _text.contentSize.height + 2 * customizer.stringOffset.y);
    self.contentSize = labelSize;
    self.text.position = customizer.stringOffset;
    
    // Save textures
    self.defaultTexture = [CCSprite rectangleOfSize:labelSize
                                              color:customizer.backgroundColor].texture;
    self.preSelectedTexture = [CCSprite rectangleOfSize:labelSize
                                                  color:customizer.preSelectedBackgroundColor].texture;
    self.selectedTexture = [CCSprite rectangleOfSize:labelSize
                                               color:customizer.selectedBackgroundColor].texture;
    
    // Update background size
    self.bgSprite.contentSize = labelSize;
  }
}

- (void)setPreselected:(BOOL)preselected
{
  _preselected = preselected;
  
  if (preselected) {
    // Cannot be selected when preselected
    _selected = NO;
    
    // Update texture
    self.bgSprite.texture = self.preSelectedTexture;
    
    // Update delegate
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(selectableLabelPreselected:)]) {
      [self.delegate selectableLabelPreselected:self];
    }
  }else {
    self.bgSprite.texture = self.defaultTexture;
  }
}

- (void)setSelected:(BOOL)selected
{
  _selected = selected;
  
  if (selected) {
    // Cannot be preselected when selected
    _preselected = NO;
    
    // Update texture
    self.bgSprite.texture = self.selectedTexture;
    
    // Play sound fx
    
    // Update delegate
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(selectableLabelSelected:)]) {
      [self.delegate selectableLabelSelected:self];
    }
  }else {
    // Revert background texture to previous state
    if (self.preselected && self.preselectEnabled) {
      self.bgSprite.texture = self.preSelectedTexture;
    }else {
      self.bgSprite.texture = self.defaultTexture;
    }
  }
}

#pragma mark - Touch delegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
  // Only claim touches inside our label rect
  CGPoint touchPoint = [self convertTouchToNodeSpaceAR:touch];
  CGRect relativeRect = CGRectMake(0, 0,
                                   self.contentSize.width,
                                   self.contentSize.height);
  BOOL touchValid = CGRectContainsPoint(relativeRect, touchPoint);
  
  // Handle touch
  if (touchValid) {
    CCLOG(@"Touch valid for label with text: %@", self.text.string);
    [self select];
  }
  
  return touchValid;
}

@end
