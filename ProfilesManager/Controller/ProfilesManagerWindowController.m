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
#import "NSFileManager+Trash.h"
#import "iAlert.h"
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
- (IBAction)quickLookTouched:(id)sender {
    NSString *installURL = [[[NSFileManager defaultManager] realHomeDirectory] stringByAppendingPathComponent:@"/Library/QuickLook/ProvisionQL.qlgenerator"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:installURL]){
        iAlert *alert = [iAlert alertWithTitle:JKLocalizedString(@"Provision QuickLook Plug-in is already Installed",nil) message:JKLocalizedString(@"What opration do you want?", nil) style:NSAlertStyleWarning];
        [alert addCommonButtonWithTitle:JKLocalizedString(@"Back", nil) handler:^(iAlertItem *item) {
           
        }];
        [alert addCommonButtonWithTitle:JKLocalizedString(@"Show in Finder", nil) handler:^(iAlertItem *item) {
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:installURL?:@""]]];
        }];
        [alert addCommonButtonWithTitle:JKLocalizedString(@"Uninstall", nil) handler:^(iAlertItem *item) {
            if ([[NSFileManager defaultManager] mr_moveFileAtPathToTrash:installURL error:nil]) {
                NSString *result = [self qlmanageRefresh];
                [iAlert showMessage:[NSString stringWithFormat:@"%@,%@",JKLocalizedString(@"Uninstall Success", nil),result] window:self.window completionHandler:^(NSModalResponse returnCode) {
                    
                }];
            }else{
                [iAlert showMessage:JKLocalizedString(@"Uninstall Failure", nil) window:self.window completionHandler:^(NSModalResponse returnCode) {
                    
                }];
            }
        }];
     
        [alert show];
    }else{
        [self installProvisionQL];
    }
}
- (void)installProvisionQL{
    NSString *quickLook = [[[NSFileManager defaultManager] realHomeDirectory] stringByAppendingPathComponent:@"/Library/QuickLook"];

    NSString *installURL = [quickLook stringByAppendingPathComponent:@"ProvisionQL.qlgenerator"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:quickLook]){
        [[NSFileManager defaultManager] createDirectoryAtPath:quickLook withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *provisionQLURL = [[NSBundle mainBundle] pathForResource:@"ProvisionQL" ofType:@"qlgenerator"];

    NSString *function = JKLocalizedString(@"the plug-in can view the .ipa/.xcarchive/.appex/.mobileprovision/.provisionprofile files directly use the the blank space key.", nil);
    
    NSString *message = [NSString stringWithFormat:@"%@   %@  https://github.com/ealeksandrov/ProvisionQL",function,JKLocalizedString(@"the plug-in sourcecode can view at", nil)];
    
   
    
    iAlert *alert = [iAlert alertWithTitle:JKLocalizedString(@"Install Provision QuickLook Plug-in",nil) message:message style:NSAlertStyleWarning];
  
    [alert addCommonButtonWithTitle:JKLocalizedString(@"Back", nil) handler:^(iAlertItem *item) {
        
    }];
    [alert addCommonButtonWithTitle:JKLocalizedString(@"Install", nil) handler:^(iAlertItem *item) {
        if ([[NSFileManager defaultManager] copyItemAtPath:provisionQLURL toPath:installURL error:nil]) {
            NSString *result = [self  qlmanageRefresh];
            
            [iAlert showMessage:[NSString stringWithFormat:@"%@,%@",JKLocalizedString(@"Install Success", nil),result] window:self.window completionHandler:^(NSModalResponse returnCode) {
                
            }];
        }else{
            [iAlert showMessage:JKLocalizedString(@"Install Failure", nil) window:self.window completionHandler:^(NSModalResponse returnCode) {
                
            }];
        }
    }];
    
    [alert show];
}
- (NSString*)qlmanageRefresh{
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    [task setLaunchPath: @"/usr/bin/qlmanage"];
    [task setArguments:@[@"-r"]];
    [task setStandardOutput: pipe];
    [task launch];
    return [[NSString alloc] initWithData:[file readDataToEndOfFile] encoding:NSUTF8StringEncoding];
}
@end
