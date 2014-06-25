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
#import "UBFManager.h"

@interface UBFAugmentationOperation()

@property(nonatomic, strong)NSMutableArray *augmentationPlugins;
@property(nonatomic, strong)UBF *ubfEvent;
@property(nonatomic, strong)EngageEvent *engageEvent;

@end

@implementation UBFAugmentationOperation

-(id)initWithPlugins:(NSMutableArray *)augPlugins ubfEvent:(UBF *)ubfEvent engageEvent:(EngageEvent *)engageEvent {
    self = [super init];
    if (self) {
        self.augmentationPlugins = augPlugins;
        self.ubfEvent = ubfEvent;
        self.engageEvent = engageEvent;
    }
    return self;
}

-(void)main {
    @autoreleasepool {
        
        int index = 0;
        NSMutableArray *notProcessedPlugins = [self.augmentationPlugins copy];
        
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
            }
        }
        
        if (![self isCancelled] && [notProcessedPlugins count] == 0) {
            self.engageEvent.eventJson = [self.ubfEvent jsonValue];
            self.engageEvent.eventStatus = [NSNumber numberWithInt:NOT_POSTED];
            [[EngageLocalEventStore sharedInstance] saveEvents];
        }
        
        UBFManager *ubfManager = [UBFManager sharedInstance];
        [ubfManager postEventCache];
    }
}

@end
