//
//  iAlert.h
//  iSimulator
//
//  Created by Jakey on 2017/2/24.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class iAlertItem;
typedef void(^JKAlertHandler)(iAlertItem *item);

@interface iAlert : NSAlert
@property(nonatomic,readonly) NSArray *actions;

- (id)initWithTitle:(NSString *)title message:(NSString *)message style:(NSAlertStyle)style;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message  style:(NSAlertStyle)style;

- (NSInteger)addButtonWithTitle:(NSString *)title;
- (iAlertItem*)addCommonButtonWithTitle:(NSString *)title handler:(JKAlertHandler)handler;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;

- (void)show:(NSWindow *)window;
- (void)show;

#pragma mark --alert
+ (void)showMessage:(NSString*)message window:(NSWindow*)window completionHandler:(void (^)(NSModalResponse returnCode))handler;
+ (void)showAlert:(NSAlertStyle)style title:(NSString *)title message:(NSString *)message;
@end

@interface iAlertItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic) NSUInteger tag;
@property (nonatomic, copy) JKAlertHandler action;
@end
