//
//  LYGCDMulticastDelegate.h
//  LYEventBus
//
//  Created by chairman on 16/10/13.
//  Copyright © 2016年 LaiYoung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYGCDMulticastDelegate : NSObject
- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
@end
