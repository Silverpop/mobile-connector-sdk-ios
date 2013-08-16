//
//  UBFClient.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "UBFClient.h"
#import "UBF.h"
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <UIKit/UIKit.h>

NSString * const kEngageClientInstalled = @"engageClientInstalled";

@interface UBFClient ()

@property NSMutableArray *events;
@property NSDictionary *sessionEnded;
@property NSDate *sessionExpires;
@property(nonatomic) NSDate *sessionBegan;
@property NSTimeInterval duration;

@property NSInteger queueSize;
@property NSInteger minCode;
@property(nonatomic) NSTimeInterval sessionTimeout;

@end


@implementation UBFClient

__strong static UBFClient *_sharedClient = nil;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)createClient:(NSString *)clientId
                      secret:(NSString *)secret
                       token:(NSString *)refreshToken
                        host:(NSString *)hostUrl {
    
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedClient = [[self alloc] initWithHost:hostUrl clientId:clientId secret:secret token:refreshToken];
        _sharedClient.events = [NSMutableArray array];
        _sharedClient.queueSize = 3; // three events trigger post
        _sharedClient.minCode = 15; // Session Ended event code
        _sharedClient.sessionTimeout = 300; // 5 minutes
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *installed = [defaults objectForKey:kEngageClientInstalled];
        if (![installed boolValue]) { // nil or false
            // installed event
            [_sharedClient trackingEvent:[UBF installed:nil]];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"YES" forKey:kEngageClientInstalled];
            [defaults synchronize];
        }
        
        // start session
        [_sharedClient restartSession];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          NSLog(@"Engage resume session");
                                                          if ([_sharedClient sessionExpired]) {
                                                              NSLog(@"Engage Session Expired");
                                                              [_sharedClient restartSession];
                                                          }
                                                          else {
                                                              _sharedClient.sessionBegan = [NSDate date];
                                                          }
                                                      }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          NSLog(@"Engage pause session");
                                                          // now - start|resume + duration
                                                          _sharedClient.duration += [[NSDate date] timeIntervalSinceDate:_sharedClient.sessionBegan];
                                                          _sharedClient.sessionEnded = [UBF sessionEnded:@{@"Session Duration":[NSString stringWithFormat:@"%d",(int)_sharedClient.duration]}];
                                                          _sharedClient.sessionExpires = [NSDate dateWithTimeInterval:_sharedClient.sessionTimeout
                                                                                                            sinceDate:[NSDate date]];
                                                          [_sharedClient postEventCache];
                                                      }];
    });
    return _sharedClient;
}

+ (instancetype)client
{
    return _sharedClient;
}

- (void)restartSession {
    if (_sharedClient.sessionEnded) [self trackingEvent:_sharedClient.sessionEnded];
    [self trackingEvent:[UBF sessionStarted:nil]];
    _sharedClient.sessionBegan = [NSDate date];
    self.duration = 0.0f;
}

- (BOOL)sessionExpired {
    return [_sessionExpires compare:[NSDate date]] == NSOrderedAscending;
}

- (void)trackingEvent:(NSDictionary *)event {
    [_events addObject:event];
    
    NSString *code = [event valueForKeyPath:@"eventTypeCode"];
    // if we have queued at least 3 events
    // or we have reached end of session
    if (_events.count > _queueSize || [code integerValue] > _minCode) {
        // post events to service
        [self postEventCache];
    }
}

- (void)postEventCache {
    if (_events.count == 0) return;
    
    NSArray *eventsCache = [_events copy];
    [_events removeAllObjects];
    
    NSDictionary *params = @{ @"events" : eventsCache };
    
    [self setParameterEncoding:AFJSONParameterEncoding];
    
    [self postPath:@"/rest/events/submission" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",[operation debugDescription]);
        NSLog(@"%@",[responseObject debugDescription]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[operation debugDescription]);
        NSLog(@"%@",[error debugDescription]);
        
        NSLog(@"-----CACHED FAILED OPERATION-----");
        // requeue to be retried later
        [_events addObjectsFromArray:eventsCache];
    }];
}

- (void)enqueueEvent:(NSDictionary *)event {
    [_events addObject:event];
    NSArray *eventsCache = [_events copy];
    [_events removeAllObjects];
    
    NSDictionary *params = @{ @"events" : eventsCache };
    
    [self setParameterEncoding:AFJSONParameterEncoding];
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"/rest/events/submission" parameters:params];
    AFHTTPRequestOperation *operation =
    [self HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"%@",[operation debugDescription]);
                                         NSLog(@"%@",[responseObject debugDescription]);
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"%@",[operation debugDescription]);
                                         NSLog(@"%@",[error debugDescription]);
                                         
                                         NSArray *ops = [[self operationQueue] operations];
                                         if (![ops containsObject:operation]) {
                                             NSLog(@"-----REQUEUED FAILED OPERATION-----");
                                             // requeue operation if it failed
                                             [self enqueueHTTPRequestOperation:operation];
                                         }
                                         
                                     }];
    
    
    [self enqueueHTTPRequestOperation:operation];
}

@end
