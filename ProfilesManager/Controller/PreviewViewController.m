//
//  PreviewViewController.m
//  ProfilesManager
//
//  Created by runlin on 2018/3/5.
//  Copyright © 2018年 Jakey. All rights reserved.
//

#import "PreviewViewController.h"
#import "ProfilesNode.h"
#import "PlistManager.h"
@interface PreviewViewController ()

@end

@implementation PreviewViewController
- (instancetype)initWithIPA:(NSString*)ipa
{
    self = [super init];
    if (self) {
        _ipaPath = ipa;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //当拖拽窗口大小，NSOutlineView frame自动更改时，Column宽等比增减
    [self.treeView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    //最后一行自动宽等比增减
    //    [self.treeView sizeLastColumnToFit];
    //app第一次运行Column 最后一行自动宽等比增减，否则会有滚动条
    [self.treeView sizeToFit];
    
    
    _workingPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"org.skyfox.ProfilesManager"];
    [[NSFileManager defaultManager] removeItemAtPath:_workingPath error:nil];
    
    
    _unzipTask = [[NSTask alloc] init];
    [_unzipTask setLaunchPath:@"/usr/bin/unzip"];
    [_unzipTask setArguments:[NSArray arrayWithObjects:@"-q", _ipaPath, @"-d", _workingPath, nil]];
    
    NSTimer *timer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkUnzip:) userInfo:nil repeats:YES];
    timer.fireDate = [NSDate distantPast];
    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
    
    [_unzipTask launch];
    self.title  = @"Unzipping";

}
- (void)checkUnzip:(NSTimer *)timer {
    if ([_unzipTask isRunning] == 0) {
        [timer invalidate];
        _unzipTask = nil;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[_workingPath stringByAppendingPathComponent:@"Payload"]]) {
            NSLog(@"Unzipping done,  Original app extracted");
            self.title  = @"Unzipping done,  Original app extracted";
            
            _plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[self findPlist]];
            self.title = [_plistDict objectForKey:@"CFBundleName"];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[_appPath stringByAppendingPathComponent:@"embedded.mobileprovision"]]) {
                
                _profileDict = (NSMutableDictionary*)[PlistManager readPlist:[_appPath stringByAppendingPathComponent:@"embedded.mobileprovision"]];
                
                _profileDict[@"filePath"] = _appPath;
            
                
                ProfilesNode *node = [[ProfilesNode alloc]initWithRootNode:nil originInfo:_profileDict key:@"Mobile Provisions"];
                

                _rootNode = node;
                [self.treeView reloadData];
            }
            
        } else {
            self.title  = @"Ready";
        }
    }
}
- (NSString*)findPlist{
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[_workingPath stringByAppendingPathComponent:@"Payload"] error:nil];
    NSString *infoPlistPath = nil;
    
    for (NSString *file in dirContents) {
        if ([[[file pathExtension] lowercaseString] isEqualToString:@"app"]) {
            infoPlistPath = [[[_workingPath stringByAppendingPathComponent:@"Payload"]
                              stringByAppendingPathComponent:file]
                             stringByAppendingPathComponent:@"Info.plist"];
            _appPath = [[_workingPath stringByAppendingPathComponent:@"Payload"] stringByAppendingPathComponent:file];
            break;
        }
    }
    return infoPlistPath;
    
}
- (IBAction)segmentControlClicked:(id)segmentControl{
    NSInteger index = [segmentControl selectedSegment];
    if(index ==0){
        
        ProfilesNode *node = [[ProfilesNode alloc]initWithRootNode:nil originInfo:_profileDict key:@"Mobile Provisions"];
        
        _rootNode = node;
        [self.treeView reloadData];
    }else{
        
        ProfilesNode *node = [[ProfilesNode alloc]initWithRootNode:nil originInfo:_plistDict key:@"Mobile Provisions"];
        
        
        _rootNode = node;
        [self.treeView reloadData];
    }
}
#pragma mark - Outline

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    ProfilesNode *realItem = item ?: _rootNode;
    return [realItem.childrenNodes count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    ProfilesNode *realItem = item ?: _rootNode;
    return realItem.childrenNodes != nil;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    ProfilesNode *realItem = item ?: _rootNode;
    return realItem.childrenNodes[index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    ProfilesNode *realItem = item ?: _rootNode;
    
    static NSString *kColumnIdentifierKey = @"key";
    //    static NSString *kColumnIdentifierName = @"name";
    static NSString *kColumnIdentifierType = @"type";
    //static NSString *kColumnIdentifierDetal = @"detail";
    //    static NSString *kColumnIdentifierUUID = @"uuid";
    
    if ([[tableColumn identifier] isEqualToString:kColumnIdentifierKey]) {
        return realItem.key;
    }
    else if([[tableColumn identifier] isEqualToString:kColumnIdentifierType]){
        return realItem.type;
    }
    else {
        return realItem.detail;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item{
    NSInteger row = [outlineView clickedRow];
    NSLog(@"select is %zd",row);
    return YES;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(NSTextFieldCell*)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
   
}

-(void)updateRowViewBackColorforItem:(id)customItem {
    NSInteger row = [self.treeView rowForItem:customItem];
    if (row < 0) return;
    NSTableRowView *view = [self.treeView rowViewAtRow:row makeIfNecessary:YES];
    [view setBackgroundColor:[NSColor redColor]];
}
@end
