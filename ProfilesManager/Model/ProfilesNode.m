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

- (id)initWithRootNode:(ProfilesNode *)rootNode originInfo:(id)info key:(NSString*)key
{
    self = [super init];
    if (self) {
        _rootNode = rootNode;
        _key = key;
        if([info isKindOfClass:[NSDictionary class]] && [info objectForKey:@"AppIDName"]){
            NSMutableDictionary *dict = [info mutableCopy];
            // determine the profile type
            // https://github.com/chockenberry/Provisioning
            BOOL getTaskAllow = NO;
            NSString *value = [info objectForKey:@"Entitlements"];
            if ([value isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dictionary = (NSDictionary *)value;
                getTaskAllow = [[dictionary valueForKey:@"get-task-allow"] boolValue];
            }
            
            BOOL hasDevices = NO;
            value = [info objectForKey:@"ProvisionedDevices"];
            if ([value isKindOfClass:[NSArray class]]) {
                hasDevices = YES;
            }
            
            BOOL isEnterprise = [[info objectForKey:@"ProvisionsAllDevices"] boolValue];
            
            if ([[[[dict objectForKey:@"filePath"] description] pathExtension] isEqualToString:@"provisionprofile"]) {
                
                [dict setObject:@"Mac" forKey:@"ProfilePlatform"];
                if (hasDevices) {
                    [dict setObject:@"Development" forKey:@"ProfileType"];
                }
                else {
                    [dict setObject:@"Distribution (App Store)" forKey:@"ProfileType"];
                }
            }
            else {
                
                [dict setObject:@"iOS" forKey:@"ProfilePlatform"];
                if (hasDevices) {
                    if (getTaskAllow) {
                        [dict setObject:@"Development" forKey:@"ProfileType"];
                    }
                    else {
                        [dict setObject:@"Distribution (Ad Hoc)" forKey:@"ProfileType"];
                    }
                }
                else {
                    if (isEnterprise) {
                        [dict setObject:@"Enterprise" forKey:@"ProfileType"];
                    }
                    else {
                        [dict setObject:@"Distribution (App Store)" forKey:@"ProfileType"];
                    }
                }
            }
            info = [dict copy];

        }
        if ([info isKindOfClass:[NSDictionary class]]) {
            _type = @"Dictionary";
            
            
            NSMutableArray *children = [NSMutableArray array];
            NSDictionary *dict = info;
            _detail = [NSString stringWithFormat:@"%lu items", (unsigned long)[dict count]];
            _uuid = [dict objectForKey:@"UUID"];
            _filePath = [dict objectForKey:@"filePath"];
           
            
            if(_uuid){
                NSDate *expiration = [dict objectForKey:@"ExpirationDate"];
                _detail =  [[NSDate date] compare:expiration] == NSOrderedDescending ?NSLocalizedString(@"expired",nil):NSLocalizedString(@"valid",nil);
                _type  =  [dict objectForKey:@"Name"];
            }
            
            for (NSString *key in dict) {
                ProfilesNode *child = [[ProfilesNode alloc]initWithRootNode:self originInfo:dict[key] key:key];
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
                ProfilesNode *child = [[ProfilesNode alloc]initWithRootNode:self originInfo:array[i] key:[NSString stringWithFormat:@"%d", i]];
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
                if ([self.rootNode.key isEqualToString:@"DeveloperCertificates"]) {
                   NSDictionary *cerInfo =  [self parseCertificate:info];
                    _extra = cerInfo;
                    _key  = [NSString stringWithFormat:@"%@",[cerInfo objectForKey:@"summary"]];
//                    _name = [cerInfo  objectForKey:@"invalidity"];
                    _type = @".cer";
                }
//                [info writeToFile:[@"/Users/Jakey/Downloads/" stringByAppendingPathComponent:@"info.cer"] atomically:YES];
//                -----BEGIN CERTIFICATE-----
//                  _detail
//                -----END CERTIFICATE-----
            }
        }
        
        if (!rootNode && !key) {
            _key = @"Root";
        }
    }
    
    return self;
}
-(NSDictionary*)parseCertificate:(NSData*)data {
    static NSString *const devCertSummaryKey = @"summary";
    static NSString *const devCertInvalidityDateKey = @"invalidity";
    
    NSMutableDictionary *detailsDict;
    SecCertificateRef certificateRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)data);
    if (certificateRef) {
        CFStringRef summaryRef = SecCertificateCopySubjectSummary(certificateRef);
        NSString *summary = (NSString *)CFBridgingRelease(summaryRef);
        if (summary) {
            detailsDict = [NSMutableDictionary dictionaryWithObject:summary forKey:devCertSummaryKey];
            
            CFErrorRef error;
            CFDictionaryRef valuesDict = SecCertificateCopyValues(certificateRef, (__bridge CFArrayRef)@[(__bridge id)kSecOIDInvalidityDate], &error);
            if (valuesDict) {
                CFDictionaryRef invalidityDateDictionaryRef = CFDictionaryGetValue(valuesDict, kSecOIDInvalidityDate);
                if (invalidityDateDictionaryRef) {
                    CFTypeRef invalidityRef = CFDictionaryGetValue(invalidityDateDictionaryRef, kSecPropertyKeyValue);
                    CFRetain(invalidityRef);
                    
                    // NOTE: the invalidity date type of kSecPropertyTypeDate is documented as a CFStringRef in the "Certificate, Key, and Trust Services Reference".
                    // In reality, it's a __NSTaggedDate (presumably a tagged pointer representing an NSDate.) But to sure, we'll check:
                    id invalidity = CFBridgingRelease(invalidityRef);
                    if (invalidity) {
                        if ([invalidity isKindOfClass:[NSDate class]]) {
                            // use the date directly
                            [detailsDict setObject:invalidity forKey:devCertInvalidityDateKey];
                        }
                        else {
                            // parse the date from a string
                            NSString *string = [invalidity description];
                            NSDateFormatter *invalidityDateFormatter = [NSDateFormatter new];
                            [invalidityDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
                            NSDate *invalidityDate = [invalidityDateFormatter dateFromString:string];
                            if (invalidityDate) {
                                [detailsDict setObject:invalidityDate forKey:devCertInvalidityDateKey];
                            }
                        }
                    }
                    else {
                        NSLog(@"No invalidity date in '%@' certificate, dictionary = %@", summary, invalidityDateDictionaryRef);
                        [detailsDict setObject:@"No invalidity date" forKey:devCertInvalidityDateKey];
                    }
                }
                else {
                    NSLog(@"No invalidity values in '%@' certificate, dictionary = %@", summary, valuesDict);
                    [detailsDict setObject:@"No invalidity values" forKey:devCertInvalidityDateKey];

                }
                
                CFRelease(valuesDict);
            }
            else {
                NSLog(@"Could not get values in '%@' certificate, error = %@", summary, error);
            }
            
        }
        else {
            NSLog(@"Could not get summary from certificate");
        }
        
        CFRelease(certificateRef);
    }
    return detailsDict;

}
@end

