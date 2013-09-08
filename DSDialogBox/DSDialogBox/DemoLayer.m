//
//  DemoLayer.m
//  DSDialogBox
//
//  Created by Draco on 2013-09-04.
//  Copyright 2013 Draco Li. All rights reserved.
//

#import "DemoLayer.h"

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
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"other-images.plist"];
    
    // TODO: Add in a hint label
    
    NSArray *words = [NSArray arrayWithObjects:
                  @"This is the demo for DLDialogBox, \nit is pretty powerful.",
                  @"You can use this dialog box to create a lot\n of different dialog boxes.",
                  @"You can make this dialog box write text simply by providing an array of words.",
                  @"Oh yeah did I mention DLDialogBox autowraps to the size of your dialog box?",
                  @"But of course you can also customize\nnew newlines anywhere if you want. ",nil];
    
    NSArray *wordsChoices = [NSArray arrayWithObjects:
                             @"DLDialog can be fully customized is almost \nevery aspect.",
                             @"You can customize dialog border, portraits, text, etc.\n ALso did I mention DLDialogBox can also handle \ngetting choice inputs from the player??",
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
      
      DLDialogBox *first = [DLDialogBox dialogWithTextArray:words
                                            defaultPortrait:nil];
      first.handleOnlyTapInputsInDialogBox = YES;
      first.anchorPoint = ccp(0, 0);
      first.position = ccp(0, 0);
      [self addChild:first z:1];
      
      self.currentDialog = first;
    }];
    item1.fontSize = fontSize;
    
    CCMenuItemFont *item2 = [CCMenuItemFont itemWithString:@"Dialog #2" block:^(id sender){
      [self removeAnyDialog];
      
      DLDialogBox *second = [DLDialogBox dialogWithTextArray:wordsChoices
                                             defaultPortrait:portrait
                                                     choices:choices
                                                  customizer:[DLDialogBoxCustomizer defaultCustomizer]];
      second.handleOnlyTapInputsInDialogBox = YES;
      second.anchorPoint = ccp(0, 0);
      second.position = ccp(0, 0);
      second.tapToFinishCurrentPage = YES;
      [self addChild:second z:1];
      
      self.currentDialog = second;
    }];
    item2.fontSize = fontSize;
    
    CCMenuItemFont *item3 = [CCMenuItemFont itemWithString:@"Dialog #3" block:^(id sender){
      [self removeAnyDialog];
      
      // Customize dialog box
      DLDialogBoxCustomizer *customizer = [DLDialogBoxCustomizer defaultCustomizer];
      customizer.borderSpriteFileName = @"dialog_border.png";
      customizer.borderLeftCapWidth = 32.0;
      customizer.borderTopCapWidth = 32.0;
      customizer.dialogTextOffset = ccp(10, 10);
      customizer.portraitOffset = ccp(0, 0);
      customizer.portraitPosition = kDialogPortraitPositionRight;
      customizer.portaitInsideDialog = NO;
      customizer.animateOutsidePortraitIn = YES;
      
      // Customize choice dialog
      DLChoiceDialogCustomizer *choiceCustomizer = [DLChoiceDialogCustomizer defaultCustomizer];
      choiceCustomizer.borderSpriteFileName =  @"dialog_border.png";
      choiceCustomizer.borderLeftCapWidth = 32.0;
      choiceCustomizer.borderTopCapWidth = 32.0;
      choiceCustomizer.contentOffset = ccp(0, 0);
      choiceCustomizer.paddingBetweenChoices = 0;
      
      // Customize choice dialog's label
      DLSelectableLabelCustomizer *labelCustomizer = [DLSelectableLabelCustomizer defaultCustomizer];
      labelCustomizer.textOffset = ccp(15, 5);
      labelCustomizer.preSelectedBackgroundColor = ccc4(0, 200, 50, 0.8*255);
      labelCustomizer.selectedBackgroundColor = ccc4(0, 225, 100, 0.8*255);
      
      choiceCustomizer.labelCustomizer = labelCustomizer;
      customizer.choiceDialogCustomizer = choiceCustomizer;
      
      DLDialogBox *third = [DLDialogBox dialogWithTextArray:wordsChoices
                                            defaultPortrait:portrait
                                                    choices:choices
                                                 customizer:customizer];
      third.handleOnlyTapInputsInDialogBox = YES;
      
      third.anchorPoint = ccp(0, 0);
      third.position = ccp(0, 0);
      [self addChild:third z:1];
      
      self.currentDialog = third;
    }];
    item3.fontSize = fontSize;
    
    CCMenu *demoMenu = [CCMenu menuWithItems:item1, item2, item3, nil];
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
  if (self.currentDialog) {
    [self.currentDialog removeDialogBoxAndCleanUp];
  }
}


#pragma mark ccTouch Delegate

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
