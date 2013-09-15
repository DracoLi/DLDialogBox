//
//  DSChatBox.m
//  sunny
//
//  Created by Draco on 2013-09-01.
//  Copyright 2013 Draco. All rights reserved.
//

#import "DLDialogBox.h"
#import "CCSprite+GLBoxes.h"
#import "CCScale9Sprite.h"

// Constants for z indexes
#define kBackgroundSpriteZIndex 0
#define kPageTextZIndex 1
#define kPageIndicatorZIndex 2

// Other constants
#define kDefaultTypingSpeed 0.02

@implementation DLDialogBoxCustomizer

+ (DLDialogBoxCustomizer *)defaultCustomizer
{
  DLDialogBoxCustomizer *customizer = [[DLDialogBoxCustomizer alloc] init];
  
  // Look
  customizer.dialogSize = CGSizeMake([[CCDirector sharedDirector] winSize].width,
                                     kDialogHeightNormal);
  customizer.backgroundColor = ccc4(0, 0, 0, 0.8*255);
  customizer.pageFinishedIndicator = [CCSprite spriteWithFile:@"arrow_cursor.png"];
  customizer.speedPerPageFinishedIndicatorBlink = 1.0;
  customizer.dialogTextInsets = UIEdgeInsetsMake(10, 10, 10, 10);
  customizer.portraitPosition = kDialogPortraitPositionLeft;
  customizer.portraitInsets = UIEdgeInsetsZero;
  customizer.portraitInsideDialog = NO;
  customizer.fntFile = @"demo_fnt.fnt";;
  customizer.choiceDialogCustomizer = [DLChoiceDialogCustomizer defaultCustomizer];
  
  // Functionalities
  customizer.tapToFinishCurrentPage = YES;
  customizer.handleTapInputs = YES;
  customizer.handleOnlyTapInputsInDialogBox = YES;
  customizer.typingDelay = kDefaultTypingSpeed;
  customizer.closeWhenDialogFinished = YES;
  
  return customizer;
}

@end

@interface DLDialogBox ()
@property (nonatomic, strong) NSMutableArray *textArray;
@property (nonatomic, strong) CCNode *bgSprite;
@property (nonatomic, readwrite) BOOL currentPageTyped;

- (void)initializeDialogBoxWithCurrentCustomizer;
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
                  choices:(NSArray *)choices
          defaultPortrait:(CCSprite *)portrait
{
  return [[self alloc] initWithTextArray:texts
                         defaultPortrait:portrait
                                 choices:choices
                              customizer:[DLDialogBoxCustomizer defaultCustomizer]];
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
    _currentPageTyped = NO;
    _textArray = [texts mutableCopy];
    _initialTextArray = texts;
    
    // Create our dialog content node
    _dialogContent = [CCNode node];
    _dialogContent.anchorPoint = ccp(0, 0);
    _dialogContent.position = ccp(0, 0);
    _dialogContent.contentSize = customizer.dialogSize;
    [self addChild:_dialogContent z:kBackgroundSpriteZIndex];
    
    // Add in general portrait
    _defaultPortraitSprite = portrait;
    _portrait = [CCSprite node];
    _portrait.anchorPoint = ccp(0, 0);
    [self updatePortraitTextureWithSprite:_defaultPortraitSprite];
    
    // Add portrait to dialog content node if its inside the dialog
    if (customizer.portraitInsideDialog) {
      [_dialogContent addChild:_portrait z:kBackgroundSpriteZIndex + 1];
    }else {
      [self addChild:_portrait z:kBackgroundSpriteZIndex - 1];
    }
    
    // Add in our dialog label
    _dialogLabel = [DLAutoTypeLabelBM labelWithString:@"" fntFile:customizer.fntFile];
    _dialogLabel.delegate = self;
    _dialogLabel.anchorPoint = ccp(0, 1);
    _dialogLabel.visible = NO;
    [self.dialogContent addChild:_dialogLabel z:kPageTextZIndex];
    
    // Set our customizer and layout the UI for our dialog box
    _customizer = customizer;
    [self initializeDialogBoxWithCurrentCustomizer];
    
    // Create choices and our choice dialog
    // Adding choices after customizer allows us to create a choice dialog
    // with the current customizer
    self.choices = choices;
    
    // Add touch dispatcher
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self
                                                              priority:kDialogBoxTouchPriority
                                                       swallowsTouches:NO];
  }
  
  return self;
}


#pragma mark - Custom property setters/getters

- (void)setChoices:(NSArray *)choices
{
  if (_choices != choices) {
    _choices = choices;
    
    // Remove existing choice dialogs
    if (self.choiceDialog) {
      [self.choiceDialog removeFromParentAndCleanup:YES];
      self.choiceDialog.delegate = nil;
    }
    
    // Make new choice dialog with our customizer
    if (choices && choices.count > 0)
    {
      // If no specified fntFile for the choice dialog, we will use the dialog's font file
      if (!self.customizer.choiceDialogCustomizer.fntFile) {
        self.customizer.choiceDialogCustomizer.fntFile = self.customizer.fntFile;
      }
      self.choiceDialog = [DLChoiceDialog dialogWithChoices:choices
                                           dialogCustomizer:self.customizer.choiceDialogCustomizer];
      self.choiceDialog.delegate = self;
    }
  }
}

- (NSUInteger)currentTextPage
{
  int currentCount = self.textArray.count;
  int oriCount = self.initialTextArray.count;
  return oriCount - currentCount;
}


#pragma mark - Public methods

- (void)finishCurrentPageOrAdvance
{
  // If current page is still being animated, then finish it
  if (self.dialogLabel.currentlyTyping) {
    [self finishCurrentPage];
  }else if (self.currentPageTyped) {
    // If current page is already displayed go to next page
    [self advanceToNextPage];
  }
}

- (void)finishCurrentPage
{
  // Finish typing current page if typing has not finished.
  // If typing has already finished then this method would do nothing and the
  // typing finished delegate wont be called.
  [self.dialogLabel finishTypingAnimation];
}

- (void)advanceToNextPage
{
  // If choice dialog is on, dialog will not be able to advance
  if (self.choiceDialog && self.choiceDialog.parent && self.choiceDialog.visible) {
    return;
  }
  
  // Alert delegate if no more text and has no choice dialog.
  // If does have choice dialog, we alert all text finished whithout this additional call
  if(self.textArray.count == 0 && !self.choiceDialog) {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(dialogBoxAllTextFinished:)]) {
      [self.delegate dialogBoxAllTextFinished:self];
    }
    
    // Close dialog box if enabled when no more content to display
    if (self.customizer.closeWhenDialogFinished) {
      [self removeDialogBoxAndCleanUp];
    }
    return;
  }
  
  // Stop any existing blinking cursor
  if (self.customizer.pageFinishedIndicator) {
    [self.customizer.pageFinishedIndicator stopAllActions];
    self.customizer.pageFinishedIndicator.visible = NO;
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
  [self.dialogLabel typeText:stringToType withDelay:self.customizer.typingDelay];
  self.dialogLabel.visible = YES;
  
  // Update for any custom portrait for this page
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
    }else {
      [self updatePortraitTextureWithSprite:self.defaultPortraitSprite];
    }
  }else {
    // Make sure we are displaying the default sprite.
    [self updatePortraitTextureWithSprite:self.defaultPortraitSprite];
  }
}

- (void)updatePortraitTextureWithSprite:(CCSprite *)sprite
{
  // Update dialog portrait displayed image if texture is different
  if (self.portrait.texture != sprite.texture) {
    [self.portrait setTextureAtlas:sprite.textureAtlas];
    [self.portrait setTexture:sprite.texture];
    [self.portrait setTextureRect:sprite.textureRect];
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
  self.dialogLabel.delegate = nil;
  [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}


#pragma mark - Private methods

- (void)initializeDialogBoxWithCurrentCustomizer
{
  DLDialogBoxCustomizer *customizer = _customizer;
  
  // Create the dialog background image
  CGSize dialogSize = customizer.dialogSize;
  if (customizer.backgroundSpriteFrameName)
  {
    _bgSprite = [CCScale9Sprite spriteWithSpriteFrameName:customizer.backgroundSpriteFrameName];
    [_bgSprite setContentSize:dialogSize];
  }
  else if (customizer.backgroundSpriteFile)
  {
    _bgSprite = [CCScale9Sprite spriteWithFile:customizer.backgroundSpriteFile];
    [_bgSprite setContentSize:dialogSize];
  }
  else {
    // If no border just create choice dialog background
    _bgSprite = [CCSprite rectangleOfSize:dialogSize
                                    color:customizer.backgroundColor];
  }
  _bgSprite.anchorPoint = ccp(0, 0);
  _bgSprite.position = ccp(0, 0);
  [self.dialogContent addChild:_bgSprite z:kBackgroundSpriteZIndex];
  
  // Adjust label text position
  CGFloat labelY = dialogSize.height - customizer.dialogTextInsets.top;
  self.dialogLabel.position = ccp(customizer.dialogTextInsets.left, labelY);
  
  // If portrait is on the left and inside, we must adjust label position to make room
  if (self.defaultPortraitSprite && customizer.portraitInsideDialog &&
      customizer.portraitPosition == kDialogPortraitPositionLeft)
  {
    CGFloat x = customizer.portraitInsets.left + _defaultPortraitSprite.contentSize.width + \
                customizer.portraitInsets.right + customizer.dialogTextInsets.left;
    self.dialogLabel.position = ccp(x, labelY);
  }
  
  // Adjust label width to fit inside dialog
  CGFloat width = customizer.dialogTextInsets.left - dialogSize.width - \
                  customizer.dialogTextInsets.right;
  if (self.defaultPortraitSprite && customizer.portraitInsideDialog) {
    width = width - _defaultPortraitSprite.contentSize.width - \
            customizer.portraitInsets.left - customizer.portraitInsets.right;
  }
  [self.dialogLabel setWidth:width];
  
  // Adjust portrait image position
  CGSize portraitSize = _defaultPortraitSprite.contentSize;
  UIEdgeInsets portraitInsets = customizer.portraitInsets;
  if (customizer.portraitPosition == kDialogPortraitPositionLeft)
  {
    CGFloat x = portraitInsets.left;
    CGFloat y = portraitInsets.bottom;
    if (customizer.portraitInsideDialog) {
      y = dialogSize.height - portraitInsets.top - portraitSize.height;
    }
    self.portrait.position = ccp(x, y);
  }
  else
  {
    CGFloat x = dialogSize.width - portraitInsets.right - portraitSize.width;
    CGFloat y = portraitInsets.bottom;
    if (customizer.portraitInsideDialog) {
      y = dialogSize.height - portraitInsets.top - portraitSize.height;
    }
    self.portrait.position = ccp(x, y);
  }
  
  // Create our new page indicator
  if (customizer.pageFinishedIndicator) {
    CCSprite *indicator = customizer.pageFinishedIndicator;
    indicator.anchorPoint = ccp(1, 0);
    
    // By default the indicator's insets uses the same one as the dialogTextInsets
    indicator.position = ccp(dialogSize.width - customizer.dialogTextInsets.right,
                             customizer.dialogTextInsets.bottom);
    indicator.visible = NO;
    [self.dialogContent addChild:indicator z:kPageIndicatorZIndex];
  }
}


#pragma mark - DLAutoTypeLabelBMDelegate

- (void)autoTypeLabelBMTypingFinished:(DLAutoTypeLabelBM *)sender
{
  self.currentPageTyped = YES;
  
  // Show the choice dialog after all words are displayed and we have a choice dialog
  if (self.textArray.count == 0 && self.choiceDialog)
  {
    [self showChoiceDialog];
    
    // Inform delegate we finished all text
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(dialogBoxAllTextFinished:)]) {
      [self.delegate dialogBoxAllTextFinished:self];
    }
  }
  
  // Show blinking page finished indicator after every page except last
  if (self.textArray.count != 0 && self.customizer.pageFinishedIndicator)
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
  // Inform delegate
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(dialogBoxChoiceSelected:choiceDialog:choiceText:choiceIndex:)])
  {
    [self.delegate dialogBoxChoiceSelected:self
                              choiceDialog:self.choiceDialog
                                choiceText:text
                               choiceIndex:index];
  }
  
  // Close dialog box when choice is selected
  if (self.customizer.closeWhenDialogFinished) {
    [self removeDialogBoxAndCleanUp];
  }
}


#pragma mark - CCTouchOneByOneDelegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
  // If the dialog box shouldn't handle any input, we claim none and do nothing.
  if (!self.customizer.handleTapInputs) {
    return NO;
  }
  
  BOOL shouldClaim = YES;
  
  // Check if we should only respond to touch in dialog box
  if (shouldClaim && self.customizer.handleOnlyTapInputsInDialogBox) {
    CGPoint touchPoint = [self convertTouchToNodeSpaceAR:touch];
    CGRect relativeRect = self.dialogContent.boundingBox;
    shouldClaim = CGRectContainsPoint(relativeRect, touchPoint);
  }
  
  // Dialog box should not handle any touches when choice dialogs is showing
  if (shouldClaim &&
      self.choiceDialog &&
      self.choiceDialog.parent &&
      self.choiceDialog.visible) {
    shouldClaim = NO;
  }
  
  if (shouldClaim) {
    // If tap to finish current page is enabled, we finish current page or advance
    // on touch input. If not, we only advance if current typing is finished.
    if (self.customizer.tapToFinishCurrentPage) {
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
  
  // Start first page automatically on page enter.
  [self advanceToNextPage];
  
  // Custom on enter animations
  if (self.customizer.onEnterDialogAnimation) {
    self.customizer.onEnterDialogAnimation(self);
  }
}

- (void)onExit
{
  [super onExit];
  
  // Custom on exit animatinos
  if (self.customizer.onExitDialogAnimation) {
    self.customizer.onExitDialogAnimation(self);
  }
}

@end
