//
//  EngageDateFormatter.m
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/27/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import "EngageDateFormatter.h"

@implementation EngageDateFormatter

/**
 *  Get GMT date string for current time
 *
 *  @return date string for current time formatted as like "2015-01-28 01:36:50 GMT"
 */
+ (NSString *)nowGmtString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss zzz";
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    return timeStamp;
}

@end
