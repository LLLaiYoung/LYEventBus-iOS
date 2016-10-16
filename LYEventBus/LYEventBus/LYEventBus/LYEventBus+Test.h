//
//  LYEventBus+Test.h
//  LYEventBus
//
//  Created by chairman on 16/10/16.
//  Copyright © 2016年 LaiYoung. All rights reserved.
//

#import "LYEventBus.h"

@protocol LYEventBusProtocolTest <NSObject>
/** 实现该协议，接受方法 */
- (void)eventTest;

@end


@interface LYEventBus (Test)
/** 调用这个方法发送消息 */
- (void)test;

@end
