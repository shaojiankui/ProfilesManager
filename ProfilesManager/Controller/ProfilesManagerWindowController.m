//
//  ProfilesManagerWindowController.m
//  ProfilesManager
//
//  Created by Jakey on 2018/4/20.
//  Copyright © 2018年 Jakey. All rights reserved.
//

#import "ProfilesManagerWindowController.h"
#import "ProfilesManagerViewController.h"
@interface ProfilesManagerWindowController ()

@end

@implementation ProfilesManagerWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
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
@end
