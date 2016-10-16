//
//  LYEventBus.h
//  LYEventBus
//
//  Created by chairman on 16/10/13.
//  Copyright © 2016年 LaiYoung. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LYEventBusProtocol <NSObject>

//Application 状态
- (void)applicationDidFinishLaunchingNotification;
- (void)applicationWillEnterForegroundNotification;
- (void)applicationDidBecomeActiveNotification;
- (void)applicationWillResignActiveNotification;
- (void)applicationDidEnterBackgroundNotification;
- (void)applicationWillTerminateNotification;

@end

@interface LYEventBus : NSObject

+ (instancetype)shareInstance;
- (void)addObserver:(id)observer observerQueue:(dispatch_queue_t)delegateQueue;
- (void)removeObserver:(id)observer observerQueue:(dispatch_queue_t)delegateQueue;

@end
