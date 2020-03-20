//
//  ProfilesNode.h
//  ProfilesManager
//
//  Created by Jakey on 15/4/30.
//  Copyright (c) 2015年 Jakey. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JKLocalizedString(key, comment) \
(([[[NSLocale preferredLanguages] objectAtIndex:0] hasPrefix:@"zh-Hans"])?([[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]):([[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"]] localizedStringForKey:key value:@"" table:nil]))

@interface ProfilesNode : NSObject

@property (nonatomic, weak)ProfilesNode *rootNode;
@property (nonatomic, strong)NSArray *childrenNodes;
@property (nonatomic, copy)NSString *key;
//@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *detail;
@property (nonatomic, copy)NSString *type;
@property (nonatomic, copy)NSString *uuid;
@property (nonatomic, copy)NSString *filePath;
@property (nonatomic, strong)NSDictionary *extra;
@property (nonatomic, strong)NSDate *expirationDate;
@property (nonatomic, strong)NSDate *creationDate;
 
@property (nonatomic, copy)NSString *days;
- (id)initWithRootNode:(ProfilesNode *)rootNote originInfo:(id)info key:(NSString*)key;

@end
