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
@property (strong, nonatomic) NSDate *expirationDate;

@property (assign) NSInteger dayValue;
@property (assign) NSInteger hourValue;
@property (assign) NSInteger minuteValue;
@property (assign) NSInteger secondValue;

@end

@implementation EngageExpirationParser

__strong static NSString *regexPattern = @"(\\d+\\s*[d|h|m|s|D|H|M|S])";
__strong static NSString *valueRegexPattern = @"(\\d+)";


- (id) initWithExpirationString:(NSString *)expirationString
                       fromDate:(NSDate *)date {
    self = [super init];
    
    self.fromDate = date;
    self.dayValue = -1;
    self.hourValue = -1;
    self.minuteValue = -1;
    self.secondValue = -1;
    
    // Create a regular expression
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:0 error:&error];
    if (error) {
        NSLog(@"Couldn't create regex with given string and options");
    }
    
    NSArray *matches = [regex matchesInString:expirationString options:0 range:NSMakeRange(0, [expirationString length])];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match rangeAtIndex:1];
        NSString *result = [expirationString substringWithRange:matchRange];
        
        NSInteger value = [self valueFromRegexResult:result];
        if ([self string:result contains:@"d"]) {
            self.dayValue = value;
        } else if ([self string:result contains:@"h"]) {
            self.hourValue = value;
        } else if ([self string:result contains:@"m"]) {
            self.minuteValue = value;
        } else if ([self string:result contains:@"s"]) {
            self.secondValue = value;
        } else {
            NSLog(@"EngageExpirationParser Regex result %@ does not match any pattern", result);
        }
    }
    
    //Creates the actual expiration date.
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    if (self.dayValue > -1) {
        [dateComponents setDay:self.dayValue];
    }
    if (self.hourValue > -1) {
        [dateComponents setHour:self.hourValue];
    }
    if (self.minuteValue > -1) {
        [dateComponents setMinute:self.minuteValue];
    }
    if (self.secondValue > -1) {
        [dateComponents setSecond:self.secondValue];
    }
    
    self.expirationDate = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
    
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
    return self.expirationDate;
}

@end
