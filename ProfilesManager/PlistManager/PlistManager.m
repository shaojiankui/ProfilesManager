//
//  PlistManager.m
//  ProfilesManager
//
//  Created by runlin on 2018/3/5.
//  Copyright © 2018年 Jakey. All rights reserved.
//

#import "PlistManager.h"

@implementation PlistManager
+ (NSDictionary*)readPlist:(NSString *)filePath
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

@end
