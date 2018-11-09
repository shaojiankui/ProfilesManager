//
//  AppDelegate.m
//  ProfilesTool
//
//  Created by Jakey on 15/4/30.
//  Copyright (c) 2015年 Jakey. All rights reserved.
//

#import "AppDelegate.h"
#import "ProfilesManagerWindowController.h"
@interface AppDelegate ()
{
    ProfilesManagerWindowController *_window;
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    _window = [[ProfilesManagerWindowController alloc] initWithWindowNibName:@"ProfilesManagerWindowController"];
    _window.contentViewController = [[ProfilesManagerViewController alloc] initWithNibName:@"ProfilesManagerViewController" bundle:[NSBundle bundleForClass:[self class]]];
    [_window.window orderFront:nil];
}
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (!flag)
    {
      [_window.window makeKeyAndOrderFront:self];
    }
    return YES;
}

@end
