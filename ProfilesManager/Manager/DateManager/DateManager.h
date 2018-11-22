//
//  DateManager.h
//  ProfilesManager
//
//  Created by Jakey on 2018/11/7.
//  Copyright © 2018 Jakey. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DateManager : NSObject
+ (DateManager *)sharedManager;
- (NSString *)stringConvert_YMDHM_FromDate:(NSDate *)date;
- (NSString *)stringConvert_Y_M_D_H_M_FromDate:(NSDate *)date;
@end
