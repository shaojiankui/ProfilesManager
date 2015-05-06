//
//  DragOutlineView.m
//  ProfilesTool
//
//  Created by Jakey on 15/5/6.
//  Copyright (c) 2015年 Jakey. All rights reserved.
//

#import "DragOutlineView.h"

@implementation DragOutlineView
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];

    }
    
    return self;
}
- (void)awakeFromNib {
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        return NSDragOperationCopy;
    }
    if(_didEnterDraging){
        _didEnterDraging();
    }
    return NSDragOperationNone;
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender{
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    NSArray *list = [zPasteboard propertyListForType:NSFilenamesPboardType];
    if(_didDragEnd){
        _didDragEnd([list firstObject],self);
    }

}
-(void)didDragEndBlock:(DidDragEnd)didDragEnd{
    _didDragEnd = [didDragEnd copy];
}
-(void)didEnterDragingBlock:(DidEnterDraging)didEnterDraging{
    _didEnterDraging  = [didEnterDraging copy];
}

@end
