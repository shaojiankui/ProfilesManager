//
//  DateManager.m
//  ProfilesManager
//
//  Created by Jakey on 2018/11/7.
//  Copyright © 2018 Jakey. All rights reserved.
//

#import "DateManager.h"
@interface DateManager ()
@property (nonatomic, strong) NSDateFormatter *dateForrmatter;
@end
@implementation DateManager

static dispatch_once_t onceTokenForDateManager;
static DateManager *_dateManager = nil;
+ (DateManager *)sharedManager
{
    
    dispatch_once(&onceTokenForDateManager, ^{
        _dateManager = [[self alloc] init];
    });
    return _dateManager;
}
- (id)init
{
    self = [super init];
    if (self) {
        _dateForrmatter = [[NSDateFormatter alloc] init];
        [_dateForrmatter setLocale:[NSLocale currentLocale]];
        [_dateForrmatter setTimeZone:[NSTimeZone localTimeZone]];
//        [_dateForrmatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3600*8]];
    }
    return self;
}
- (NSString *)stringConvert_YMDHM_FromDate:(NSDate *)date{
    [_dateForrmatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [_dateForrmatter stringFromDate:date];
}
- (NSString *)stringConvert_Y_M_D_H_M_FromDate:(NSDate *)date{
    [_dateForrmatter setDateFormat:@"yyyy-MM-dd-HH-mm"];
    return [_dateForrmatter stringFromDate:date];
}
@end
