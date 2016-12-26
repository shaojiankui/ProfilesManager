//
//  ProfilesToolViewController.m
//  ProfilesTool
//
//  Created by Jakey on 15/4/30.
//  Copyright (c) 2015年 Jakey. All rights reserved.
//

#import "ProfilesToolViewController.h"
#import "ProfilesNode.h"
#import "NSOutlineView+Menu.h"
#import "NSFileManager+Trash.h"


@implementation ProfilesToolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self loadProfileFiles];
    //drag file
    
    [self.treeView didDragEndBlock:^(NSString *result, NSOutlineView *view) {
        if (result && ( [result hasSuffix:@"mobileprovision"] || [result hasSuffix:@"MOBILEPROVISION"])) {
            NSError *error;
            [[NSFileManager defaultManager]copyItemAtPath:result toPath:[_profileDir stringByAppendingString:[result lastPathComponent]?:@""] error:&error];
            if(error)
            {
                [self showMessage:[error localizedDescription]];
            }
            [self loadProfileFiles];
        }
    }];
 
}

-(void)loadProfileFiles{
    if (!_profilePaths) {
        _profilePaths = [NSMutableArray array];
    }
    if (!_profileDatas) {
        _profileDatas = [NSMutableArray array];

    }
   
    _profileDir = [NSString stringWithFormat:@"%@/Library/MobileDevice/Provisioning Profiles/", NSHomeDirectory()];
    _profileNames =  [[[NSFileManager defaultManager] subpathsAtPath:_profileDir]  pathsMatchingExtensions:@[@"mobileprovision",@"MOBILEPROVISION"]];
    
    
    NSMutableDictionary *provisions = [NSMutableDictionary dictionary];
    for(NSString *fileName in _profileNames){
        [_profilePaths addObject:[_profileDir stringByAppendingString:fileName?:@""]];
        NSMutableDictionary *dic = (NSMutableDictionary*)[self readPlist:[_profileDir stringByAppendingString:fileName?:@""]];
        dic[@"filePath"] = [_profileDir stringByAppendingString:fileName?:@""];

        [_profileDatas addObject:dic];
        if (dic && fileName) {
            provisions[fileName] = dic;
        }
        
    }
    
    
    ProfilesNode *node = [[ProfilesNode alloc]initWithParentNode:nil originInfo:provisions key:@"Mobile Provisions"];
    _rootNode = node;
    [self.treeView reloadData];
    
}

-(NSDictionary*)readPlist:(NSString *)filePath
{
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        NSString *startString = @"<?xml version";
        NSString *endString = @"</plist>";
        
        NSData *rawData = [NSData dataWithContentsOfFile:filePath];
        NSData *startData = [NSData dataWithBytes:[startString UTF8String] length:startString.length];
        NSData *endData = [NSData dataWithBytes:[endString UTF8String] length:endString.length];
        
        NSRange fullRange = {.location = 0, .length = [rawData length]};
        
        NSRange startRange = [rawData rangeOfData:startData options:0 range:fullRange];
        NSRange endRange = [rawData rangeOfData:endData options:0 range:fullRange];
        
        NSRange plistRange = {.location = startRange.location, .length = endRange.location + endRange.length - startRange.location};
        NSData *plistData = [rawData subdataWithRange:plistRange];
        
        id obj = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:NULL error:nil];
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            return obj;
        }
    }
    return nil;
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
    static NSString *kColumnIdentifierName = @"name";

    static NSString *kColumnIdentifierType = @"type";
    //static NSString *kColumnIdentifierDetal = @"detail";
    static NSString *kColumnIdentifierUUID = @"uuid";

    if ([[tableColumn identifier] isEqualToString:kColumnIdentifierKey]) {
        return realItem.key;
    }
    else if([[tableColumn identifier] isEqualToString:kColumnIdentifierName]){
        return realItem.name;
    }
    else if([[tableColumn identifier] isEqualToString:kColumnIdentifierType]){
        return realItem.type;
    }
    else if([[tableColumn identifier] isEqualToString:kColumnIdentifierUUID]){
        return realItem.uuid;
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

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if ([outlineView parentForItem:item] == nil)
    {
        [cell setMenu:[self itemMenu]];

    }else{
        [cell setMenu:nil];

    }
    
}

#pragma mark -
#pragma mark NSMenuDelegate
- (void)rightMouseDown:(NSEvent *)theEvent {

    NSPoint location = [self.treeView convertPoint:[theEvent locationInWindow] fromView:nil];
    //    NSInteger i =  [self.treeView rowAtPoint:pt];

    [[self mainMenu] popUpMenuPositioningItem:nil atLocation:location inView:self.treeView];
}
-(NSMenu*)itemMenu{
    if(!_itemMenu){
        _itemMenu = [[NSMenu alloc]init];
        _itemMenu.delegate = self;
    }
    return _itemMenu;
}
-(NSMenu*)mainMenu{
    if(!_mainMenu){
        _mainMenu = [[NSMenu alloc]init];
        _mainMenu.delegate = self;
    }
    return _mainMenu;
}
- (void)menuWillOpen:(NSMenu *)menu
{
    
    if(menu == _itemMenu){
        NSMenuItem *moveTrashItem = [menu itemWithTag:1000];
        if (!moveTrashItem)
        {
            moveTrashItem = [[NSMenuItem alloc] initWithTitle:@"移动到废纸篓" action:@selector(moveTrashItemClick:) keyEquivalent:@""];
            [moveTrashItem setTarget:self];
            [moveTrashItem setTag:1000];
            [menu addItem:moveTrashItem];
        }
        NSMenuItem *deleteItem = [menu itemWithTag:1001];
        if (!deleteItem)
        {
            deleteItem = [[NSMenuItem alloc] initWithTitle:@"完全删除" action:@selector(deleteItemClick:) keyEquivalent:@""];
            [deleteItem setTarget:self];
            [deleteItem setTag:1001];
            [menu addItem:deleteItem];
        }
        NSMenuItem *gotoItemName = [menu itemWithTag:1002];
        if (!gotoItemName)
        {
            gotoItemName = [[NSMenuItem alloc] initWithTitle:@"定位" action:@selector(gotoClick:) keyEquivalent:@""];
            [gotoItemName setTarget:self];
            [gotoItemName setTag:1002];
            [menu addItem:gotoItemName];
        }
//        NSMenuItem *exportItem = [menu itemWithTag:1003];
//        if (!exportItem)
//        {
//            exportItem = [[NSMenuItem alloc] initWithTitle:@"导出" action:@selector(exportItemClick:) keyEquivalent:@""];
//            [exportItem setTarget:self];
//            [exportItem setTag:1003];
//            [menu addItem:exportItem];
//        }
    }
    if(menu == _mainMenu){
        NSMenuItem *refreshItem = [menu itemWithTag:2000];
        if (!refreshItem)
        {
            refreshItem = [[NSMenuItem alloc] initWithTitle:@"刷新列表" action:@selector(refreshItemClick:) keyEquivalent:@""];
            [refreshItem setTarget:self];
            [refreshItem setTag:2000];
            [menu addItem:refreshItem];
        }
        NSMenuItem *importItem = [menu itemWithTag:2001];
        if (!importItem)
        {
            importItem = [[NSMenuItem alloc] initWithTitle:@"导入" action:@selector(importItemClick:) keyEquivalent:@""];
            [importItem setTarget:self];
            [importItem setTag:2001];
            [menu addItem:importItem];
        }
    }
}
#pragma mark -
#pragma mark Operation
- (void)deleteItemClick:(id)sender
{
    
    NSInteger index = [self.treeView clickedRow];
    ProfilesNode *node = [self.treeView itemAtRow:index];
    
    NSLog(@"deleteItem inde%zd",index);
    if (index == -1) return;
    
    [self.treeView beginUpdates];
    [self.treeView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:index]  inParent:nil withAnimation:NSTableViewAnimationEffectFade];
    [self.treeView endUpdates];
    
    [self deleteProfile:node.filePath option:YES];
    [self loadProfileFiles];
    
}
- (void)moveTrashItemClick:(id)sender{
    NSInteger index = [self.treeView clickedRow];
    ProfilesNode *node = [self.treeView itemAtRow:index];
    
    NSLog(@"move to trash inde%zd",index);
    if (index == -1) return;
    
    [self.treeView beginUpdates];
    [self.treeView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:index]  inParent:nil withAnimation:NSTableViewAnimationEffectFade];
    [self.treeView endUpdates];
    
    [self deleteProfile:node.filePath option:NO];
    [self loadProfileFiles];

}
//delete and move
-(BOOL)deleteProfile:(NSString*)filePath option:(BOOL)totle{
    NSError *error;
    BOOL result = NO;
    if (totle) {
       result =  [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];

    }else{
         result = [[NSFileManager defaultManager] mr_moveFileAtPathToTrash:filePath error:&error];
    }
    if(error)
    {
        [self showMessage:[error localizedDescription]];

    }
    return result;
    
}
//goto
- (void)gotoClick:(id)sender
{
    NSInteger index = [self.treeView clickedRow];
    if (index == -1) return;
    ProfilesNode *node = [self.treeView itemAtRow:index];
    if ([node.filePath length] > 0)
    {
        //打开文件
       //[[NSWorkspace sharedWorkspace] openFile:node.filePath];
       // 打开文件夹
       [[NSWorkspace sharedWorkspace] selectFile:node.filePath inFileViewerRootedAtPath:node.filePath];
    }
}
//export Item to file
- (void)exportItemClick:(id)sender {
    
}
//main
- (void)refreshItemClick:(id)sender {
    [self loadProfileFiles];

}
//import
- (void)importItemClick:(id)sender{
    NSError *error;
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setCanChooseDirectories:YES];
    [oPanel setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]];
    [oPanel setAllowedFileTypes:@[@"mobileprovision", @"MOBILEPROVISION"]];
    
    if ([oPanel runModal] == NSOKButton) {
        NSString *path =[[[oPanel URLs] objectAtIndex:0] path];
        
        [[NSFileManager defaultManager]copyItemAtPath:path toPath:[_profileDir stringByAppendingString:[path lastPathComponent]?:@""] error:&error];

    }
    if(error)
    {
        [self showMessage:[error localizedDescription]];
        
    }
    [self loadProfileFiles];

}
#pragma mark --alert
-(void)showMessage:(NSString*)message{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:message];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        
    }];
    
}
- (void)showAlert:(NSAlertStyle)style title:(NSString *)title message:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    [alert setAlertStyle:style];
    [alert runModal];
}


@end
