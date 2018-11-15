//
//  NSOutlineView+Menu.m
//  ProfilesManager
//
//  Created by Jakey on 15/5/6.
//  Copyright (c) 2015年 Jakey. All rights reserved.
//

#import "NSOutlineView+Menu.h"

@implementation NSOutlineView (Menu)

-(NSMenu *)menuForEvent:(NSEvent *)event
{
    NSPoint pt = [self convertPoint:[event locationInWindow] fromView:nil];
    NSInteger row = [self rowAtPoint:pt];
    if (row >= 0) {
        NSTableRowView* rowView = [self rowViewAtRow:row makeIfNecessary:NO];
        if (rowView) {
            NSInteger col = [self columnAtPoint:pt];
            if (col >= 0) {
                NSTableCellView* cellView = [rowView viewAtColumn:col];
                NSMenu* cellMenu = cellView.menu;
                if(cellMenu) {
                    return cellMenu;
                }
            }
            NSMenu* rowMenu = rowView.menu;
            if (rowMenu) {
                return rowMenu;
            }
        }
    }
    return [super menuForEvent:event];
}

//- (NSMenu *)defaultMenu {
//    if([self selectedRow] < 0) return nil;
//    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Model browser context menu"];
//    [theMenu insertItemWithTitle:@"Add package" action:@selector(addSite:) keyEquivalent:@"" atIndex:0];
//    NSString* deleteItem = [NSString stringWithFormat: @"Remove '%i'", [self selectedRow]];
//    [theMenu insertItemWithTitle: deleteItem action:@selector(removeSite:) keyEquivalent:@"" atIndex:1];
//    return theMenu;
//}
//
//- (NSMenu *)menuForEvent:(NSEvent *)theEvent {
//    return [self defaultMenu];
//}
@end
