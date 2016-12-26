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

- (id)initWithParentNode:(ProfilesNode *)parentNote originInfo:(id)info key:(NSString*)key
{
    self = [super init];
    if (self) {
        _parentNode = parentNote;
        _key = key;

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
                ProfilesNode *child = [[ProfilesNode alloc]initWithParentNode:self originInfo:dict[key] key:key];
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
                ProfilesNode *child = [[ProfilesNode alloc]initWithParentNode:self originInfo:array[i] key:[NSString stringWithFormat:@"%d", i]];
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
                if ([self.parentNode.key isEqualToString:@"DeveloperCertificates"]) {
                   NSDictionary *cerInfo =  [self parseCertificate:info];
                    _key  = [NSString stringWithFormat:@"%@",[cerInfo  objectForKey:@"summary"]];
                    _name = [cerInfo  objectForKey:@"invalidity"];
                    _type = @".cer";

                }
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

