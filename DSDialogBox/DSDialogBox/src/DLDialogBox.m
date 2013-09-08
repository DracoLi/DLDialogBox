//
//  DSChatBox.m
//  sunny
//
//  Created by Draco on 2013-09-01.
//  Copyright 2013 Draco. All rights reserved.
//

#import "DLDialogBox.h"
#import "CCSprite+GLBoxes.h"
#import "CCSpriteScale9.h"

#define kBackgroundSpriteZIndex 0
#define kPageTextZIndex 1
#define kPageIndicatorZIndex 2

#define kDefaultIndicatorPadding 5
#define kDefaultTypingSpeed 0.02

#define kDialogBoxTouchPriority 0

#define kPortraitMoveAnimationDuration 0.3
#define kPortraitMoveAnimationEaseRate 0.5
#define kPortraitFadeAnimationDuration 0.2


@implementation DLDialogBoxCustomizer

+ (DLDialogBoxCustomizer *)defaultCustomizer
{
  
  DLDialogBoxCustomizer *customizer = [[DLDialogBoxCustomizer alloc] init];
  customizer.dialogSize = CGSizeMake([[CCDirector sharedDirector] winSize].width,
                                     kDialogHeightNormal);
  customizer.backgroundColor = ccc4(0, 0, 0, 0.8*255);
  customizer.pageFinishedIndicator = [CCSprite spriteWithFile:@"arrow_cursor.png"];
  customizer.speedPerPageFinishedIndicatorBlink = 1.0;
  customizer.dialogTextOffset = ccp(5, 15);
  customizer.portraitPosition = kDialogPortraitPositionLeft;
  customizer.portaitInsideDialog = NO;
  customizer.animateOutsidePortraitIn = YES;
  //  customizer.outsidePortraitInFront = NO;
  customizer.fntFile = @"demo_fnt.fnt";;
  customizer.choiceDialogCustomizer = [DLChoiceDialogCustomizer defaultCustomizer];
  return customizer;
}

@end

@interface DLDialogBox ()
@property (nonatomic, strong) DLAutoTypeLabelBM *label;
@property (nonatomic, strong) CCNode *bgSprite;
@property (nonatomic, readwrite) NSUInteger currentTextPage;
@property (nonatomic, readwrite) BOOL currentPageTyped;
@end

@implementation DLDialogBox

- (void)dealloc
{
  [self removeDialogBoxAndCleanUp];
}


+ (id)dialogWithTextArray:(NSArray *)texts
          defaultPortrait:(CCSprite *)portrait
{
  return [[self alloc] initWithTextArray:texts
                         defaultPortrait:portrait
                                 choices:nil
                              customizer:[DLDialogBoxCustomizer defaultCustomizer]];
}

+ (id)dialogWithTextArray:(NSArray *)texts
          defaultPortrait:(CCSprite *)portrait
               customizer:(DLDialogBoxCustomizer *)customizer
{
  return [[self alloc] initWithTextArray:texts
                         defaultPortrait:portrait
                                 choices:nil
                              customizer:customizer];
}

+ (id)dialogWithTextArray:(NSArray *)texts
          defaultPortrait:(CCSprite *)portrait
                  choices:(NSArray *)choices
               customizer:(DLDialogBoxCustomizer *)customizer
{
  return [[self alloc] initWithTextArray:texts
                         defaultPortrait:portrait
                                 choices:choices
                              customizer:customizer];
}

- (id)initWithTextArray:(NSArray *)texts
        defaultPortrait:(CCSprite *)portrait
                choices:(NSArray *)choices
             customizer:(DLDialogBoxCustomizer *)customizer
{
  if (self = [super init])
  {
    _currentTextPage = 0;
    _currentPageTyped = YES;
    _closeWhenDialogFinished = YES;
    _textArray = [texts mutableCopy];
    self.handleTapInputs = YES;
    _handleOnlyTapInputsInDialogBox = YES;
    _tapToFinishCurrentPage = NO;
    _typingDelay = kDefaultTypingSpeed;
    
    // Add in general portrait
    _defaultPortraitSprite = portrait;
    _portrait = [CCSprite node];
    _portrait.anchorPoint = ccp(0, 0);
    [self addChild:_portrait]; // Z index determined by customizer
    [self updatePortraitTextureWithSprite:portrait];
    
    // Add in our dialog label
    _label = [DLAutoTypeLabelBM labelWithString:@"" fntFile:customizer.fntFile];
    _label.delegate = self;
    _label.anchorPoint = ccp(0, 1);
    _label.visible = NO;
    [self addChild:_label z:kPageTextZIndex];
    
    // Creates our background indictator
    self.customizer = customizer;
    
    // Create choices and our choice dialog
    // Adding choices after customizer allows us to create a choice dialog
    // with the supplied customizer
    self.choices = choices;
  }
  
  return self;
}


#pragma mark - Custom property setters/getters

- (void)setCustomizer:(DLDialogBoxCustomizer *)customizer
{
  if (self.customizer != customizer) {
    
    // Remove all existing backgrounds
    if (_bgSprite) {
      [_bgSprite removeFromParentAndCleanup:YES];
    }
    
    // Create the background images
    CGSize dialogSize = customizer.dialogSize;
    if (customizer.borderSpriteFileName) {
      CCSpriteScale9 *sprite = [CCSpriteScale9
                                spriteWithFile:customizer.borderSpriteFileName
                                andLeftCapWidth:customizer.borderLeftCapWidth
                                andTopCapHeight:customizer.borderTopCapWidth];
      ccColor4B colors = customizer.backgroundColor;
      [sprite setColor:ccc3(colors.r, colors.g, colors.b)];
      [sprite setOpacity:colors.a];
      [sprite adaptiveScale9:dialogSize];
      _bgSprite = sprite;
    }else {
      _bgSprite = [CCSprite rectangleOfSize:dialogSize
                                      color:customizer.backgroundColor];
    }
    _bgSprite.anchorPoint = ccp(0, 0);
    _bgSprite.position = ccp(0, 0);
    [self addChild:_bgSprite z:kBackgroundSpriteZIndex];
    
    // Adjust label text position if already created
    self.label.position = ccp(customizer.dialogTextOffset.x,
                              _bgSprite.contentSize.height - customizer.dialogTextOffset.y);
    
    // If portrait is on the left and inside, we must adjust label position
    if (self.defaultPortraitSprite && customizer.portaitInsideDialog &&
        customizer.portraitPosition == kDialogPortraitPositionLeft)
    {
      CGFloat x = customizer.portraitOffset.x + _defaultPortraitSprite.contentSize.width + \
      customizer.dialogTextOffset.x;
      self.label.position = ccp(x, customizer.dialogTextOffset.y);
    }
    CCLOG(@"label position: (%0.2f, %0.2f)", self.label.position.x, self.label.position.y);
    
    // Adjust label size
    CGFloat width = dialogSize.width - customizer.dialogTextOffset.x * 2;
    if (self.defaultPortraitSprite && customizer.portaitInsideDialog) {
      width = width - _defaultPortraitSprite.contentSize.width - \
              customizer.portraitOffset.x;
    }
    [self.label setWidth:width];
    
    // Adjust portrait image position
    CGSize portraitSize = self.portrait.contentSize;
    CGPoint portraitOffset = customizer.portraitOffset;
    if (customizer.portraitPosition == kDialogPortraitPositionLeft)
    {
      if (customizer.portaitInsideDialog) {
        self.portrait.position = ccp(portraitOffset.x,
                                     dialogSize.height - portraitSize.height - \
                                     portraitOffset.y);
      }else {
        self.portrait.position = portraitOffset;
      }
    }
    else
    {
      // Portrait is on the right side
      CGFloat x = dialogSize.width - portraitSize.width - portraitOffset.x;
      CGFloat y = 0;
      if (customizer.portaitInsideDialog) {
        y = dialogSize.height - portraitOffset.y - portraitSize.height;
      }else {
        y = portraitOffset.y;
      }
      self.portrait.position = ccp(x, y);
    }
    
    // Adjust portrait z index
    if (customizer.portaitInsideDialog) {
      self.portrait.zOrder = kPageTextZIndex + 1;
    }else {
      self.portrait.zOrder = kBackgroundSpriteZIndex - 1;
    }
    
    // Adjust choice dialog look and feel
    // If we already created our choice dialog and its got the same customizer then
    // it would no nothing
    if (self.choiceDialog) {
      self.choiceDialog.customizer = customizer.choiceDialogCustomizer;
    }
    
    // Update page finished indicator
    BOOL newIndicatorSame = NO;
    if (_customizer && _customizer.pageFinishedIndicator == customizer.pageFinishedIndicator) {
      newIndicatorSame = YES;
    }
    
    // Remove existing indicator if exists and not same as new one
    if (_customizer && _customizer.pageFinishedIndicator && !newIndicatorSame) {
      [_customizer.pageFinishedIndicator removeFromParentAndCleanup:YES];
      
    }
    
    // Create our page indicator if our previous one is not the same as this one
    if (!newIndicatorSame) {
      CCSprite *indicator = customizer.pageFinishedIndicator;
      indicator.anchorPoint = ccp(0, 0);
      indicator.position = ccp(dialogSize.width - indicator.contentSize.width - kDefaultIndicatorPadding,
                               kDefaultIndicatorPadding);
      indicator.visible = NO;
      [self addChild:indicator z:kPageIndicatorZIndex];
    }
    
    // Finally set our new customizer
    _customizer = customizer;
  }
}

- (void)setChoices:(NSArray *)choices
{
  if (_choices != choices) {
    _choices = choices;
    
    if (self.choiceDialog) {
      // Remove existing choice dialogs
      [self.choiceDialog removeFromParentAndCleanup:YES];
      self.choiceDialog.delegate = nil;
    }
    
    // Make new choice dialog
    if (choices && choices.count > 0) {
      self.choiceDialog = [DLChoiceDialog dialogWithChoices:choices
                                           dialogCustomizer:self.customizer.choiceDialogCustomizer];
      self.choiceDialog.delegate = self;
    }
  }
}

- (void)setHandleTapInputs:(BOOL)handleTapInputs
{
  if (_handleTapInputs != handleTapInputs) {
    
    // Remove previous touch dispatcher
    if (_handleTapInputs) {
      [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    }
    
    // Add touch dispatcher
    if (handleTapInputs) {
      [[[CCDirector sharedDirector] touchDispatcher]
       addTargetedDelegate:self
       priority:kDialogBoxTouchPriority
       swallowsTouches:NO];
    }
    
    _handleTapInputs = handleTapInputs;
  }
}

#pragma mark - Public methods

- (void)finishCurrentPageOrAdvance
{
  // If current page is still being animated, then finish it
  if ([self.label numberOfRunningActions] > 0) {
    [self finishCurrentPage];
  }else {
    // If current page is already displayed go to next page
    [self advanceToNextPage];
  }
}

- (void)finishCurrentPage
{
  [self.label finishTypingAnimation];
}

- (void)advanceToNextPage
{
  // Stop any existing blinking cursor
  if (self.customizer.pageFinishedIndicator) {
    [self.customizer.pageFinishedIndicator stopAllActions];
    self.customizer.pageFinishedIndicator.visible = NO;
  }
  
  // Alert delegate if no more text and has no choice dialog.
  // If does have choice dialog, we alert all text finished whithout this additional call
  if(self.textArray.count == 0 && !self.choiceDialog) {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(dialogBoxAllTextFinished:)]) {
      [self.delegate dialogBoxAllTextFinished:self];
    }
    
    // Close dialog box if enabled when no more content to display
    if (self.closeWhenDialogFinished) {
      [self removeDialogBoxAndCleanUp];
    }
    return;
  }
  
  // Do nothing if we have no more words to display and choice dialog is displayed
  if (self.textArray.count == 0 &&
      self.choiceDialog.parent &&
      self.choiceDialog.visible) {
    return;
  }
  
  // Remove the text to be displayed from our text array
  NSString *text = self.textArray[0];
  [self.textArray removeObjectAtIndex:0];
  
  // Type the text
  self.currentPageTyped = NO;
  NSString *stringToType = text;
  if (self.prependText) {
    stringToType = [NSString stringWithFormat:@"%@%@", self.prependText, stringToType];
  }
  [self.label typeText:stringToType withDelay:self.typingDelay];
  self.label.delegate = self;
  self.label.visible = YES;
  self.currentTextPage += 1;
  
  // Update for any custom portrait
  if (self.customPortraitForPages) {
    NSString *pageString = [NSString stringWithFormat:@"%d", self.currentTextPage];
    id value = [self.customPortraitForPages valueForKey:pageString];
    if (value && [value isKindOfClass:[CCSprite class]])
    {
      [self updatePortraitTextureWithSprite:(CCSprite *)value];
    }
    else if (value && [value isKindOfClass:[NSString class]])
    {
      CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:(NSString *)value];
      [self updatePortraitTextureWithSprite:sprite];
    }
  }else {
    [self updatePortraitTextureWithSprite:self.defaultPortraitSprite];
  }
}

- (void)updatePortraitTextureWithSprite:(CCSprite *)sprite
{
  // Update dialog portrait displayed image if texture is different
  if (self.portrait.texture != sprite.texture) {
    [self.portrait setTextureAtlas:sprite.textureAtlas];
    [self.portrait setTexture:sprite.texture];
    [self.portrait setDisplayFrame:sprite.displayFrame];
  }
}

- (void)showChoiceDialog
{
  // We add the choice dialog to the parent instead of the dialog box
  if (self.choiceDialog && !self.choiceDialog.parent) {
    self.choiceDialog.visible = YES;
    [self.parent addChild:self.choiceDialog z:self.zOrder + 1];
  }
}

- (void)removeChoiceDialogAndCleanUp
{
  if (self.choiceDialog && self.choiceDialog.parent) {
    [self.choiceDialog removeFromParentAndCleanup:YES];
    self.choiceDialog.delegate = nil;
  }
}

- (void)removeDialogBoxAndCleanUp
{
  [self removeChoiceDialogAndCleanUp];
  [self removeFromParentAndCleanup:YES];
  self.delegate = nil;
  self.label.delegate = nil;
  self.handleTapInputs = NO;
}


#pragma mark - DLAutoTypeLabelBMDelegate

- (void)autoTypeLabelBMTypingFinished:(DLAutoTypeLabelBM *)sender
{
  self.currentPageTyped = YES;
  
  // Show the choice dialog after all words are displayed and we have a dialog created
  if (self.textArray.count == 0 &&
      self.choiceDialog)
  {
    [self showChoiceDialog];
    
    // Inform delegate we finished all text
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(dialogBoxAllTextFinished:)]) {
      [self.delegate dialogBoxAllTextFinished:self];
    }
  }
  
  // Show blinking page finished indicator after every page except last
  if (self.textArray.count != 0)
  {
    // Animate arrow cursor blinking
    id blink = [CCBlink actionWithDuration:5.0 blinks:5.0 / self.customizer.speedPerPageFinishedIndicatorBlink];
    [self.customizer.pageFinishedIndicator
     runAction:[CCRepeatForever actionWithAction:blink]];
  }  
}


#pragma mark - DLChoiceDialogDelegate

- (void)choiceDialogLabelSelected:(DLChoiceDialog *)sender
                       choiceText:(NSString *)text
                      choiceIndex:(NSUInteger)index
{
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(dialogBoxChoiceSelected:choiceText:choiceIndex:)])
  {
    [self.delegate dialogBoxChoiceSelected:self
                                choiceText:text
                               choiceIndex:index];
    
    // Close dialog box when choice is selected
    if (self.closeWhenDialogFinished) {
      [self removeDialogBoxAndCleanUp];
    }
  }
}


#pragma mark - CCTouchOneByOneDelegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
  BOOL shouldClaim = YES;
  
  if (self.handleOnlyTapInputsInDialogBox) {
    CGPoint touchPoint = [self convertTouchToNodeSpaceAR:touch];
    CGRect relativeRect = self.bgSprite.boundingBox;
    shouldClaim = CGRectContainsPoint(relativeRect, touchPoint);
  }
  
  // Dialog box should not handle any touches when choice dialogs is showing
  if (self.choiceDialog && self.choiceDialog.parent && self.choiceDialog.visible) {
    shouldClaim = NO;
  }
  
  if (shouldClaim)
  {
    if (self.tapToFinishCurrentPage) {
      [self finishCurrentPageOrAdvance];
    }else if (self.currentPageTyped) {
      [self advanceToNextPage];
    }
  }
  
  return shouldClaim;
}


#pragma mark - Method overrides

- (void)onEnter
{
  [super onEnter];
  
  // start first page
  [self advanceToNextPage];
  
  // Animate in our portrait its outsidie of dialog box and animation is enabled
  if (self.defaultPortraitSprite &&
      !self.customizer.portaitInsideDialog &&
      self.customizer.animateOutsidePortraitIn)
  {
    CGPoint finalPos = self.portrait.position;
    
    // Calculate initial position
    CGPoint startingPos = CGPointZero;
    CGSize portraitSize = self.portrait.contentSize;
    if (self.customizer.portraitPosition == kDialogPortraitPositionLeft) {
      startingPos = ccpSub(finalPos, CGPointMake(portraitSize.width / 4, 0));
    }else {
      startingPos = ccpAdd(finalPos, CGPointMake(portraitSize.width / 4, 0));
    }
    
    // Animate move and fade in
    self.portrait.position = startingPos;
    id move = [CCMoveTo actionWithDuration:kPortraitMoveAnimationDuration
                                  position:finalPos];
    //    id moveEaseOut = [CCEaseOut actionWithAction:move
    //                                            rate:kPortraitMoveAnimationEaseRate];
    id fadeIn = [CCFadeIn actionWithDuration:kPortraitFadeAnimationDuration];
    [self.portrait runAction:[CCSpawn actions:move, fadeIn, nil]];
  }
}

@end
