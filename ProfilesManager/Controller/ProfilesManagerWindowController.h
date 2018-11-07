//
//  ProfilesManagerWindowController.h
//  ProfilesManager
//
//  Created by Jakey on 2018/4/20.
//  Copyright © 2018年 Jakey. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ProfilesManagerWindowController : NSWindowController
@property (weak) IBOutlet NSPopUpButton *searchTypePopUpButton;
@property (weak) IBOutlet NSButton *searchButton;
@property (weak) IBOutlet NSTextField *searchTextField;

- (IBAction)searchTypePopUpButtonTouched:(id)sender;
- (IBAction)searchButtonTouched:(id)sender;
- (IBAction)refreshButtonTouched:(id)sender;
@end
