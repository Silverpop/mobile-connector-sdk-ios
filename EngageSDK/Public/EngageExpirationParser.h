//
//  EngageExpirationParser.h
//  ExpirationParser
//
//  Created by Jeremy Dyer on 5/28/14.
//  Copyright (c) 2014 Jeremy Dyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EngageExpirationParser : NSObject

- (id) initWithExpirationString:(NSString *)expirationString fromDate:(NSDate *)date;

- (long)expirationTimeStamp;
- (NSDate *)expirationDate;

//Given the expiration string the number of seconds parsed from the value.
- (long)secondsParsedFromExpiration;
- (long)millisecondsParsedFromExpiration;

@end
