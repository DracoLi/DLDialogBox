//
//  DemoLayer.m
//  DSDialogBox
//
//  Created by Draco on 2013-09-04.
//  Copyright 2013 Draco Li. All rights reserved.
//

#import "DemoLayer.h"


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
  if (self = [super init]) {
    
  }
}

@end
