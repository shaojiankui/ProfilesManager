//
//  DragOutlineView.h
//  ProfilesTool
//
//  Created by Jakey on 15/5/6.
//  Copyright (c) 2015年 Jakey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
typedef void (^DidDragEnd)(NSArray *result,NSOutlineView *view);
typedef void (^DidEnterDraging)();
@interface DragOutlineView : NSOutlineView
{
    DidDragEnd _didDragEnd;
    DidEnterDraging _didEnterDraging;
    
}
-(void)didDragEndBlock:(DidDragEnd)didDragEnd;
-(void)didEnterDragingBlock:(DidEnterDraging)didEnterDraging;

@end
