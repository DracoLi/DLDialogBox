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
                             @"You can customize borders, portraits, text, etc. ;D",
                             @"How awesome is DLDialogBox?!\nYou tell me!", nil];
    NSArray *choices = [NSArray arrayWithObjects:
                        @"Pretty Damn Awesome",
                        @"So awesome I'm dead",
                        @"Too awesome for words",
                        @"I'm not awesome", nil];
    CCSprite *portrait = [CCSprite spriteWithSpriteFrameName:@"sun-face.png"];
    CCSprite *innerPortrait = [CCSprite spriteWithSpriteFrameName:@"face-port.png"];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGFloat topPadding = 40;
    CGFloat fontSize = 20.0;
    
    CCMenuItemFont *item1 = [CCMenuItemFont itemWithString:@"Dialog #1" block:^(id sender){
      [self removeAnyDialog];
      
      DLDialogBox *first = [DLDialogBox dialogWithTextArray:words defaultPortrait:nil];
      [self addChild:first z:1];
      
      self.currentDialog = first;
    }];
    item1.fontSize = fontSize;
    
    CCMenuItemFont *item2 = [CCMenuItemFont itemWithString:@"Dialog #2" block:^(id sender){
      [self removeAnyDialog];
      
      DLDialogBoxCustomizer *customizer = [DLDialogBoxCustomizer defaultCustomizer];
      
      // Set the position of the choice dialog
      customizer.choiceDialogCustomizer.dialogAnchorPoint = ccp(1, 0);
      customizer.choiceDialogCustomizer.dialogPosition = ccp(winSize.width, 100);
      
      // Customize the choice dialog box labels to align right
      customizer = [DLDialogPresets customizeDialogWithPresets:
       @[@(kCustomizerWithDialogOnBottom), @(kCustomizerWithDialogCenterAligned),
         @(kCustomizerWithFadeAndSlideAnimationFromBottom),
         @(kCustomizerWithFancyUI)] baseCustomizer:customizer];
      
      DLDialogBox *second = [DLDialogBox dialogWithTextArray:wordsChoices
                                             defaultPortrait:portrait
                                                     choices:choices
                                                  customizer:customizer];
      [self addChild:second z:1];

      self.currentDialog = second;
    }];
    item2.fontSize = fontSize;
    
    CCMenuItemFont *item3 = [CCMenuItemFont itemWithString:@"Dialog #3" block:^(id sender){
      [self removeAnyDialog];
      
      DLDialogBoxCustomizer *customizer = [DLDialogBoxCustomizer defaultCustomizer];
      
      // Set the position of the choice dialog
      customizer.choiceDialogCustomizer.dialogAnchorPoint = ccp(1, 0);
      customizer.choiceDialogCustomizer.dialogPosition = ccp(winSize.width, 0);
      
      // Others
      customizer.portraitInsideDialog = YES;
      customizer.typingSpeed = kTypingSpeedNormal;
      customizer.dialogSize = CGSizeMake(customizer.dialogSize.width, innerPortrait.contentSize.height);
      customizer.dialogTextInsets = UIEdgeInsetsMake(7, 10, 7, 10);
      
      // Go through our customizer presets
      customizer = [DLDialogPresets customizeDialogWithPresets:
                    @[@(kCustomizerWithDialogOnTop),
                    @(kCustomizerWithDialogLeftAligned),
                    @(kCustomizerWithFadeAndSlideAnimationFromTop),
                    @(kCustomizerWithWhiteUI),
                    @(kCustomizerWithRetroSounds)] baseCustomizer:customizer];
      
      
      DLDialogBox *third = [DLDialogBox dialogWithTextArray:wordsChoices
                                             defaultPortrait:innerPortrait
                                                     choices:choices
                                                  customizer:customizer];
      third.prependText = @"Draco: ";
      third.delegate = self;
      third.tag = 3;
      
      [self addChild:third z:1];
      
      self.currentDialog = third;
    }];
    item3.fontSize = fontSize;
    
    
    CCMenuItemFont *item4 = [CCMenuItemFont itemWithString:@"Dialog #4" block:^(id sender){
      [self removeAnyDialog];
      
      DLDialogBoxCustomizer *customizer = [DLDialogBoxCustomizer defaultCustomizer];
      
      // Set the position of the choice dialog
      customizer.choiceDialogCustomizer.dialogAnchorPoint = ccp(1, 1);
      customizer.choiceDialogCustomizer.dialogPosition = ccp(winSize.width, winSize.height - 50);
      
      // Others
      customizer.portraitInsideDialog = YES;
      customizer.typingSpeed = kTypingSpeedSuperFast;
      customizer.dialogSize = CGSizeMake(customizer.dialogSize.width,
                                         innerPortrait.contentSize.height + 10);
      
      // Go through our customizer presets
      customizer = [DLDialogPresets customizeDialogWithPresets:
                    @[@(kCustomizerWithDialogOnBottom),
                    @(kCustomizerWithDialogCenterAligned),
                    @(kCustomizerWithFadeAndSlideAnimationFromBottom),
                    @(kCustomizerWithEightBitUI),
                    @(kCustomizerWithRetroSounds)] baseCustomizer:customizer];
      
      
      DLDialogBox *fourth = [DLDialogBox dialogWithTextArray:wordsChoices
                                            defaultPortrait:innerPortrait
                                                    choices:choices
                                                 customizer:customizer];
      fourth.delegate = self;
      fourth.tag = 4;
      [self addChild:fourth z:1];
      
      self.currentDialog = fourth;
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

- (void)dialogBoxChoiceSelected:(DLDialogBox *)sender
                     choiceText:(NSString *)text
                    choiceIndex:(NSUInteger)index
{
  if (sender.tag == 10) {
    [sender playHideAnimationOrRemoveFromParent];
  }
}

@end
