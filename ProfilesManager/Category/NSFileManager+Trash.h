//
//  NSFileManager+Trash.h
//  AppTrash
//
//  Copyright Matt Rajca 2010. All rights reserved.
//
#import <Foundation/Foundation.h>
@interface NSFileManager (Trash)

- (NSString *)mr_uniqueFileNameWithPath:(NSString *)aPath;
- (BOOL)mr_moveFileAtPathToTrash:(NSString *)aPath error:(NSError **)outError;
//获取sandbox之外的路径
- (NSString *)realHomeDirectory;
@end
