//
//  EngageExpirationParser.m
//  ExpirationParser
//
//  Created by Jeremy Dyer on 5/28/14.
//  Copyright (c) 2014 Jeremy Dyer. All rights reserved.
//

#import "EngageExpirationParser.h"

@interface EngageExpirationParser()

@property (strong, nonatomic) NSDate *fromDate;
@property (strong, nonatomic) NSDate *expiresAtDate;

@property (assign) NSInteger dayValue;
@property (assign) NSInteger hourValue;
@property (assign) NSInteger minuteValue;
@property (assign) NSInteger secondValue;

@end

@implementation EngageExpirationParser

__strong static NSString *regexPattern = @"(\\d+\\s*[d|h|m|s|D|H|M|S])";
__strong static NSString *expirationDateRegexPattern = @"(\\d{4}/\\d{2}/\\d{2}\\s{1}\\d{2}:\\d{2}:\\d{2})";
__strong static NSString *valueRegexPattern = @"(\\d+)";
__strong static NSString *engageDatePattern = @"yyyy'/'MM'/'dd' 'HH':'mm':'ss'";


- (id) initWithExpirationString:(NSString *)expirationString
                       fromDate:(NSDate *)date {
    self = [super init];
    
    self.fromDate = date;
    self.dayValue = -1;
    self.hourValue = -1;
    self.minuteValue = -1;
    self.secondValue = -1;
    self.expiresAtDate = nil;
    
    // Create a regular expression
    NSError *error = NULL;
    NSRegularExpression *validForRegex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:0 error:&error];
    if (error) {
        NSLog(@"Couldn't create valid for regex with given string and options");
    }
    
    NSArray *matches = [validForRegex matchesInString:expirationString options:0 range:NSMakeRange(0, [expirationString length])];
    if (matches == nil || [matches count] == 0) {
        //Lets try the expiration date regex now.
        NSRegularExpression *expiresAtRegex = [NSRegularExpression regularExpressionWithPattern:expirationDateRegexPattern options:0 error:&error];
        matches = [expiresAtRegex matchesInString:expirationString options:0 range:NSMakeRange(0, [expirationString length])];
    }
    
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match rangeAtIndex:0];
        
        NSString *result = [expirationString substringWithRange:matchRange];
        
        if ([self string:result contains:@"d"]) {
            self.dayValue = [self valueFromRegexResult:result];
        } else if ([self string:result contains:@"h"]) {
            self.hourValue = [self valueFromRegexResult:result];
        } else if ([self string:result contains:@"m"]) {
            self.minuteValue = [self valueFromRegexResult:result];
        } else if ([self string:result contains:@"s"]) {
            self.secondValue = [self valueFromRegexResult:result];
        } else if ([self string:result contains:@"/"]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"UTC"];
            [dateFormatter setDateFormat:engageDatePattern];
            [dateFormatter setTimeZone:timeZone];
            
            //Parse the result into the new date.
            self.expiresAtDate = [dateFormatter dateFromString:result];
            NSLog(@"Date %@", self.expiresAtDate);
        } else {
            NSLog(@"EngageExpirationParser Regex result '%@' does not match any pattern", result);
        }
    }
    
    //If the expiration date was not already set by the parameter than it is set here.
    if (self.expiresAtDate == nil) {
        //Creates the actual expiration date.
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//        NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"UTC"];
//        [calendar setTimeZone:timeZone];
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//        [dateComponents setTimeZone:timeZone];
        if (self.dayValue > -1) [dateComponents setDay:self.dayValue];
        if (self.hourValue > -1) [dateComponents setHour:self.hourValue];
        if (self.minuteValue > -1) [dateComponents setMinute:self.minuteValue];
        if (self.secondValue > -1) [dateComponents setSecond:self.secondValue];
        
        self.expiresAtDate = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
    }
    
    return self;
}

- (BOOL) string:(NSString *)string contains:(NSString *)containString {
    NSRange searchRange = [string rangeOfString:containString options:NSCaseInsensitiveSearch];
    if (searchRange.length == 1) {
        return YES;
    } else {
        return NO;
    }
}

- (NSInteger) valueFromRegexResult:(NSString *)regexResult {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:valueRegexPattern options:0 error:&error];
    if (error) {
        NSLog(@"Couldn't create regex with given string and options");
    }
    
    NSArray *matches = [regex matchesInString:regexResult options:0 range:NSMakeRange(0, [regexResult length])];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match rangeAtIndex:1];
        NSString *result = [regexResult substringWithRange:matchRange];
        return [result integerValue];
    }
    
    return -1;
}


- (long)expirationTimeStamp {
    return [self.expirationDate timeIntervalSince1970];
}


- (NSDate *)expirationDate {
    return self.expiresAtDate;
}

- (long)secondsParsedFromExpiration {
    long seconds = 0;
    if (self.dayValue > -1) seconds = self.dayValue * 86400;
    if (self.hourValue > -1) seconds = seconds + self.hourValue * 3600;
    if (self.minuteValue > -1) seconds = seconds + self.minuteValue * 60;
    if (self.secondValue > -1) seconds = seconds + self.secondValue;
    return seconds;
}

- (long)millisecondsParsedFromExpiration {
    return ([self secondsParsedFromExpiration] * 1000);
}

@end
