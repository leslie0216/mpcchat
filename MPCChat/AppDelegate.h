//
//  AppDelegate.h
//  MPCChat
//
//  Created by Chengzhao Li on 2016-02-24.
//  Copyright © 2016 Chengzhao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPCHandler.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) MPCHandler *mpcHandler;


@end

