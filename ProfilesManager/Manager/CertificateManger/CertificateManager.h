//
//  CertificateManager.h
//  ProfilesManager
//
//  Created by Jakey on 2020/3/22.
//  Copyright © 2020 Jakey. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CertificateManager : NSObject
+ (NSDictionary*)readCertificateInfo:(NSData *)certificateData;
@end

NS_ASSUME_NONNULL_END
