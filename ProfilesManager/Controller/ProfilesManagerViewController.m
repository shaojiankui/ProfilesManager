//
//  ProfilesToolViewController.m
//  ProfilesManager
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
#import "DateManager.h"
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
static NSString *kColumnIdentifierCreateDays = @"days";

@implementation ProfilesManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self createDir];
    [self treeViewBuilder];
}

- (void)createDir {
    _profileDir = [NSString stringWithFormat:@"%@/Library/MobileDevice/Provisioning Profiles/", [[NSFileManager defaultManager] realHomeDirectory]];
    _backupDir = [NSString stringWithFormat:@"%@/Library/MobileDevice/Provisioning Profiles Rename Backup/", [[NSFileManager defaultManager] realHomeDirectory]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:_backupDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_backupDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:_profileDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_profileDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)treeViewBuilder {
    //当拖拽窗口大小，NSOutlineView frame自动更改时，Column宽等比增减
    [self.treeView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    //最后一行自动宽等比增减
    //    [self.treeView sizeLastColumnToFit];
    //app第一次运行Column 最后一行自动宽等比增减，否则会有滚动条
    [self.treeView sizeToFit];
    self.treeView.allowsMultipleSelection = YES;

    [self loadProfileFilesWithSearchWord:_searchWord];
    //drag file
    [self.treeView didDragEndBlock:^(NSArray *list, NSOutlineView *view) {
        for (NSString *result in list) {
            if (result && ([[result lowercaseString] hasSuffix:@"mobileprovision"] || [[result lowercaseString] hasSuffix:@"provisionprofile"])) {
                NSError *error;
                [[NSFileManager defaultManager]copyItemAtPath:result toPath:[_profileDir stringByAppendingString:[result lastPathComponent] ? : @""] error:&error];
                if (error) {
                    [iAlert showMessage:[error localizedDescription]
                                 window:self.view.window completionHandler:^(NSModalResponse returnCode) {
                    }];
                }
            }
            [self loadProfileFilesWithSearchWord:_searchWord];
        }
        if ([list count] == 1 && [[[list firstObject]lowercaseString] hasSuffix:@"ipa"]) {
            PreviewViewController *preview = [[PreviewViewController alloc]initWithIPA:[list firstObject]];
            [self presentViewControllerAsModalWindow:preview];
        }
    }];
}

- (void)loadProfileFilesWithSearchWord:(NSString *)searchWord {
    _searchWord = searchWord;

    NSArray *profileNames =  [[[NSFileManager defaultManager] subpathsAtPath:_profileDir] pathsMatchingExtensions:@[@"mobileprovision", @"MOBILEPROVISION", @"provisionprofile", @"PROVISIONPROFILE"]];

    NSMutableDictionary *provisions = [NSMutableDictionary dictionary];
    for (NSUInteger i=0;i<[profileNames count];i++) {
        NSString *fileName = [profileNames objectAtIndex:i];
        
        NSString *plistString;
        NSMutableDictionary *dic = (NSMutableDictionary *)[PlistManager readPlist:[_profileDir stringByAppendingString:fileName?:@""] plistString:&plistString];
        dic[@"filePath"] = [_profileDir stringByAppendingString:fileName?:@""];

    
         if (dic && fileName) {
            if ([searchWord lowercaseString] && searchWord.length > 0) {
                if ([[plistString lowercaseString] rangeOfString:[searchWord lowercaseString]].location != NSNotFound) {
                    provisions[fileName] = dic;
                }
            } else {
                provisions[fileName] = dic;
            }
        }
    }
    ProfilesNode *node = [[ProfilesNode alloc]initWithRootNode:nil originInfo:provisions key:@"Mobile Provisions"];
    _rootNode = node;
    [self.treeView reloadData];
    [self updateStatus];

    for (NSTableColumn *tableColumn in self.treeView.tableColumns) {
        NSSortDescriptor *sortStates = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier
                                                                     ascending:NO comparator:^(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        [tableColumn setSortDescriptorPrototype:sortStates];
    }
}

#pragma mark - Outline

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    ProfilesNode *realItem = item ? : _rootNode;
    return [realItem.childrenNodes count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    ProfilesNode *realItem = item ? : _rootNode;
    return realItem.childrenNodes != nil;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    ProfilesNode *realItem = item ? : _rootNode;
    return realItem.childrenNodes[index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    ProfilesNode *realItem = item ? : _rootNode;

    if ([[tableColumn identifier] isEqualToString:kColumnIdentifierKey]) {
        return realItem.key;
    } else if ([[tableColumn identifier] isEqualToString:kColumnIdentifierType]) {
        return realItem.type;
    } else if ([[tableColumn identifier] isEqualToString:kColumnIdentifierDetal]) {
        return realItem.detail;
    } else if ([[tableColumn identifier] isEqualToString:kColumnIdentifierExpirationDate]) {
        return  [[DateManager sharedManager] stringConvert_YMDHM_FromDate:realItem.expirationDate];
    } else if ([[tableColumn identifier] isEqualToString:kColumnIdentifierCreateDate]) {
        return [[DateManager sharedManager] stringConvert_YMDHM_FromDate:realItem.creationDate];
    }else if ([[tableColumn identifier] isEqualToString:kColumnIdentifierCreateDays]) {
        return realItem.days;
    }
    return @"";
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    NSInteger selectedRow = [outlineView clickedRow];
    //    [outlineView setNeedsDisplayInRect:[outlineView rectOfRow:selectedRow]];
    NSLog(@"select is %zd", selectedRow);
    return YES;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(NSTextFieldCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    ProfilesNode *realItem = item ? : _rootNode;

    if ([outlineView parentForItem:item] == nil) {
        if ([[tableColumn identifier] isEqualToString:kColumnIdentifierType]) {
            cell.textColor = [NSColor blackColor];
        } else {
            cell.textColor = [NSColor darkGrayColor];
            if ([[tableColumn identifier] isEqualToString:kColumnIdentifierDetal]) {
                if ([realItem.detail isEqualToString:@"Expired"] || [realItem.detail isEqualToString:@"过期"]) {
                    cell.textColor = [NSColor redColor];
                }
            }
        }
        [cell setMenu:[self itemMenu]];
    } else {
        cell.textColor = [NSColor darkGrayColor];
        ProfilesNode *realItem = item;
        if ([realItem.rootNode.key isEqualToString:@"DeveloperCertificates"]) {
            [cell setMenu:[self certificateMenu]];
        } else {
            [cell setMenu:nil];
        }
    }

    if (cell.highlighted) {
        if ([[tableColumn identifier] isEqualToString:kColumnIdentifierDetal]) {
            if ([realItem.detail isEqualToString:@"Expired"] || [realItem.detail isEqualToString:@"过期"]) {
                cell.textColor = [NSColor redColor];
            } else {
                cell.textColor = [NSColor whiteColor];
            }
        } else {
            cell.textColor = [NSColor whiteColor];
        }
    }
}

- (void)outlineView:(NSOutlineView *)outlineView sortDescriptorsDidChange:(NSArray<NSSortDescriptor *> *)oldDescriptors {
    NSSortDescriptor *sortDescriptor = [[outlineView sortDescriptors] objectAtIndex:0];

    NSArray *sortedArray;
    NSMutableArray *currChildren = [_rootNode.childrenNodes mutableCopy];
    sortedArray = [currChildren sortedArrayUsingDescriptors:@[sortDescriptor]];
    _rootNode.childrenNodes = sortedArray;
    [outlineView reloadData];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    [self updateStatus];
}

#pragma mark -
#pragma mark NSMenuDelegate
- (void)rightMouseDown:(NSEvent *)theEvent {
    NSPoint location = [self.treeView convertPoint:[theEvent locationInWindow] fromView:nil];
    //    NSInteger i =  [self.treeView rowAtPoint:pt];
    [[self mainMenu] popUpMenuPositioningItem:nil atLocation:location inView:self.treeView];
}

- (NSMenu *)certificateMenu {
    if (!_certificateMenu) {
        _certificateMenu = [[NSMenu alloc]init];
        _certificateMenu.delegate = self;
    }
    return _certificateMenu;
}

- (NSMenu *)itemMenu {
    if (!_itemMenu) {
        _itemMenu = [[NSMenu alloc]init];
        _itemMenu.delegate = self;
    }
    return _itemMenu;
}

- (NSMenu *)mainMenu {
    if (!_mainMenu) {
        _mainMenu = [[NSMenu alloc]init];
        _mainMenu.delegate = self;
    }
    return _mainMenu;
}

- (void)menuWillOpen:(NSMenu *)menu
{
    if (menu == _itemMenu) {
        NSMenuItem *copyPathItem = [menu itemWithTag:1007];
        if (!copyPathItem) {
            copyPathItem = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Copy Profile path", nil) action:@selector(copyProfilePath:) keyEquivalent:@""];
            [copyPathItem setTarget:self];
            [copyPathItem setTag:1007];
            [menu addItem:copyPathItem];
        }

        NSMenuItem *gotoItemName = [menu itemWithTag:1002];
        if (!gotoItemName) {
            gotoItemName = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Show in Finder", nil) action:@selector(showInFinder:) keyEquivalent:@""];
            [gotoItemName setTarget:self];
            [gotoItemName setTag:1002];
            [menu addItem:gotoItemName];
        }
        NSMenuItem *moveTrashItem = [menu itemWithTag:1000];
        if (!moveTrashItem) {
            moveTrashItem = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Move to Trash", nil) action:@selector(moveTrashItemClick:) keyEquivalent:@""];
            [moveTrashItem setTarget:self];
            [moveTrashItem setTag:1000];
            [menu addItem:moveTrashItem];
        }
        NSMenuItem *deleteItem = [menu itemWithTag:1001];
        if (!deleteItem) {
            deleteItem = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Delete", nil) action:@selector(deleteItemClick:) keyEquivalent:@""];
            [deleteItem setTarget:self];
            [deleteItem setTag:1001];
            [menu addItem:deleteItem];
        }
        NSMenuItem *exportItem = [menu itemWithTag:1003];
        if (!exportItem) {
            exportItem = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Export", nil) action:@selector(exportItemClick:) keyEquivalent:@""];
            [exportItem setTarget:self];
            [exportItem setTag:1003];
            [menu addItem:exportItem];
        }
        NSMenuItem *renameItem = [menu itemWithTag:1004];
        if (!renameItem) {
            renameItem = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Beautify Filename", nil) action:@selector(renameItemClick:) keyEquivalent:@""];
            [renameItem setTarget:self];
            [renameItem setTag:1004];
            [menu addItem:renameItem];
        }
    }
    if (menu == _mainMenu) {
        NSMenuItem *refreshItem = [menu itemWithTag:2000];
        if (!refreshItem) {
            refreshItem = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Refresh Table", nil) action:@selector(refreshItemClick:) keyEquivalent:@""];
            [refreshItem setTarget:self];
            [refreshItem setTag:2000];
            [menu addItem:refreshItem];
        }
        NSMenuItem *importItem = [menu itemWithTag:2001];
        if (!importItem) {
            importItem = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Import Profile", nil) action:@selector(importItemClick:) keyEquivalent:@""];
            [importItem setTarget:self];
            [importItem setTag:2001];
            [menu addItem:importItem];
        }
    }
    if (menu  == _certificateMenu) {
        NSMenuItem *exportItem = [menu itemWithTag:3001];
        if (!exportItem) {
            exportItem = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Export Certificate File", nil) action:@selector(exportCerItemClick:) keyEquivalent:@""];
            [exportItem setTarget:self];
            [exportItem setTag:3001];
            [menu addItem:exportItem];
        }
        
        NSMenuItem *copyNameItem = [menu itemWithTag:3002];
        if (!copyNameItem) {
            copyNameItem = [[NSMenuItem alloc] initWithTitle:JKLocalizedString(@"Copy Certificate Name", nil) action:@selector(copyCertificateNameItemClick:) keyEquivalent:@""];
            [copyNameItem setTarget:self];
            [copyNameItem setTag:3002];
            [menu addItem:copyNameItem];
        }
    }
}

#pragma mark -
#pragma mark Operation
- (void)updateStatus {
    if ([self selectedRowIndexes].count > 0) {
        self.statusLabel.stringValue = [NSString stringWithFormat:@"%@ of %@ items selected", [@([self selectedRowIndexes].count) stringValue], [@([_rootNode.childrenNodes count]) stringValue]];
    } else {
        self.statusLabel.stringValue = [NSString stringWithFormat:@"%@ items", [@([_rootNode.childrenNodes count]) stringValue]];
    }
}

- (NSIndexSet *)selectedRowIndexes {
    NSIndexSet *selectedRowIndexes = [self.treeView selectedRowIndexes];
    //多选
    if (selectedRowIndexes.count == 0) {
        //直接右键
        NSInteger index = [self.treeView clickedRow];
        if (index > -1) {
            selectedRowIndexes = [NSIndexSet indexSetWithIndex:index];
        }
    }
    return selectedRowIndexes;
}

- (NSArray *)activateFileURLs {
    NSArray *selectedItems = [_rootNode.childrenNodes objectsAtIndexes:[self selectedRowIndexes]];
    NSMutableArray *activateFileURLs = [NSMutableArray array];
    for (ProfilesNode *node in selectedItems) {
        if ([node.filePath length] > 0) {
            [activateFileURLs addObject:[NSURL fileURLWithPath:node.filePath]];
        }
    }
    return activateFileURLs;
}

- (void)deleteItemClick:(id)sender
{
    NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
    NSArray *selectedItems = [_rootNode.childrenNodes objectsAtIndexes:selectedRowIndexes];

    NSMutableArray *selectedItemNames = [NSMutableArray array];
    for (ProfilesNode *node in selectedItems) {
        [selectedItemNames addObject:node.type ? : node.filePath];
    }

    iAlert *alert = [iAlert alertWithTitle:JKLocalizedString(@"Are you sure delete selected items from disk? After delete operation can't rollback!", nil) message:[selectedItemNames componentsJoinedByString:@",\n"] style:NSAlertStyleWarning];
    [alert addCommonButtonWithTitle:JKLocalizedString(@"Ok", nil) handler:^(iAlertItem *item) {
        [self.treeView beginUpdates];
        [self.treeView removeItemsAtIndexes:selectedRowIndexes inParent:nil withAnimation:NSTableViewAnimationEffectFade];
        [self.treeView endUpdates];

        for (ProfilesNode *node in selectedItems) {
            if ([self deleteProfile:node.filePath option:YES]) {
                NSMutableArray *temp = [_rootNode.childrenNodes mutableCopy];
                [temp removeObject:node];
                _rootNode.childrenNodes = temp;
            }
        }
        [self updateStatus];
    }];
    [alert addButtonWithTitle:JKLocalizedString(@"Cancle", nil)];
    [alert show:self.view.window];
}

- (void)moveTrashItemClick:(id)sender {
    NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
    NSArray *selectedItems = [_rootNode.childrenNodes objectsAtIndexes:selectedRowIndexes];

    NSMutableArray *selectedItemNames = [NSMutableArray array];
    for (ProfilesNode *node in selectedItems) {
        [selectedItemNames addObject:node.type ? : node.filePath];
    }

    iAlert *alert = [iAlert alertWithTitle:JKLocalizedString(@"Are you sure move selected items to trash?", nil) message:[selectedItemNames componentsJoinedByString:@",\n"] style:NSAlertStyleWarning];

    [alert addCommonButtonWithTitle:JKLocalizedString(@"Ok", nil) handler:^(iAlertItem *item) {
        [self.treeView beginUpdates];
        [self.treeView removeItemsAtIndexes:selectedRowIndexes inParent:nil withAnimation:NSTableViewAnimationEffectFade];
        [self.treeView endUpdates];

        for (ProfilesNode *node in selectedItems) {
            if ([self deleteProfile:node.filePath option:NO]) {
                NSMutableArray *temp = [_rootNode.childrenNodes mutableCopy];
                [temp removeObject:node];
                _rootNode.childrenNodes = temp;
            }
        }
        [self updateStatus];

//        [self loadProfileFilesWithSearchWord:_searchWord];
    }];

    [alert addButtonWithTitle:JKLocalizedString(@"Cancle", nil)];
    [alert show:self.view.window];
}

//copyProfilePath
- (void)copyProfilePath:(id)sender
{
    NSArray *selectedItems = [_rootNode.childrenNodes objectsAtIndexes:[self selectedRowIndexes]];
    if (selectedItems.count > 0) {
        ProfilesNode *node = selectedItems.firstObject;
        NSPasteboard *paste = [NSPasteboard generalPasteboard];
        [paste clearContents];
        [paste setString:node.filePath forType:NSPasteboardTypeString];
    }
}

//showInFinder
- (void)showInFinder:(id)sender
{
    NSArray *activateFileURLs = [self activateFileURLs];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:activateFileURLs];
}

//beautify filename
- (void)renameItemClick:(id)sender {
    NSInteger index = [self.treeView clickedRow];
    ProfilesNode *node = [self.treeView itemAtRow:index];

    if ([node.filePath.lastPathComponent hasPrefix:node.type]) {
        [iAlert showMessage:JKLocalizedString(@"The filename no need beautify", nil) window:self.view.window completionHandler:^(NSModalResponse returnCode) {
        }];
        return;
    }

    NSString *msg = JKLocalizedString(@"The profile installed by double click fileaname format is 'uuid+ext',it‘s very hard identify.\nare you sure rename profile filename? this will take 5 seconds！\nthe new filename is: ", nil);

    iAlert *alert = [iAlert alertWithTitle:JKLocalizedString(@"Warning", nil) message:[NSString stringWithFormat:@"%@%@", msg, node.type] style:NSAlertStyleWarning];
    [alert addCommonButtonWithTitle:JKLocalizedString(@"Ok", nil) handler:^(iAlertItem *item) {
        if (index == -1) return;
        NSString *newPath = [self renameFileAtPath:node.filePath toName:node.type];
        if (newPath && newPath.length > 0) {
            node.filePath = newPath;
            node.key = [newPath lastPathComponent];
            [self.treeView beginUpdates];
            [self.treeView reloadItem:node];
            [self.treeView endUpdates];
        }
    }];

    [alert addButtonWithTitle:JKLocalizedString(@"Cancle", nil)];
    [alert show:self.view.window];
}

//export Item to file
- (void)exportItemClick:(id)sender {
    NSInteger index = [self.treeView clickedRow];
    if (index == -1) return;
    ProfilesNode *node = [self.treeView itemAtRow:index];

    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.allowedFileTypes = @[@"mobileprovision", @"provisionprofile"];
    savePanel.nameFieldStringValue = node.type ? : node.key;
    savePanel.extensionHidden = NO;

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
- (void)importItemClick:(id)sender {
    NSError *error;
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setCanChooseDirectories:YES];
    [oPanel setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]];
    [oPanel setAllowedFileTypes:@[@"mobileprovision", @"MOBILEPROVISION", @"provisionprofile"]];

    if ([oPanel runModal] == NSModalResponseOK) {
        NSString *path = [[[oPanel URLs] objectAtIndex:0] path];

        [[NSFileManager defaultManager]copyItemAtPath:path toPath:[_profileDir stringByAppendingString:[path lastPathComponent] ? : @""] error:&error];
    }
    if (error) {
        [iAlert showMessage:[error localizedDescription] window:self.view.window completionHandler:^(NSModalResponse returnCode) {
        }];
    }
    [self loadProfileFilesWithSearchWord:_searchWord];
}

- (void)exportCerItemClick:(id)sender
{
    NSInteger index = [self.treeView clickedRow];
    if (index == -1) return;
    ProfilesNode *node = [self.treeView itemAtRow:index];
    if ([node.detail length] > 0) {
        NSOpenPanel *oPanel = [NSOpenPanel openPanel];
        [oPanel setCanChooseDirectories:YES];
        [oPanel setCanChooseFiles:NO];
        [oPanel setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]];
        if ([oPanel runModal] == NSModalResponseOK) {
            NSString *path = [[[oPanel URLs] objectAtIndex:0] path];
            NSString *savePath = [[path stringByAppendingPathComponent:[node.extra objectForKey:@"summary"] ]stringByAppendingPathExtension:@"cer"];

            NSString *formaterCer = [NSString stringWithFormat:@"-----BEGIN CERTIFICATE-----\n%@\n-----END CERTIFICATE-----", node.detail];

            BOOL haveCreate =  [[NSFileManager defaultManager]createFileAtPath:savePath contents:[formaterCer dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
            if (haveCreate) {
                [[NSWorkspace sharedWorkspace] selectFile:savePath inFileViewerRootedAtPath:@""];
            }
        }
    }
}

- (void)copyCertificateNameItemClick:(id)sender
{
    NSInteger index = [self.treeView clickedRow];
    if (index == -1) return;
    ProfilesNode *node = [self.treeView itemAtRow:index];
    NSPasteboard *paste = [NSPasteboard generalPasteboard];
    [paste clearContents];
    [paste setString:node.key forType:NSPasteboardTypeString];
}


#pragma mark --filemanager

//delete and move
- (BOOL)deleteProfile:(NSString *)filePath option:(BOOL)completely {
    NSError *error;
    BOOL result = NO;
    if (completely) {
        result =  [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    } else {
        result = [[NSFileManager defaultManager] mr_moveFileAtPathToTrash:filePath error:&error];
    }
    if (error) {
        [iAlert showMessage:[error localizedDescription] window:self.view.window completionHandler:^(NSModalResponse returnCode) {
        }];
    }
    return result;
}

- (NSString *)renameFileAtPath:(NSString *)oldPath toName:(NSString *)toName {
    BOOL result = NO;
    NSError *error = nil;

    NSString *ext = oldPath.pathExtension;

    NSString *time = [[DateManager sharedManager] stringConvert_Y_M_D_H_M_FromDate:[NSDate date]];

    NSString *toPath = [[[_backupDir stringByAppendingPathComponent:toName] stringByAppendingString:time] stringByAppendingPathExtension:ext];

    NSString *newPath = [[_profileDir stringByAppendingPathComponent:toName] stringByAppendingPathExtension:ext];

    result = [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:toPath error:&error];
    //Provisioning Profiles文件比较特殊 直接改名会被系统自动删掉
    sleep(5);
    result = [[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:toPath] toURL:[NSURL fileURLWithPath:newPath] error:&error];

    if (error) {
        [iAlert showAlert:NSAlertStyleWarning title:@"" message:[error localizedDescription]];
        NSLog(@"重命名失败：%@", [error localizedDescription]);
    }
    if (result) {
        return newPath;
    }
    return nil;
}

@end
