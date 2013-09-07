//
//  DemoLayer.h
//  DSDialogBox
//
//  Created by Draco on 2013-09-04.
//  Copyright 2013 Draco Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DLDialogBox.h"

@interface DemoLayer : CCLayer
<DLDialogBoxDelegate>

+ (CCScene *)scene;

@end
