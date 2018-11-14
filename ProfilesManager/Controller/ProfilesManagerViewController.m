//
//  ProfilesToolViewController.m
//  ProfilesTool
//
//  Created by Jakey on 15/4/30.
//  Copyright (c) 2015年 Jakey. All rights reserved.
//

#import "ProfilesManagerViewController.h"
#import "ProfilesNode.h"
#import "NSOutlineView+Menu.h"
#import "NSFileManager+Trash.h"
#import "iAlert.h"
#import "PreviewViewController.h"
#import "PlistManager.h"
#import "DragOutlineRowView.h"
//#include <unistd.h>
//#include <sys/types.h>
//#include <pwd.h>
//#include <assert.h>
static NSString *kColumnIdentifierKey = @"key";
//    static NSString *kColumnIdentifierName = @"name";
static NSString *kColumnIdentifierType = @"type";
static NSString *kColumnIdentifierDetal = @"detail";
//    static NSString *kColumnIdentifierUUID = @"uuid";
static NSString *kColumnIdentifierExpirationDate = @"expirationDate";
static NSString *kColumnIdentifierCreateDate = @"creationDate";

@implementation ProfilesManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _profileDir = [NSString stringWithFormat:@"%@/Library/MobileDevice/Provisioning Profiles/", RealHomeDirectory()];
    
    //当拖拽窗口大小，NSOutlineView frame自动更改时，Column宽等比增减
    [self.treeView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    //最后一行自动宽等比增减
    //    [self.treeView sizeLastColumnToFit];
    //app第一次运行Column 最后一行自动宽等比增减，否则会有滚动条
    [self.treeView sizeToFit];
    
    [self loadProfileFilesWithSearchWord:_searchWord];
    //drag file
    [self.treeView didDragEndBlock:^(NSArray *list, NSOutlineView *view) {
        for(NSString *result in list){
            if (result && ( [[result lowercaseString] hasSuffix:@"mobileprovision"] || [[result lowercaseString] hasSuffix:@"provisionprofile"])) {
                NSError *error;
                [[NSFileManager defaultManager]copyItemAtPath:result toPath:[_profileDir stringByAppendingString:[result lastPathComponent]?:@""] error:&error];
                if(error)
                {
                    [self showMessage:[error localizedDescription] completionHandler:^(NSModalResponse returnCode) {
                        
                    }];
                }
            }
            [self loadProfileFilesWithSearchWord:_searchWord];
        }
        if ([list count]==1 && [[[list firstObject]lowercaseString] hasSuffix:@"ipa"]) {
            PreviewViewController *preview = [[PreviewViewController alloc]initWithIPA:[list firstObject]];
            [self presentViewControllerAsModalWindow:preview];
        }
    }];
    
}
//获取sandbox之外的路径
NSString *RealHomeDirectory() {
    //    struct passwd *pw = getpwuid(getuid());
    //    assert(pw);
    //    return [NSString stringWithUTF8String:pw->pw_dir];
    //
    NSString *home = NSHomeDirectory();
    NSArray *pathArray = [home componentsSeparatedByString:@"/"];
    NSString *absolutePath;
    if ([pathArray count] > 2) {
        absolutePath = [NSString stringWithFormat:@"/%@/%@", [pathArray objectAtIndex:1], [pathArray objectAtIndex:2]];
    }
    return absolutePath;
}

- (void)loadProfileFilesWithSearchWord:(NSString*)searchWord {
    _searchWord = searchWord;
    
    NSArray  *profileNames =  [[[NSFileManager defaultManager] subpathsAtPath:_profileDir]  pathsMatchingExtensions:@[@"mobileprovision",@"MOBILEPROVISION",@"provisionprofile",@"PROVISIONPROFILE"]];
    
    NSMutableDictionary *provisions = [NSMutableDictionary dictionary];
    for(NSString *fileName in profileNames){
        NSString *plistString;
        NSMutableDictionary *dic = (NSMutableDictionary*)[PlistManager readPlist:[_profileDir stringByAppendingString:fileName?:@""] plistString:&plistString];
        dic[@"filePath"] = [_profileDir stringByAppendingString:fileName?:@""];
        
        if (dic && fileName) {
            if ([searchWord lowercaseString] && searchWord.length>0) {
                if ([[plistString lowercaseString] rangeOfString:[searchWord lowercaseString]].location != NSNotFound) {
                    provisions[fileName] = dic;
                }
            }else{
                provisions[fileName] = dic;
            }
        }
    }
    
    ProfilesNode *node = [[ProfilesNode alloc]initWithRootNode:nil originInfo:provisions key:@"Mobile Provisions"];
    _rootNode = node;
    [self.treeView reloadData];
    
    for (NSTableColumn *tableColumn in self.treeView.tableColumns ) {
        NSSortDescriptor *sortStates = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier
                     ascending:NO comparator:^(id obj1, id obj2) {
                         return [obj1 compare:obj2];
                    }];
        [tableColumn setSortDescriptorPrototype:sortStates];
    }
   
}


#pragma mark - Outline
- (nullable NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item{
    DragOutlineRowView *row   = [[DragOutlineRowView alloc] init];
    row.identifier = @"row";
    return row;
}
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    ProfilesNode *realItem = item ?: _rootNode;
    return [realItem.childrenNodes count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    ProfilesNode *realItem = item ?: _rootNode;
    return realItem.childrenNodes != nil;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    ProfilesNode *realItem = item ?: _rootNode;
    return realItem.childrenNodes[index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    ProfilesNode *realItem = item ?: _rootNode;
    
    if ([[tableColumn identifier] isEqualToString:kColumnIdentifierKey]) {
        return realItem.key;
    }
    else if([[tableColumn identifier] isEqualToString:kColumnIdentifierType]){
        return realItem.type;
    }
    else if([[tableColumn identifier] isEqualToString:kColumnIdentifierDetal]){
        return realItem.detail;
    } else if([[tableColumn identifier] isEqualToString:kColumnIdentifierExpirationDate]){
        return realItem.expirationDate;
    }else if([[tableColumn identifier] isEqualToString:kColumnIdentifierCreateDate]){
        return realItem.creationDate;
    }
    return @"";
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item{
    NSInteger selectedRow = [outlineView clickedRow];
//    [outlineView setNeedsDisplayInRect:[outlineView rectOfRow:selectedRow]];
    NSLog(@"select is %zd",selectedRow);
    return YES;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(NSTextFieldCell*)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
   
    ProfilesNode *realItem = item ?: _rootNode;

    if ([outlineView parentForItem:item] == nil)
    {
        if ([[tableColumn identifier] isEqualToString:kColumnIdentifierType]) {
            cell.textColor = [NSColor blackColor];
        }else{
            cell.textColor = [NSColor darkGrayColor];
            if ([[tableColumn identifier] isEqualToString:kColumnIdentifierDetal]) {
                if ([realItem.detail isEqualToString:@"Expired"] ||[realItem.detail isEqualToString:@"过期"] ) {
                    cell.textColor = [NSColor redColor];
                }
            }
        }
        [cell setMenu:[self itemMenu]];
    }else{
        cell.textColor = [NSColor darkGrayColor];
        ProfilesNode *realItem = item;
        if([realItem.rootNode.key isEqualToString:@"DeveloperCertificates"]){
            [cell setMenu:[self certificateMenu]];
        }else{
            [cell setMenu:nil];
        }
    }
   
}


- (void)outlineView:(NSOutlineView *)outlineView sortDescriptorsDidChange:(NSArray<NSSortDescriptor *> *)oldDescriptors{
    NSSortDescriptor *sortDescriptor  = [[outlineView sortDescriptors] objectAtIndex:0];
    
    NSArray *sortedArray;
    NSMutableArray *currChildren= [_rootNode.childrenNodes mutableCopy];
    sortedArray = [currChildren sortedArrayUsingDescriptors:@[sortDescriptor]];
    _rootNode.childrenNodes = sortedArray;
    [outlineView reloadData];
    //    NSSortDescriptor *sortDescriptor;
    //
    //    NSString *key=[[[outlineView sortDescriptors] objectAtIndex:0] key];
    //    BOOL isAscending=[[[outlineView sortDescriptors] objectAtIndex:0] ascending];
    //
    //    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:isAscending] ;
    //    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    //    NSArray *sortedArray;
    //
    //    NSMutableArray *currChildren= [_rootNode.childrenNodes mutableCopy];
    //    sortedArray = [currChildren sortedArrayUsingDescriptors:sortDescriptors];
    //    _rootNode.childrenNodes = sortedArray;
    //    [outlineView reloadData];
//}

}

#pragma mark -
#pragma mark NSMenuDelegate
- (void)rightMouseDown:(NSEvent *)theEvent {
    
    NSPoint location = [self.treeView convertPoint:[theEvent locationInWindow] fromView:nil];
    //    NSInteger i =  [self.treeView rowAtPoint:pt];
    [[self mainMenu] popUpMenuPositioningItem:nil atLocation:location inView:self.treeView];
}

- (NSMenu*)certificateMenu{
    if(!_certificateMenu){
        _certificateMenu = [[NSMenu alloc]init];
        _certificateMenu.delegate = self;
    }
    return _certificateMenu;
}

- (NSMenu*)itemMenu{
    if(!_itemMenu){
        _itemMenu = [[NSMenu alloc]init];
        _itemMenu.delegate = self;
    }
    return _itemMenu;
}

- (NSMenu*)mainMenu{
    if(!_mainMenu){
        _mainMenu = [[NSMenu alloc]init];
        _mainMenu.delegate = self;
    }
    return _mainMenu;
}

- (void)menuWillOpen:(NSMenu *)menu
{
    
    if(menu == _itemMenu){
        NSMenuItem *gotoItemName = [menu itemWithTag:1002];
        if (!gotoItemName)
        {
            gotoItemName = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Show in Finder",nil) action:@selector(gotoClick:) keyEquivalent:@""];
            [gotoItemName setTarget:self];
            [gotoItemName setTag:1002];
            [menu addItem:gotoItemName];
        }
        NSMenuItem *moveTrashItem = [menu itemWithTag:1000];
        if (!moveTrashItem)
        {
            moveTrashItem = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Move to Trash",nil) action:@selector(moveTrashItemClick:) keyEquivalent:@""];
            [moveTrashItem setTarget:self];
            [moveTrashItem setTag:1000];
            [menu addItem:moveTrashItem];
        }
        NSMenuItem *deleteItem = [menu itemWithTag:1001];
        if (!deleteItem)
        {
            deleteItem = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Delete",nil) action:@selector(deleteItemClick:) keyEquivalent:@""];
            [deleteItem setTarget:self];
            [deleteItem setTag:1001];
            [menu addItem:deleteItem];
        }
        NSMenuItem *exportItem = [menu itemWithTag:1003];
        if (!exportItem)
        {
            exportItem = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Export",nil) action:@selector(exportItemClick:) keyEquivalent:@""];
            [exportItem setTarget:self];
            [exportItem setTag:1003];
            [menu addItem:exportItem];
        }
//        NSMenuItem *renameItem = [menu itemWithTag:1004];
//        if (!renameItem)
//        {
//            renameItem = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Beautify Filename",nil) action:@selector(renameItemClick:) keyEquivalent:@""];
//            [renameItem setTarget:self];
//            [renameItem setTag:1004];
//            [menu addItem:renameItem];
//        }
    }
    if(menu == _mainMenu){
        NSMenuItem *refreshItem = [menu itemWithTag:2000];
        if (!refreshItem)
        {
            refreshItem = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Refresh Table",nil) action:@selector(refreshItemClick:) keyEquivalent:@""];
            [refreshItem setTarget:self];
            [refreshItem setTag:2000];
            [menu addItem:refreshItem];
        }
        NSMenuItem *importItem = [menu itemWithTag:2001];
        if (!importItem)
        {
            importItem = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Import Profile",nil) action:@selector(importItemClick:) keyEquivalent:@""];
            [importItem setTarget:self];
            [importItem setTag:2001];
            [menu addItem:importItem];
        }
    }
    if (menu  == _certificateMenu) {
        NSMenuItem *exportItem = [menu itemWithTag:3001];
        if (!exportItem)
        {
            exportItem = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Export Certificate File",nil) action:@selector(exportCerItemClick:) keyEquivalent:@""];
            [exportItem setTarget:self];
            [exportItem setTag:3001];
            [menu addItem:exportItem];
        }
    }
}

#pragma mark -
#pragma mark Operation
- (void)deleteItemClick:(id)sender
{
    NSInteger index = [self.treeView clickedRow];
    ProfilesNode *node = [self.treeView itemAtRow:index];
    
    iAlert *alert = [iAlert alertWithTitle:[NSString stringWithFormat:@"%@,%@",JKLocalizedString(@"Confirm Delete Opration",nil),node.type] message:JKLocalizedString(@"Delete this profie item permanently,can't rollback!",nil) style:NSAlertStyleWarning];
    [alert addCommonButtonWithTitle:JKLocalizedString(@"Ok", nil) handler:^(iAlertItem *item) {
        NSLog(@"deleteItem inde%zd",index);
        if (index == -1) return;
        
        [self.treeView beginUpdates];
        [self.treeView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:index]  inParent:nil withAnimation:NSTableViewAnimationEffectFade];
        [self.treeView endUpdates];
        
        [self deleteProfile:node.filePath option:YES];
//        [self loadProfileFilesWithSearchWord:_searchWord];
    }];
    [alert addButtonWithTitle:JKLocalizedString(@"Cancle", nil)];
    [alert show:self.view.window];
}

- (void)moveTrashItemClick:(id)sender{
    NSInteger index = [self.treeView clickedRow];
    ProfilesNode *node = [self.treeView itemAtRow:index];
    
    iAlert *alert = [iAlert alertWithTitle:JKLocalizedString(@"Warning",nil) message:JKLocalizedString(@"are you sure move item to trash?",nil) style:NSAlertStyleWarning];
    [alert addCommonButtonWithTitle:JKLocalizedString(@"Ok", nil) handler:^(iAlertItem *item) {
        
        NSLog(@"move to trash inde%zd",index);
        if (index == -1) return;
        
        [self.treeView beginUpdates];
        [self.treeView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:index]  inParent:nil withAnimation:NSTableViewAnimationEffectFade];
        [self.treeView endUpdates];
        
        [self deleteProfile:node.filePath option:NO];
        [self loadProfileFilesWithSearchWord:_searchWord];
    }];
    
    [alert addButtonWithTitle:JKLocalizedString(@"Cancle", nil)];
    [alert show:self.view.window];
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
        [[NSWorkspace sharedWorkspace] selectFile:node.filePath inFileViewerRootedAtPath:@""];
    }
}
////beautify filename
//- (void)renameItemClick:(id)sender{
//    NSInteger index = [self.treeView clickedRow];
//    ProfilesNode *node = [self.treeView itemAtRow:index];
//    
//    iAlert *alert = [iAlert alertWithTitle:JKLocalizedString(@"Warning",nil) message:JKLocalizedString(@"are you sure rename profile filename ?",nil) style:NSAlertStyleWarning];
//    [alert addCommonButtonWithTitle:JKLocalizedString(@"Ok", nil) handler:^(iAlertItem *item) {
//        
//        if (index == -1) return;
//        if ([self renameFileAtPath:node.filePath toName:node.type]) {
//            [self.treeView beginUpdates];
//            [self.treeView reloadItem:node];
//            [self.treeView endUpdates];
//        }
//    }];
//    
//    [alert addButtonWithTitle:JKLocalizedString(@"Cancle", nil)];
//    [alert show:self.view.window];
//}
//export Item to file
- (void)exportItemClick:(id)sender {
    NSInteger index = [self.treeView clickedRow];
    if (index == -1) return;
    ProfilesNode *node = [self.treeView itemAtRow:index];
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.allowedFileTypes = @[@"mobileprovision",@"provisionprofile"];
    savePanel.nameFieldStringValue = node.key;
    [savePanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        NSString *savePath = savePanel.URL.path;
        if (result == NSFileHandlingPanelOKButton) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:savePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:savePath error:nil];
            }
            [[NSFileManager defaultManager] copyItemAtPath:node.filePath toPath:savePath error:nil];
        }
    }];
}

//main
- (void)refreshItemClick:(id)sender {
    [self loadProfileFilesWithSearchWord:_searchWord];
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
        [self showMessage:[error localizedDescription] completionHandler:^(NSModalResponse returnCode) {
            
        }];
    }
    [self loadProfileFilesWithSearchWord:_searchWord];
}

- (void)exportCerItemClick:(id)sender
{
    NSInteger index = [self.treeView clickedRow];
    if (index == -1) return;
    ProfilesNode *node = [self.treeView itemAtRow:index];
    if ([node.detail length] > 0)
    {
        
        NSOpenPanel *oPanel = [NSOpenPanel openPanel];
        [oPanel setCanChooseDirectories:YES];
        [oPanel setCanChooseFiles:NO];
        [oPanel setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]];
        if ([oPanel runModal] == NSOKButton) {
            NSString *path =[[[oPanel URLs] objectAtIndex:0] path];
            NSString *savePath = [[path stringByAppendingPathComponent:[node.extra objectForKey:@"summary"] ]stringByAppendingPathExtension:@"cer"];
            
            NSString *formaterCer = [NSString stringWithFormat:@"-----BEGIN CERTIFICATE-----\n%@\n-----END CERTIFICATE-----",node.detail];
            
            BOOL haveCreate =  [[NSFileManager defaultManager]createFileAtPath:savePath contents:[formaterCer dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
            if(haveCreate){
                [[NSWorkspace sharedWorkspace] selectFile:savePath inFileViewerRootedAtPath:@""];
            }
        }
        
    }
}
#pragma mark --filemanager

//delete and move
- (BOOL)deleteProfile:(NSString*)filePath option:(BOOL)totle{
    NSError *error;
    BOOL result = NO;
    if (totle) {
        result =  [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        
    }else{
        result = [[NSFileManager defaultManager] mr_moveFileAtPathToTrash:filePath error:&error];
    }
    if(error)
    {
        [self showMessage:[error localizedDescription] completionHandler:^(NSModalResponse returnCode) {
            
        }];
    }
    return result;
}

//-(BOOL)renameFileAtPath:(NSString *)oldPath toName:(NSString *)toName {
//    BOOL result = NO;
//    NSError * error = nil;
//    NSString *toPath = [[[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:toName] stringByAppendingPathExtension:@"mobileprovision"];
//
//    NSString *tempFolder = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"temp"];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:tempFolder]) {
//        [[NSFileManager defaultManager] createDirectoryAtPath:tempFolder withIntermediateDirectories:YES attributes:nil error:nil];
//    }
//    NSString *tempPath =  [tempFolder stringByAppendingPathComponent:oldPath.lastPathComponent];
//
//     result = [[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:oldPath] toURL:[NSURL fileURLWithPath:tempPath] error:&error];
//
//    result = [[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:tempPath] toURL:[NSURL fileURLWithPath:toPath] error:&error];
//
//    if (error){ NSLog(@"重命名失败：%@",[error localizedDescription]);
//
//    }
//    return result;
//}
#pragma mark --alert
- (void)showMessage:(NSString*)message completionHandler:(void (^)(NSModalResponse returnCode))handler{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:message];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        handler(returnCode);
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
