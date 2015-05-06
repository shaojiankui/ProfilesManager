//
//  ProfilesToolViewController.h
//  ProfilesTool
//
//  Created by Jakey on 15/4/30.
//  Copyright (c) 2015年 Jakey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "DragOutlineView.h"
#import "ProfilesNode.h"

@interface ProfilesToolViewController : NSViewController<NSOutlineViewDataSource,NSOutlineViewDelegate,NSMenuDelegate>
{
    NSString *_profileDir;
    NSArray *_profileNames;
    NSMutableArray *_profilePaths;
    NSMutableArray *_profileDatas;
    
    NSMenu *_itemMenu;
    NSMenu *_mainMenu;
    ProfilesNode *_rootNode;

}

@property (weak) IBOutlet DragOutlineView *treeView;

@end
