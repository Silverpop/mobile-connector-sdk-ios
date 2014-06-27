//
//  UBFAugmentationOperation.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/10/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "UBFAugmentationOperation.h"
#import "UBFAugmentationPluginProtocol.h"
#import "EngageLocalEventStore.h"
#import "EngageConfig.h"
#import "UBFManager.h"

@interface UBFAugmentationOperation()

@property(nonatomic, strong)NSMutableArray *augmentationPlugins;
@property(nonatomic, strong)UBF *ubfEvent;
@property(nonatomic, strong)EngageEvent *engageEvent;
@property(assign)dispatch_source_t timeoutTimer;

@end

@implementation UBFAugmentationOperation

-(id)initWithPlugins:(NSMutableArray *)augPlugins
            ubfEvent:(UBF *)ubfEvent
         engageEvent:(EngageEvent *)engageEvent
               timer:(dispatch_source_t) timeoutTimer {
    
    self = [super init];
    
    if (self) {
        self.augmentationPlugins = augPlugins;
        self.ubfEvent = ubfEvent;
        self.engageEvent = engageEvent;
        self.timeoutTimer = timeoutTimer;
    }
    return self;
}

-(void)main {
    @autoreleasepool {
        
        int index = 0;
        NSMutableArray *notProcessedPlugins = [self.augmentationPlugins mutableCopy];
        
        while (![self isCancelled] && [notProcessedPlugins count] > 0) {
            if (index >= [notProcessedPlugins count]) {
                index = 0;
            }
            
            id plugin = [notProcessedPlugins objectAtIndex:index];
            
            if ([plugin isSupplementalDataReady:self.ubfEvent]) {
                self.ubfEvent = [plugin process:self.ubfEvent];
                [notProcessedPlugins removeObjectAtIndex:index];
                //Index does not need to be updated since the list size has decreased by one.
            } else if (![plugin processSyncronously]) {
                index++;
            } else {
                //Lets pause execution for a moment to prevent eating up CPU cycles.
                [NSThread sleepForTimeInterval:0.1f];   //Sleep for 100ms
            }
        }
        
        NSString *notificationMessage;
        
        if (![self isCancelled] && [notProcessedPlugins count] == 0) {
            self.engageEvent.eventStatus = [NSNumber numberWithInt:NOT_POSTED];
            notificationMessage = AUGMENTATION_SUCCESSFUL_EVENT;
            
            //Cancel the pending timer of doom.
            if (self.timeoutTimer) {
                dispatch_source_cancel(self.timeoutTimer);
            }
        } else {
            self.engageEvent.eventStatus = [NSNumber numberWithInt:EXPIRED];
            notificationMessage = AUGMENTATION_EXPIRED_EVENT;
        }
        
        self.engageEvent.eventJson = [self.ubfEvent jsonValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationMessage object:self.engageEvent];
    }
}

@end
