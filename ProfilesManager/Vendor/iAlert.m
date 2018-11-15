//
//  iAlert.m
//  iSimulator
//
//  Created by Jakey on 2017/2/24.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import "iAlert.h"
@implementation iAlertItem
@end

@interface iAlert()
{
    NSMutableArray *_items;
}
@end
@implementation iAlert

#pragma mark -- init
- (id)initWithTitle:(NSString *)title message:(NSString *)message style:(NSAlertStyle)style{
    self = [super init];
    if (self != nil)
    {
        _items = [NSMutableArray array];
        self.alertStyle = style;
        self.messageText = [title description];
        self.informativeText = [message description];
    }
    return self;
}
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message style:(NSAlertStyle)style{
    return [[self alloc] initWithTitle:title message:message style:style];
}

#pragma mark -- add button and handle
- (NSInteger)addButtonWithTitle:(NSString *)title{
    NSAssert(title != nil, @"all title must be non-nil");
    iAlertItem *item =  [self addCommonButtonWithTitle:title handler:^(iAlertItem *item) {
        NSLog(@"no action");
    }];
    return [_items indexOfObject:item];
}

- (iAlertItem*)addCommonButtonWithTitle:(NSString *)title handler:(JKAlertHandler)handler{
   return [self addButtonWithTitle:title handler:handler];
}
- (iAlertItem*)addButtonWithTitle:(NSString *)title handler:(JKAlertHandler)handler{
    NSAssert(title != nil, @"all title must be non-nil");
    iAlertItem *item = [[iAlertItem alloc] init];
    item.title = [title description];
    item.action = handler;
    [super addButtonWithTitle:[title description]];
    [_items addObject:item];
    item.tag = [_items indexOfObject:item];
    return item;
}
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex{
    iAlertItem *item = _items[buttonIndex];
    return item.title;
}
- (NSArray *)actions
{
    return [_items copy];
}

#pragma --mark show
- (void)show:(NSWindow *)window
{
    [self  beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
       iAlertItem *item = _items[returnCode-1000];
        item.action(item);
    }];
    [window becomeKeyWindow];
}
-(void)show{
    NSRect frame = NSMakeRect(0, 0, 200, 100);
    NSUInteger styleMask =    NSBorderlessWindowMask;
//    NSRect rect = [NSWindow contentRectForFrameRect:frame styleMask:styleMask];
    NSWindow * window =  [[NSWindow alloc] initWithContentRect:frame styleMask:styleMask backing: NSBackingStoreBuffered defer:false];
    [window setBackgroundColor:[NSColor clearColor]];
    [window makeKeyAndOrderFront:window];
    [window orderFrontRegardless];
    [window center];
    [self  beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        iAlertItem *item = _items[returnCode-1000];
        item.action(item);
    }];
    [window becomeKeyWindow];
}

#pragma mark --alert
+ (void)showMessage:(NSString*)message window:(NSWindow*)window completionHandler:(void (^)(NSModalResponse returnCode))handler{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:message];
    [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        handler(returnCode);
    }];
    
}

+ (void)showAlert:(NSAlertStyle)style title:(NSString *)title message:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    [alert setAlertStyle:style];
    [alert runModal];
}
@end
