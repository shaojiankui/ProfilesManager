//
//  PreviewViewController.h
//  ProfilesManager
//
//  Created by runlin on 2018/3/5.
//  Copyright © 2018年 Jakey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DragOutlineView.h"
#import "ProfilesNode.h"
@interface PreviewViewController : NSViewController<NSOutlineViewDataSource,NSOutlineViewDelegate,NSMenuDelegate>
{
    NSTask *_unzipTask;
    NSString *_workingPath;
    NSString *_appPath;
    
    NSMutableDictionary *_profileDict;
    NSDictionary *_plistDict;

    ProfilesNode *_rootNode;
    NSString *_ipaPath;
}
@property (weak) IBOutlet DragOutlineView *treeView;
- (instancetype)initWithIPA:(NSString*)ipa;

@end
