//
//  XMLAPITests.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "XMLAPITests.h"
#import "ResultDictionary.h"
#import "XMLAPIClient.h"
#import "XMLAPI.h"

@implementation XMLAPITests

- (void)testAuthentication {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    XMLAPIClient *client = [XMLAPIClient createClient:@"ae58e0fd-310e-4423-a157-208e342f1cbb"
                                               secret:@"f447039c-7d3f-46b0-9a5e-36b85d39e7f4"
                                                token:@"96338534-7c47-48af-9961-836eca933632"];
    
    [client connectSuccess:^(AFOAuthCredential *success) {
        NSLog(@"SUCCESS");
        dispatch_semaphore_signal(semaphore); 
    } failure:^(NSError *failure) {
        NSLog(@"FAIL");
        dispatch_semaphore_signal(semaphore); 
    }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    dispatch_release(semaphore);
}

- (void)testResourceAddRecipient {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    XMLAPI *addRecipient = [XMLAPI addRecipient:@"somebodyelse@ehirelabs.com" list:@"19943"];
    NSDictionary *phone = @{@"PHONE": @"678-778-8888"};
    [addRecipient addSyncFields:phone];
    [addRecipient addColumns:phone];
    
    [[XMLAPIClient client] postResource:addRecipient success:^(id ERXML) {
        STAssertNotNil(ERXML,@"Could not load response");
        STAssertNotNil([ERXML valueForShortPath:@"recipientid"],@"RecipientId was not found after AddRecipient call");
//        NSLog(@"ERXML\n\n%@\n\n",[ERXML debugDescription]);
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSError *error) {
        STFail(@"AddRecipient failed");
        [error debugDescription];
        dispatch_semaphore_signal(semaphore); 
    }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    dispatch_release(semaphore);
}

- (void)testResourceSelectRecipientData {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    XMLAPI *selectRecipientData = [XMLAPI selectRecipientData:@"somebodyelse@ehirelabs.com" list:@"19943"];
    
    [[XMLAPIClient client] postResource:selectRecipientData success:^(id ERXML) {
        STAssertNotNil(ERXML,@"Could not load response");
        STAssertNotNil([ERXML valueForShortPath:@"success"],@"Success was not found after SelectRecipientData call");
//        NSLog(@"ERXML\n\n%@\n\n",[ERXML debugDescription]);
//        NSLog(@"ERXML[success]\n\n%@\n\n",[ERXML valueForShortPath:@"success"]);
//        NSLog(@"ERXML[columns.mobile]\n\n%@\n\n",[ERXML valueForShortPath:@"columns.mobile"]);
//        NSLog(@"ERXML[columns.phone]\n\n%@\n\n",[ERXML valueForShortPath:@"columns.phone"]);
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSError *error) {
        STFail(@"SelectRecipientData failed");
        [error debugDescription];
        dispatch_semaphore_signal(semaphore); 
    }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    dispatch_release(semaphore);
}

@end
