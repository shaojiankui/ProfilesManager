//
//  PlistManager.h
//  ProfilesManager
//
//  Created by runlin on 2018/3/5.
//  Copyright © 2018年 Jakey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistManager : NSObject
+ (NSDictionary*)readPlist:(NSString *)filePath;
@end
