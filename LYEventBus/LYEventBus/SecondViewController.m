//
//  SecondViewController.m
//  LYEventBus
//
//  Created by chairman on 16/10/14.
//  Copyright © 2016年 LaiYoung. All rights reserved.
//


/** 屏幕的SIZE */
#define SCREEN_SIZE [[UIScreen mainScreen] bounds].size

#import "SecondViewController.h"
#import "LYEventBus.h"
#import "LYEventBus+Test.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[LYEventBus shareInstance] addObserver:self observerQueue:dispatch_get_main_queue()];
    
    UIButton *sendMessageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendMessageBtn.frame = CGRectMake((SCREEN_SIZE.width - 150)/2, (SCREEN_SIZE.height - 30)/2, 150, 30);
    [sendMessageBtn setTitle:@"sendMessage" forState:UIControlStateNormal];
    [sendMessageBtn setBackgroundColor:[UIColor grayColor]];
    [sendMessageBtn addTarget:self action:@selector(sendMessge) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:sendMessageBtn];
}

- (void)dealloc {
    [[LYEventBus shareInstance] removeObserver:self observerQueue:dispatch_get_main_queue()];
}

- (void)sendMessge {
//    [[LYEventBus shareInstance] test];
    [[LYEventBus shareInstance] testWithArgument:@"argument"];
}

- (void)eventTest {
    NSLog(@"this is EventBus test");
}

- (void)eventTestWithArgument:(NSString *)argument {
    NSLog(@"argument = %@",argument);
}

- (void)applicationDidFinishLaunchingNotification {
    NSLog(@"%s,line = %i,%@",__func__,__LINE__,[NSThread currentThread]);
}
- (void)applicationWillEnterForegroundNotification {
    NSLog(@"%s,line = %i,%@",__func__,__LINE__,[NSThread currentThread]);
}

- (void)applicationDidBecomeActiveNotification {
    NSLog(@"%s,line = %i,%@",__func__,__LINE__,[NSThread currentThread]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
