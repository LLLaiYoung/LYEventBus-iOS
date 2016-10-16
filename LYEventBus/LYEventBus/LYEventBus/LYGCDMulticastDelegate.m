//
//  LYGCDMulticastDelegate.m
//  LYEventBus
//
//  Created by chairman on 16/10/13.
//  Copyright © 2016年 LaiYoung. All rights reserved.
//

#import "LYGCDMulticastDelegate.h"
#import <libkern/OSAtomic.h>

#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
#import <AppKit/AppKit.h>
#endif

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface LYGCDMulticastDelegateNode : NSObject {
@private
    
#if __has_feature(objc_arc_weak)
    __weak id delegate;
#if !TARGET_OS_IPHONE
    __unsafe_unretained id unsafeDelegate; // Some classes don't support weak references yet (e.g. NSWindowController)
#endif
#else
    __unsafe_unretained id delegate;
#endif
    
    dispatch_queue_t delegateQueue;
}

- (id)initWithDelegate:(id)inDelegate delegateQueue:(dispatch_queue_t)inDelegateQueue;
#if __has_feature(objc_arc_weak)
@property (/* atomic */ readwrite, weak) id delegate;
#if !TARGET_OS_IPHONE
@property (/* atomic */ readwrite, unsafe_unretained) id unsafeDelegate;
#endif
#else
@property (/* atomic */ readwrite, unsafe_unretained) id delegate;
#endif

@property (nonatomic, readonly) dispatch_queue_t delegateQueue;

@end

@interface LYGCDMulticastDelegate()
{
    NSMutableArray *delegateNodes;
}

@end

@implementation LYGCDMulticastDelegate
- (instancetype)init
{
    self = [super init];
    if (self) {
        delegateNodes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
    if (!delegate) return;
    if (delegateQueue == NULL) return;
    LYGCDMulticastDelegateNode *node = [[LYGCDMulticastDelegateNode alloc] initWithDelegate:delegate delegateQueue:delegateQueue];
    [delegateNodes addObject:node];
}

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
    if (!delegate) return;
    NSUInteger i;
    for (i = [delegateNodes count]; i>0; i--) {
        LYGCDMulticastDelegateNode *node = delegateNodes[i-1];
        id nodeDelegate  = node.delegate;
#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null]) {
            nodeDelegate = node.unsafeDelegate;
        }
#endif
        if (delegate == nodeDelegate) {
            if (delegateQueue == NULL || delegateQueue == node.delegateQueue) {
                node.delegate = nil;
#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
                node.unsafeDelegate = nil;
#endif
                [delegateNodes removeObjectAtIndex:(i-1)];
            }
        }
    }
}

#pragma mark - Forward Method

/** methodSignatureForSelector:的作用在于为另一个类实现的消息创建一个有效的方法签名 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    for (LYGCDMulticastDelegateNode *node in delegateNodes)
    {
        id nodeDelegate = node.delegate;//拿到实现 Protocol 的对象
#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null])
            nodeDelegate = node.unsafeDelegate;
#endif
        //* 生成签名 */
        NSMethodSignature *result = [nodeDelegate methodSignatureForSelector:aSelector];
        
        if (result != nil)
        {
            return result;
        }
    }
    
    // This causes a crash...
    // return [super methodSignatureForSelector:aSelector];
    
    // This also causes a crash...
    // return nil;
    
    return [[self class] instanceMethodSignatureForSelector:@selector(doNothing)];
}

/** forwardInvocation:将选择器转发给一个真正实现了该消息的对象 */
- (void)forwardInvocation:(NSInvocation *)origInvocation
{
    SEL selector = [origInvocation selector];//拿到selector
    BOOL foundNilDelegate = NO;
    
    for (LYGCDMulticastDelegateNode *node in delegateNodes)
    {
        id nodeDelegate = node.delegate;
#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null])
            nodeDelegate = node.unsafeDelegate;
#endif
        
        if ([nodeDelegate respondsToSelector:selector])
        {
            // All delegates MUST be invoked ASYNCHRONOUSLY.
            
            NSInvocation *dupInvocation = [self duplicateInvocation:origInvocation];
            
            dispatch_async(node.delegateQueue, ^{ @autoreleasepool {
                
                [dupInvocation invokeWithTarget:nodeDelegate];//执行方法调用
                
            }});
        }
        else if (nodeDelegate == nil)
        {
            foundNilDelegate = YES;
        }
    }
    
    if (foundNilDelegate)
    {
        // At lease one weak delegate reference disappeared.
        // Remove nil delegate nodes from the list.
        //
        // This is expected to happen very infrequently.
        // This is why we handle it separately (as it requires allocating an indexSet).
        
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        
        NSUInteger i = 0;
        for (LYGCDMulticastDelegateNode *node in delegateNodes)
        {
            id nodeDelegate = node.delegate;
#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
            if (nodeDelegate == [NSNull null])
                nodeDelegate = node.unsafeDelegate;
#endif
            
            if (nodeDelegate == nil)
            {
                [indexSet addIndex:i];
            }
            i++;
        }
        
        [delegateNodes removeObjectsAtIndexes:indexSet];
    }
}

- (NSInvocation *)duplicateInvocation:(NSInvocation *)origInvocation
{
    NSMethodSignature *methodSignature = [origInvocation methodSignature];
    //* 调用的方法签名 */
    NSInvocation *dupInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [dupInvocation setSelector:[origInvocation selector]];//给调用方添加selector
    
    NSUInteger i, count = [methodSignature numberOfArguments];
    /**
     *  为什么是2？因为0已经被self(target)占用，1已经被_cmd(selector)占用 在NSInvocation的官方文档中已经说明
     */
    for (i = 2; i < count; i++)//count如果大于2就代表有参数
    {
        const char *type = [methodSignature getArgumentTypeAtIndex:i];
        
        if (*type == *@encode(BOOL))
        {
            BOOL value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(char) || *type == *@encode(unsigned char))
        {
            char value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(short) || *type == *@encode(unsigned short))
        {
            short value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(int) || *type == *@encode(unsigned int))
        {
            int value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(long) || *type == *@encode(unsigned long))
        {
            long value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(long long) || *type == *@encode(unsigned long long))
        {
            long long value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(double))
        {
            double value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(float))
        {
            float value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == '@')
        {
            void *value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == '^')
        {
            void *block;
            [origInvocation getArgument:&block atIndex:i];
            [dupInvocation setArgument:&block atIndex:i];
        }
        else
        {
            NSString *selectorStr = NSStringFromSelector([origInvocation selector]);
            
            NSString *format = @"Argument %lu to method %@ - Type(%c) not supported";
            NSString *reason = [NSString stringWithFormat:format, (unsigned long)(i - 2), selectorStr, *type];
            
            [[NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil] raise];
        }
    }
    
    [dupInvocation retainArguments];
    
    return dupInvocation;
}


@end

@implementation LYGCDMulticastDelegateNode

@synthesize delegate;       // atomic
#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
@synthesize unsafeDelegate; // atomic
#endif
@synthesize delegateQueue;  // non-atomic

- (id)initWithDelegate:(id)inDelegate delegateQueue:(dispatch_queue_t)inDelegateQueue
{
    if ((self = [super init]))
    {
#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        {
            if (SupportsWeakReferences(inDelegate))
            {
                delegate = inDelegate;
                delegateQueue = inDelegateQueue;
            }
            else
            {
                delegate = [NSNull null];
                
                unsafeDelegate = inDelegate;
                delegateQueue = inDelegateQueue;
            }
        }
#else
        {
            delegate = inDelegate;
            delegateQueue = inDelegateQueue;
        }
#endif
        
#if !OS_OBJECT_USE_OBJC
        if (delegateQueue)
            dispatch_retain(delegateQueue);
#endif
    }
    return self;
}

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
    if (delegateQueue)
        dispatch_release(delegateQueue);
#endif
}

@end
