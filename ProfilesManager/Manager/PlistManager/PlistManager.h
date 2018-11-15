//
//  PlistManager.h
//  ProfilesManager
//
//  Created by Jakey on 2018/3/5.
//  Copyright © 2018年 Jakey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistManager : NSObject
+ (NSDictionary*)readPlist:(NSString *)filePath plistString:(NSString**)plistString;
@end
