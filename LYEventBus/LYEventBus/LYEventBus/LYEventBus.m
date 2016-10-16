//
//  LYEventBus.m
//  LYEventBus
//
//  Created by chairman on 16/10/13.
//  Copyright © 2016年 LaiYoung. All rights reserved.
//

#import "LYEventBus.h"
#import <objc/runtime.h>
#import "LYGCDMulticastDelegate.h"
#import <UIKit/UIKit.h>


@implementation LYEventBus

+ (instancetype)shareInstance {
    static LYEventBus *eventBus = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        eventBus = [[LYEventBus alloc] init];
    });
    return eventBus;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyApplicationWillEnterForegroundNotification:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyApplicationDidBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyApplicationDidFinishLaunchingNotification:)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}


- (void)addObserver:(id)observer observerQueue:(dispatch_queue_t)delegateQueue {
    [self.eventBusDelegate addDelegate:observer delegateQueue:delegateQueue];
}

- (void)removeObserver:(id)observer observerQueue:(dispatch_queue_t)delegateQueue {
    [self.eventBusDelegate removeDelegate:observer delegateQueue:delegateQueue];
}

#pragma mark - Private Methods

- (void)notifyApplicationWillEnterForegroundNotification:(NSNotification *)notification {
    [self.eventBusDelegate applicationWillEnterForegroundNotification];
}

- (void)notifyApplicationDidBecomeActiveNotification:(NSNotification *)notification {
    [self.eventBusDelegate applicationDidBecomeActiveNotification];
}

- (void)notifyApplicationDidFinishLaunchingNotification:(NSNotification *)notification {
    [self.eventBusDelegate applicationDidFinishLaunchingNotification];
}
#pragma mark - Getter Methods

- (LYGCDMulticastDelegate<LYEventBusProtocol> *)eventBusDelegate {
    id value = nil;
    @synchronized (self) {
        value = objc_getAssociatedObject(self, _cmd);
        if (!value) {
            value = [[LYGCDMulticastDelegate<LYEventBusProtocol> alloc] init];
            objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN);
        }
    }
    return value;
}
@end
