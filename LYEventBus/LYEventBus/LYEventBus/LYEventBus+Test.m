//
//  LYEventBus+Test.m
//  LYEventBus
//
//  Created by chairman on 16/10/16.
//  Copyright © 2016年 LaiYoung. All rights reserved.
//

#import "LYEventBus+Test.h"

@implementation LYEventBus (Test)

- (void)test {
    [[self valueForKey:@"eventBusDelegate"] eventTest];
}

- (void)testWithArgument:(NSString *)argument {
    [[self valueForKey:@"eventBusDelegate"] eventTestWithArgument:argument];
}

@end
