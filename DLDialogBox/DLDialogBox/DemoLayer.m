//
//  DemoLayer.m
//  DSDialogBox
//
//  Created by Draco on 2013-09-04.
//  Copyright 2013 Draco Li. All rights reserved.
//

#import "DemoLayer.h"
#import "DLDialogPresets.h"
#import "SimpleAudioEngine.h"

typedef enum {
  kBasicDialog = 0,
  kBasicDialogWithChoicesAndPortrait,
  kStyledDialogWithChoiceAndPortrait,
  kStyledDialogWithInnerPortrait
} DialogTypes;

@interface DemoLayer ()
@property (nonatomic, strong) CCTMXTiledMap *tileMap;
@property (nonatomic, copy) NSArray *demoDialogs;
@property (nonatomic, strong) DLDialogBox *currentDialog;
@end

@implementation DemoLayer

+ (CCScene *)scene
{
  CCScene *sc = [CCScene node];
  DemoLayer *demo = [DemoLayer node];
  [sc addChild:demo];
  return sc;
}

- (id)init
{
  if (self = [super init])
  {
    // Load in map
    _tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"demo-room.tmx"];
    _tileMap.anchorPoint = ccp(0,0);
    [self addChild:self.tileMap z:-1];
    
    // Load in some of the images we gonna use for our dialog
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"portraits.plist"];
    
    // TODO: Add in a hint label
    
    NSArray *words = [NSArray arrayWithObjects:
                  @"This is the demo for DLDialogBox, \nit is pretty powerful.",
                  @"You can use this dialog box to create a lot\n of different dialog boxes.",
                  @"You can make this dialog box write text simply by providing an array of words.",
                  @"Oh yeah did I mention DLDialogBox autowraps to the size of your dialog box?",
                  @"But of course you can also customize\nnew newlines anywhere if you want. ",nil];
    
    NSArray *wordsChoices = [NSArray arrayWithObjects:
                             @"DLDialog can be fully customized is almost \nevery aspect.",
                             @"You can customize borders, portraits, text, etc. DLDialogBox also handles getting choice inputs from the player ;D",
                             @"How awesome is DLDialogBox?!\nYou tell me!", nil];
    NSArray *choices = [NSArray arrayWithObjects:
                        @"Pretty Damn Awesome",
                        @"So awesome I'm dead",
                        @"Too awesome for words",
                        @"I'm not awesome", nil];
    CCSprite *portrait = [CCSprite spriteWithSpriteFrameName:@"sun-face.png"];
    
    
    // TODO: Create the forth dialog with inner portrait
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGFloat topPadding = 40;
    CGFloat fontSize = 20.0;
    
    CCMenuItemFont *item1 = [CCMenuItemFont itemWithString:@"Dialog #1" block:^(id sender){
      [self removeAnyDialog];
      
      DLDialogBoxCustomizer *customizer = [DLDialogBoxCustomizer defaultCustomizer];
      customizer.dialogSize = CGSizeMake(customizer.dialogSize.width, kDialogBoxHeightSmall);
      customizer.closeWhenDialogFinished = NO;
      customizer.tapToFinishCurrentPage = NO;
//      customizer.handleOnlyTapInputsInDialogBox = NO;
      DLDialogBox *first = [DLDialogBox dialogWithTextArray:words
                                            defaultPortrait:nil customizer:customizer];
      first.anchorPoint = ccp(0, 0);
      first.position = ccp(0, 0);
      [self addChild:first z:1];
      
      self.currentDialog = first;
    }];
    item1.fontSize = fontSize;
    
    CCMenuItemFont *item2 = [CCMenuItemFont itemWithString:@"Dialog #2" block:^(id sender){
      [self removeAnyDialog];
      
      // Customize the choice dialog box labels to align right
      DLDialogBoxCustomizer *customizer = [DLDialogBoxCustomizer defaultCustomizer];
      customizer.choiceDialogCustomizer.labelCustomizer.textAlignment = kCCTextAlignmentRight;
      customizer.typingSpeed = kTypingSpeedSlow;
      
      // TESTING: If choice dialog's fnt is not set, then it should uses the dialogbox's provide font file
      customizer.choiceDialogCustomizer.fntFile = nil;
      
      
      // Animate portrait
      customizer.showAnimation = ^(DLDialogBox *dialog) {
        [dialog animateOutsidePortraitInWithFadeIn:YES
                                          distance:40
                                          duration:0.3];
      };
      customizer.hideAnimation = ^(DLDialogBox *dialog) {
        [dialog animateOutsidePortraitOutWithFadeOut:YES
                                            distance:40
                                            duration:0.3];
        [dialog.dialogContent removeFromParentAndCleanup:YES];
        [dialog removeFromParentAndCleanupAfterDelay:0.3];
      };
      
      DLDialogBox *second = [DLDialogBox dialogWithTextArray:wordsChoices
                                             defaultPortrait:portrait
                                                     choices:choices
                                                  customizer:customizer];
      second.anchorPoint = ccp(0, 0);
      second.position = ccp(0, 0);
      [self addChild:second z:1];
      
      // Manually set the to be displayed position of the choice dialog
      second.choiceDialog.anchorPoint = ccp(1, 0);
      second.choiceDialog.position = ccp(winSize.width, 100);
      
      self.currentDialog = second;
    }];
    item2.fontSize = fontSize;
    
    CCMenuItemFont *item3 = [CCMenuItemFont itemWithString:@"Dialog #3" block:^(id sender){
      [self removeAnyDialog];
      
      // Customize dialog box
      DLDialogBoxCustomizer *customizer = [DLDialogPresets dialogCustomizerOfType:kDialogBoxCustomizerWithBasicAnimations];
      customizer.backgroundSpriteFile = @"fancy_border.png";
      customizer.dialogTextInsets = UIEdgeInsetsMake(15, 15, 15, 15);
      customizer.dialogSize = CGSizeMake(customizer.dialogSize.width - 50, kDialogBoxHeightNormal);
      customizer.portraitInsets = UIEdgeInsetsMake(0, -40, -10, 0);
      customizer.portraitPosition = kDialogPortraitPositionLeft;
      customizer.portraitInsideDialog = NO;
      customizer.speedPerPageFinishedIndicatorBlink = 0.5; // 2 blinks per second
//      customizer.handleTapInputs = NO;
//      customizer.closeWhenDialogFinished = YES;
      customizer.typingSpeed = kTypingSpeedFast;
      customizer.textPageStartedSoundFileName = @"text_page.wav";
//      customizer.handleOnlyTapInputsInDialogBox = NO;
//      customizer.closeWhenDialogFinished = NO;
//      customizer.swallowAllTouches = YES;
      
      // Customize choice dialog
      DLChoiceDialogCustomizer *choiceCustomizer = customizer.choiceDialogCustomizer;
      choiceCustomizer.backgroundSpriteFile =  @"fancy_border.png";
      choiceCustomizer.contentInsets = UIEdgeInsetsMake(8, 8, 30, 8);
      choiceCustomizer.spacingBetweenChoices = 0; // Label's closer together
//      choiceCustomizer.swallowAllTouches = YES;
      choiceCustomizer.preselectSoundFileName = @"preselected.wav";
      choiceCustomizer.selectedSoundFileName = @"selected.wav";
      choiceCustomizer.closeWhenChoiceSelected = NO;
      
      CGPoint finalPos = ccp(0, winSize.height);
      CGPoint startPos = ccpSub(finalPos, CGPointMake(100, 0));
      choiceCustomizer.showAnimation = [DLChoiceDialogCustomizer
                                        customShowAnimationWithStartPosition:startPos
                                        finalPosition:finalPos
                                        fadeIn:YES
                                        duration:0.14];
      choiceCustomizer.hideAnimation = [DLChoiceDialogCustomizer
                                        customHideAnimationWithFinalPosition:startPos
                                        fadeOut:YES duration:0.2];
      
      // Customize choice dialog's label
      DLSelectableLabelCustomizer *labelCustomizer = choiceCustomizer.labelCustomizer;
      labelCustomizer.textInsets = UIEdgeInsetsMake(5, 15, 5, 15); // More horizontal padding
      labelCustomizer.preSelectedBackgroundColor = ccc4(66, 139, 202, 255);
      labelCustomizer.selectedBackgroundColor = ccc4(22, 88, 146, 255);
      labelCustomizer.textAlignment = kCCTextAlignmentLeft;
      
      choiceCustomizer.labelCustomizer = labelCustomizer;
      customizer.choiceDialogCustomizer = choiceCustomizer;
      
      
      // Additional potraits
      NSDictionary *portraits = @{@"2": @"sun-face-ques.png", @"3": [CCSprite spriteWithSpriteFrameName:@"sun-face-sad.png"]};
      
      
      DLDialogBox *third = [DLDialogBox dialogWithTextArray:wordsChoices
                                            defaultPortrait:portrait
                                                    choices:choices
                                                 customizer:customizer];
      third.customPortraitForPages = portraits;
      third.anchorPoint = ccp(0, 0);
      third.position = ccp(25, 10); // Since dialog box is smaller than screen width, set an offset to center
      
      // Position choice dialog on top left
      third.choiceDialog.anchorPoint = ccp(0, 1);
      third.choiceDialog.position = ccp(0, winSize.height);
      
      third.prependText = @"Draco: ";
      third.delegate = self;
      third.tag = 3;
      
      [self addChild:third z:1];
      
      self.currentDialog = third;
    }];
    item3.fontSize = fontSize;
    
    
    CCMenuItemFont *item4 = [CCMenuItemFont itemWithString:@"Dialog #4" block:^(id sender){
      [self removeAnyDialog];
      
      // Customize dialog box
      DLDialogBoxCustomizer *customizer = [DLDialogPresets dialogCustomizerOfType:kDialogBoxCustomizerWithBasicAnimations];
      customizer.backgroundSpriteFile = @"fancy_border.png";
      customizer.dialogSize = CGSizeMake(customizer.dialogSize.width, kDialogBoxHeightNormal + 5);
      customizer.dialogTextInsets = UIEdgeInsetsMake(15, 10, 15, 15);
      customizer.portraitInsets = UIEdgeInsetsMake(10, 10, 10, 0);
      customizer.portraitPosition = kDialogPortraitPositionLeft;
//      customizer.dialogTextInsets = UIEdgeInsetsMake(15, 15, 20, 10);
//      customizer.portraitInsets = UIEdgeInsetsMake(10, 0, 10, 10);
//      customizer.portraitPosition = kDialogPortraitPositionRight;
      customizer.portraitInsideDialog = YES;
      customizer.handleOnlyTapInputsInDialogBox = NO;
      customizer.hidePageFinishedIndicatorOnLastPage = NO;
      
      // Inner portrait
      CCSprite *innerPortrait = [CCSprite spriteWithSpriteFrameName:@"face-port.png"];
      
      DLDialogBox *third = [DLDialogBox dialogWithTextArray:words
                                            defaultPortrait:innerPortrait
                                                 customizer:customizer];
      third.anchorPoint = ccp(0, 0);
      third.position = ccp(0, 0); // Since dialog box is smaller than screen width, set an offset to center
      
      // Position choice dialog on top left
      third.choiceDialog.anchorPoint = ccp(0, 1);
      third.choiceDialog.position = ccp(0, winSize.height);
      
      third.prependText = @"Cheese: ";
      third.delegate = self;
      
      third.dialogContent.anchorPoint = ccp(0, 1);
      third.dialogContent.position = ccp(0, [[CCDirector sharedDirector] winSize].height);
      
      third.customizer.showAnimation = [DLDialogBoxCustomizer
                                        customShowAnimationWithSlideDistance:-50
                                        fadeIn:YES duration:0.4];
      third.customizer.hideAnimation = [DLDialogBoxCustomizer
                                        customHideAnimationWithSlideDistance:-50
                                        fadeOut:YES duration:0.28];
      
      [self addChild:third z:1];
      
      self.currentDialog = third;
    }];
    item4.fontSize = fontSize;
    
    CCMenu *demoMenu = [CCMenu menuWithItems:item1, item2, item3, item4, nil];
    [demoMenu alignItemsHorizontallyWithPadding:10];
    demoMenu.position = ccp(winSize.width / 2, winSize.height - topPadding);
    [self addChild:demoMenu z:0];
    
    self.touchEnabled = YES;
    [self scheduleUpdate];
  }
  return self;
}


- (void)removeAnyDialog
{
  if (self.currentDialog && self.currentDialog.parent) {
    [self.currentDialog removeDialogBoxAndChoiceDialogFromParentAndCleanup];
    self.currentDialog = nil;
  }
}


#pragma mark ccTouch Delegate

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}


#pragma mark DLDialogBox Delegate

- (void)dialogBoxCurrentTextPageFinished:(DLDialogBox *)sender
                             currentPage:(NSUInteger)currentPage
{
  NSUInteger index = sender.currentTextPage;
  NSAssert(currentPage == index, @"Passed in current page must be same as currentTextPage");
  NSAssert(sender.currentPageTyped == YES, @"Current page typed must be TRUE");
  NSAssert(index > 0, @"current page must start from 1");
  
  // Test changing choice dialog's customizer properties on runtime
//  if (index == 2 && sender.tag == 3) {
//    sender.customizer.choiceDialogCustomizer.preselectEnabled = NO;
//    sender.customizer.choiceDialogCustomizer.preselectSoundFileName = @"preselected.wav";
//    sender.customizer.choiceDialogCustomizer.selectedSoundFileName = @"selected.wav";
//  }
  
  // Test changing typing speed after page
//  if (index == 2) {
//    sender.customizer.typingSpeed = kTypingSpeedSlow;
//  }
}

- (void)dialogBoxCurrentTextPageStarted:(DLDialogBox *)sender currentPage:(NSUInteger)currentPage
{
  // Test changing typing speed half way
//  sender.customizer.typingSpeed = kTypingSpeedSlow;
//  __weak DLDialogBox *weakSender = sender;
//  id block = [CCCallBlock actionWithBlock:^() {
//    weakSender.customizer.typingSpeed = kTypingSpeedSuperFast;
//  }];
//  [sender runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0], block, nil]];
}


- (void)dialogBoxAllTextFinished:(DLDialogBox *)sender
{
  NSUInteger index = sender.currentTextPage;
  NSAssert(index == sender.initialTextArray.count, @"This should be the last page");
}

- (void)dialogBoxChoiceSelected:(DLDialogBox *)sender choiceDialog:(DLChoiceDialog *)choiceDialog choiceText:(NSString *)text choiceIndex:(NSUInteger)index
{
  if (sender.tag == 10) {
    [sender playHideAnimationOrRemoveFromParent];
  }
}

@end
