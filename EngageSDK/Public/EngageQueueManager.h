//
//  EngageQueueManager.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 4/22/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AFOAuth2Client.h"
#import "XMLAPI.h"

@interface EngageQueueManager : AFOAuth2Client

+ (EngageQueueManager *)sharedInstance;

- (void)enqueueEvent:(NSDictionary *)event;
- (void)enqueueXMLAPIEvent:(XMLAPI *)xmlApiEvent;

@property AFOAuthCredential *credential;

@end
