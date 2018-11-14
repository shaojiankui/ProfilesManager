//
//  ProfilesManagerWindowController.m
//  ProfilesManager
//
//  Created by Jakey on 2018/4/20.
//  Copyright © 2018年 Jakey. All rights reserved.
//

#import "ProfilesManagerWindowController.h"
#import "ProfilesManagerViewController.h"
#import "GitHubUpdater.h"
@interface ProfilesManagerWindowController ()
@property( atomic, readwrite, strong, nullable ) IBOutlet GitHubUpdater * updater;
@end

@implementation ProfilesManagerWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.updater            = [[ GitHubUpdater alloc] init];
    self.updater.user       = @"shaojiankui";
    self.updater.repository = @"ProfilesManager";
    [self.updater checkForUpdatesInBackground];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)searchTypePopUpButtonTouched:(id)sender {
    
}
- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
{
//    NSLog(@"Selector method is (%@)", NSStringFromSelector( commandSelector ) );
    if (commandSelector == @selector(insertNewline:)) {
        //Do something against ENTER key
        [self searchButtonTouched:self.searchButton];
        return YES;
    }
//    else if (commandSelector == @selector(deleteForward:)) {
//        //Do something against DELETE key
//
//    } else if (commandSelector == @selector(deleteBackward:)) {
//        //Do something against BACKSPACE key
//
//    } else if (commandSelector == @selector(insertTab:)) {
//        //Do something against TAB key
//    }
    return NO;
    // return YES if the action was handled; otherwise NO
}
#pragma mark -- text field delegate

- (void)controlTextDidEndEditing:(NSNotification *)obj{
    [self searchButtonTouched:self.searchButton];
}

- (void)controlTextDidChange:(NSNotification *)obj{
    [self searchButtonTouched:self.searchButton];
}
- (IBAction)searchButtonTouched:(id)sender {
    ProfilesManagerViewController *manger =  (ProfilesManagerViewController*)self.contentViewController;
    [manger loadProfileFilesWithSearchWord:self.searchTextField.stringValue];
    
}
- (IBAction)refreshButtonTouched:(id)sender {
    ProfilesManagerViewController *manger =  (ProfilesManagerViewController*)self.contentViewController;
    [manger loadProfileFilesWithSearchWord:self.searchTextField.stringValue];
}
- (IBAction)resetButtonTouched:(id)sender {
//    rm ~/Library/Preferences/myapp.plist; sudo killall cfprefsd
//    defaults delete ~/Library/Preferences/myapp.plist
    [self.window setFrame:NSMakeRect(0, 0, 1000, 600) display:YES];
    [self.window center];
}
@end
