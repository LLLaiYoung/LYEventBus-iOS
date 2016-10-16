//
//  ViewController.m
//  LYEventBus
//
//  Created by chairman on 16/10/13.
//  Copyright © 2016年 LaiYoung. All rights reserved.
//

#import "ViewController.h"
#import "LYEventBus.h"
#import "SecondViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LYEventBus shareInstance] addObserver:self observerQueue:dispatch_get_main_queue()];
}

- (void)dealloc {
    [[LYEventBus shareInstance] removeObserver:self observerQueue:dispatch_get_main_queue()];
}

- (void)applicationWillEnterForegroundNotification {
    NSLog(@"applicationWillEnterForegroundNotification");
}

- (void)applicationDidBecomeActiveNotification {
    NSLog(@"applicationDidBecomeActiveNotification");
}

- (void)applicationDidFinishLaunchingNotification {
    NSLog(@"applicationDidFinishLaunchingNotification");
}
- (IBAction)push:(UIButton *)sender {
    SecondViewController *secondVC = [SecondViewController new];
    [self.navigationController pushViewController:secondVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
