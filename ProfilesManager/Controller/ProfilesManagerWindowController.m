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

- (IBAction)searchButtonTouched:(id)sender {
    ProfilesManagerViewController *manger =  (ProfilesManagerViewController*)self.contentViewController;
    [manger loadProfileFilesWithSearchWord:self.searchTextField.stringValue];
    
}
@end
