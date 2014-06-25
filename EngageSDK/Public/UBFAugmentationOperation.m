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
        
//        [[NSNotificationCenter defaultCenter] addObserverForName:PLUGIN_SUPPLEMENTAL_DATA_AVAILABLE
//                                                          object:nil
//                                                           queue:[NSOperationQueue mainQueue]
//                                                      usingBlock:^(NSNotification *note) {
//                                                          
//                                                          NSLog(@"Plugin Supplemental data is now available for Plugin Class %@", [note.object class]);
//                                                      }];
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
            
            if ([plugin isSupplementalDataReady]) {
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
        
        if (![self isCancelled] && [notProcessedPlugins count] == 0) {
            //Cancel the pending timer of doom.
            dispatch_source_cancel(self.timeoutTimer);
            
            self.engageEvent.eventJson = [self.ubfEvent jsonValue];
            self.engageEvent.eventStatus = [NSNumber numberWithInt:NOT_POSTED];
            [[EngageLocalEventStore sharedInstance] saveEvents];
        }
        
        UBFManager *ubfManager = [UBFManager sharedInstance];
        [ubfManager postEventCache];
    }
}

//-(void)cancel {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

@end
