//
//  ProfilesToolViewController.h
//  ProfilesManager
//
//  Created by Jakey on 15/4/30.
//  Copyright (c) 2015年 Jakey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "DragOutlineView.h"
#import "ProfilesNode.h"

@interface ProfilesManagerViewController : NSViewController<NSOutlineViewDataSource,NSOutlineViewDelegate,NSMenuDelegate>
{
    NSString *_profileDir;
    NSString *_backupDir;

    NSMenu *_itemMenu;
    NSMenu *_certificateMenu;
    NSMenu *_mainMenu;
    
    ProfilesNode *_rootNode;
    NSString *_searchWord;
}
@property (weak) IBOutlet DragOutlineView *treeView;
@property (weak) IBOutlet NSTextField *statusLabel;
- (void)loadProfileFilesWithSearchWord:(NSString*)searchWord;
@end
