//
//  UBFTests.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "UBFTests.h"
#import "UBFClient.h"
#import "UBF.h"

@implementation UBFTests

- (void)testAuthentication
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    
    UBFClient *clientUBF = [UBFClient createClient:@"ae58e0fd-310e-4423-a157-208e342f1cbb"
                                            secret:@"f447039c-7d3f-46b0-9a5e-36b85d39e7f4"
                                             token:@"96338534-7c47-48af-9961-836eca933632"];
    
    [clientUBF connectSuccess:^(AFOAuthCredential *credential) {
        STAssertNotNil(credential,@"Could not load credentials");
        NSLog(@"%@",[credential debugDescription]);
        NSLog(@"SUCCESS");
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSError *failure) {
        NSLog(@"FAIL");
        STFail(@"OAuth failed");
        dispatch_semaphore_signal(semaphore);
    }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    dispatch_release(semaphore);
}

- (void)testEventInstalled
{
    [[UBFClient client] trackingEvent:[UBF installed:nil]];
    
    [[UBFClient client] trackingEvent:[UBF sessionStarted:nil]];
    
    [[UBFClient client] trackingEvent:[UBF sessionEnded:nil]];
    
    [[UBFClient client] trackingEvent:[UBF goalAbandoned:nil]];
}


@end
