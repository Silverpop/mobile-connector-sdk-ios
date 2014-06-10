//
//  UBFAugmentationManager.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/10/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "UBFAugmentationManager.h"
#import "EngageConfigManager.h"
#import "UBFAugmentationPluginProtocol.h"
#import "UBFCoordinatesAugmentationPlugin.h"
#import "UBFPlacemarkAugmentationPlugin.h"
#import "EngageConfig.h"
#import "EngageExpirationParser.h"
#import "UBFAugmentationOperation.h"
#import "EngageLocalEventStore.h"

@interface UBFAugmentationManager()

@property (strong, nonatomic) NSMutableArray *augmentationPlugins;
@property (strong, nonatomic) EngageConfigManager *ecm;
@property (assign) long augmentationTimeoutSeconds;

@property (strong, nonatomic) NSOperationQueue *augmentationQueue;
@property (strong, nonatomic) EngageLocalEventStore *engageLocalEventStore;

@end

@implementation UBFAugmentationManager

__strong static UBFAugmentationManager *_sharedInstance = nil;

-(id)init {
    self = [super init];
    if (self) {
        _sharedInstance = [[UBFAugmentationManager alloc] init];
        _sharedInstance.ecm = [EngageConfigManager sharedInstance];
        
        EngageExpirationParser *exp = [[EngageExpirationParser alloc] initWithExpirationString:[_sharedInstance.ecm configForAugmentationServiceFieldName:PLIST_AUGMENTATION_SERVICE_TIMEOUT] fromDate:nil];
        _sharedInstance.augmentationTimeoutSeconds = [exp secondsParsedFromExpiration];
        
        _sharedInstance.augmentationPlugins = [NSMutableArray new];
        
        //Adds default Augmentation plugins.
        UBFCoordinatesAugmentationPlugin *coordsPlugin = [[UBFCoordinatesAugmentationPlugin alloc] init];
        UBFPlacemarkAugmentationPlugin *placemarkPlugin = [[UBFPlacemarkAugmentationPlugin alloc] init];
        [_sharedInstance.augmentationPlugins addObject:coordsPlugin];
        [_sharedInstance.augmentationPlugins addObject:placemarkPlugin];
        
        //Creates the Augmentation Queue.
        _sharedInstance.augmentationQueue = [[NSOperationQueue alloc] init];
        _sharedInstance.engageLocalEventStore = [EngageLocalEventStore sharedInstance];
    }
    return self;
}


+(instancetype)sharedInstance {
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[UBFAugmentationManager alloc] init];
    });
    
    return _sharedInstance;
}

-(void)addAugmentationPlugin:(id)augmentationPlugin {
    if (_sharedInstance.augmentationPlugins) {
        [_sharedInstance.augmentationPlugins addObject:augmentationPlugin];
    }
}

-(void)augmentUBFEvent:(UBF*)ubfEvent withEngageEvent:(EngageEvent *)engageEvent {
    if (ubfEvent && engageEvent) {
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW,
                    _sharedInstance.augmentationTimeoutSeconds * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
        
        UBFAugmentationOperation *augOperation = [[UBFAugmentationOperation alloc] initWithPlugins:_sharedInstance.augmentationPlugins ubfEvent:ubfEvent engageEvent:engageEvent];
        
        [_sharedInstance.augmentationQueue addOperation:augOperation];
        
        // If timer is reached then the Operation has timed out.
        dispatch_source_set_event_handler(_timer, ^{
            dispatch_source_cancel(_timer);
            [augOperation cancel];
            NSLog(@"Augmentation service timed out");
            engageEvent.eventStatus = [NSNumber numberWithInt:EXPIRED];
            [_sharedInstance.engageLocalEventStore saveEvents];
        });
        dispatch_resume(_timer);
    }
}

@end
