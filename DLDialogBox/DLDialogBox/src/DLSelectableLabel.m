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
  customizer.textOffset = ccp(10, 5);
  customizer.textAlignment = kCCTextAlignmentCenter;
  return customizer;
}

@end

@interface DLSelectableLabel ()
@property (nonatomic, strong) CCTexture2D *defaultTexture;
@property (nonatomic, strong) CCTexture2D *preSelectedTexture;
@property (nonatomic, strong) CCTexture2D *selectedTexture;
@property (nonatomic) BOOL isReceivingTouchEvents;

/**
 * I implemented my own version of alignment with anchor point.
 */
- (void)updateTextWithAlignment:(CCTextAlignment)alignment;

/**
 * Convevient method to update textures with the colors from customizer
 * Also updates our bg sprite contentsize.
 */
- (void)updateBackgrounds;
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
    self.customizer = customizer;
    
    // Add background
    // This is done fater customizer since customizer sets the defaultTexture
    _bgSprite = [CCSprite spriteWithTexture:self.defaultTexture];
    _bgSprite.anchorPoint = ccp(0, 0);
    _bgSprite.position = ccp(0, 0);
    [self addChild:_bgSprite z:0];
  }
  
  return self;
}


#pragma mark - Public methods

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

- (void)setWidth:(CGFloat)width
{
  // Calculate and update new content size
  CGSize newSize = CGSizeMake(width, self.contentSize.height);
  self.contentSize = newSize;
  
  // Update label width + background width
  [self updateBackgrounds];
  
  // Update text alignment again since width changed
  [self updateTextWithAlignment:self.customizer.textAlignment];
}


#pragma mark - Private methods

- (void)updateTextWithAlignment:(CCTextAlignment)alignment
{
  DLSelectableLabelCustomizer *customizer = self.customizer;
  CGSize contentSize = self.contentSize;
  CGSize labelSize = self.text.contentSize;
  CGFloat halfYOffset = customizer.textOffset.y + labelSize.height / 2;
  CGFloat halfXOffset = customizer.textOffset.x + labelSize.width / 2;
  if (alignment == kCCTextAlignmentLeft) {
    self.text.anchorPoint = ccp(0, 0.5f);
    self.text.position = ccp(customizer.textOffset.x, halfYOffset);
  }else if (alignment == kCCTextAlignmentCenter) {
    self.text.anchorPoint = ccp(0.5f, 0.5f);
    self.text.position = ccp(halfXOffset, halfYOffset);
    CCLOGWARN(@"Know bug! DLSelectableLabel currently does not support center align due to cocos2d bug.");
  }else if (alignment == kCCTextAlignmentRight) {
    self.text.anchorPoint = ccp(1.0f, 0.5f);
    self.text.position = ccp(contentSize.width - customizer.textOffset.x, halfYOffset);
  }
}

- (void)updateBackgrounds
{
  // Update textures
  self.defaultTexture = [CCSprite rectangleOfSize:self.contentSize
                                            color:_customizer.backgroundColor].texture;
  self.preSelectedTexture = [CCSprite rectangleOfSize:self.contentSize
                                                color:_customizer.preSelectedBackgroundColor].texture;
  self.selectedTexture = [CCSprite rectangleOfSize:self.contentSize
                                             color:_customizer.selectedBackgroundColor].texture;
  
  // Update bgsprite size
  self.bgSprite.contentSize = self.contentSize;
  
  // Update bgsprite texture
  if (self.selected) {
    [self.bgSprite setTexture:self.selectedTexture];
  }else if (self.preselected) {
    [self.bgSprite setTexture:self.preSelectedTexture];
  }else {
    [self.bgSprite setTexture:self.defaultTexture];
  }
  
  // Update bgsprite rect
  [self.bgSprite setTextureRect:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
}


#pragma mark - Property setter overrides

- (void)setCustomizer:(DLSelectableLabelCustomizer *)customizer
{
  if (_customizer != customizer) {
    _customizer = customizer;
    
    // Update label size and text position
    CGSize labelSize = CGSizeMake(_text.contentSize.width + 2 * customizer.textOffset.x,
                                  _text.contentSize.height + 2 * customizer.textOffset.y);
    self.contentSize = labelSize;
    [self updateTextWithAlignment:customizer.textAlignment];
    
    // Update backgrounds and its size
    [self updateBackgrounds];
  }
}

- (void)setPreselected:(BOOL)preselected
{
  if (_preselected == preselected) {
    return;
  }
  
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
  if (_selected == selected) {
    return;
  }
  
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

- (void)onEnter
{
  // Only start collecting touch events once this label is displayed to save
  // some processing power
  if (!self.isReceivingTouchEvents) {
    [[[CCDirector sharedDirector] touchDispatcher]
     addTargetedDelegate:self priority:kSelectableLabelTouchPriority swallowsTouches:YES];
  }
}

#pragma mark - Touch delegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
  // Only claim touches inside our label rect
  CGPoint touchPoint = [self convertTouchToNodeSpace:touch];
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