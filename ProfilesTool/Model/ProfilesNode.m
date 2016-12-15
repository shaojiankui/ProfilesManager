//
//  ProfilesNode.m
//  ProfilesTool
//
//  Created by Jakey on 15/4/30.
//  Copyright (c) 2015年 Jakey. All rights reserved.
//

#import "ProfilesNode.h"
#import "NSData+JKBase64.h"
@implementation ProfilesNode

- (id)initWithParentNode:(ProfilesNode *)parentNote originInfo:(id)info
{
    self = [super init];
    if (self) {
        _parentNode = parentNote;
        
        if ([info isKindOfClass:[NSDictionary class]]) {
            _type = @"Dictionary";
            
            NSMutableArray *children = [NSMutableArray array];
            NSDictionary *dict = info;
            _detail = [NSString stringWithFormat:@"%lu items", (unsigned long)[dict count]];
            _uuid = [info objectForKey:@"UUID"];
            _filePath = [info objectForKey:@"filePath"];
            _name  =  [info objectForKey:@"Name"];
            
            if(_uuid){
                NSDate *expiration = [dict objectForKey:@"ExpirationDate"];
                _detail =  [[NSDate date] compare:expiration] == NSOrderedDescending ?@"过期(expire)":@"有效(valid)";
            }
            
            for (NSString *key in dict) {
                ProfilesNode *child = [[ProfilesNode alloc]initWithParentNode:self originInfo:dict[key]];
                child.key = key;
                [children addObject:child];
            }
            _childrenNodes = [NSArray arrayWithArray:children];
        }
        else if([info isKindOfClass:[NSArray class]]) {
            _type = @"Array";
            
            NSMutableArray *children = [NSMutableArray array];
            NSArray *array = info;
            _detail = [NSString stringWithFormat:@"%lu items", (unsigned long)[array count]];
            
            for (int i=0; i<[array count]; i++) {
                ProfilesNode *child = [[ProfilesNode alloc]initWithParentNode:self originInfo:array[i]];
                child.key = [NSString stringWithFormat:@"%d", i];
                [children addObject:child];
            }
            _childrenNodes = [NSArray arrayWithArray:children];
        }
        else {
            _detail = [NSString stringWithFormat:@"%@", info];
            
            if ([info isKindOfClass:[NSString class]]) {
                _type = @"String";
            }
            else if([info isKindOfClass:[NSDate class]]){
                _type = @"Date";
            }
            else if([info isKindOfClass:[NSNumber class]]) {
                _type = @"Number";
            }
            else {
                _type = @"Data";
                _detail = [info jk_base64EncodedString];
//                [info writeToFile:[@"/Users/Jakey/Downloads/" stringByAppendingPathComponent:@"info.cer"] atomically:YES];
//                -----BEGIN CERTIFICATE-----
//                  _detail
//                -----END CERTIFICATE-----


            }
        }
        
        if (!parentNote) {
            _key = @"Root";
        }
    }
    
    return self;
}

@end

