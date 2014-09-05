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
#import "EngageConfig.h"
#import "EngageExpirationParser.h"
#import "UBFAugmentationOperation.h"
#import "EngageLocalEventStore.h"
#import "UBFManager.h"

@interface UBFAugmentationManager()

@property (strong, nonatomic) EngageConfigManager *ecm;
@property (assign) long augmentationTimeoutSeconds;

@property (strong, nonatomic) NSOperationQueue *augmentationQueue;
@property (strong, nonatomic) EngageLocalEventStore *engageLocalEventStore;

@property (assign) int eventsToCacheBeforePost;
@property (assign) int eventsCached;

@end

@implementation UBFAugmentationManager

__strong static UBFAugmentationManager *_sharedInstance = nil;

-(id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


+(instancetype)sharedInstance {
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[UBFAugmentationManager alloc] init];
        _sharedInstance.ecm = [EngageConfigManager sharedInstance];
        
        EngageExpirationParser *exp = [[EngageExpirationParser alloc] initWithExpirationString:[_sharedInstance.ecm configForAugmentationServiceFieldName:PLIST_AUGMENTATION_SERVICE_TIMEOUT] fromDate:nil];
        _sharedInstance.augmentationTimeoutSeconds = [exp secondsParsedFromExpiration];
        
        _sharedInstance.augmentationPlugins = [NSMutableArray new];
        
        NSArray *pluginClassNames = [[EngageConfigManager sharedInstance] augmentationPluginClassNames];
        for (NSString *className in pluginClassNames) {
            NSLog(@"Creating Augmentation Plugin %@", className);
            [_sharedInstance.augmentationPlugins addObject:[[NSClassFromString(className) alloc] init]];
        }
        
        //Creates the Augmentation Queue.
        _sharedInstance.augmentationQueue = [[NSOperationQueue alloc] init];
        _sharedInstance.engageLocalEventStore = [EngageLocalEventStore sharedInstance];
        
        _sharedInstance.eventsCached = 0;
        _sharedInstance.eventsToCacheBeforePost = [[[EngageConfigManager sharedInstance] numberConfigForGeneralFieldName:PLIST_GENERAL_UBF_EVENT_CACHE_SIZE] intValue];
        
        //Register for Augmentation events.
        [[NSNotificationCenter defaultCenter] addObserverForName:AUGMENTATION_SUCCESSFUL_EVENT
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          [_sharedInstance updateCachedCounts];
                                                      }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:AUGMENTATION_EXPIRED_EVENT
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          [_sharedInstance updateCachedCounts];
                                                      }];
    });
    
    return _sharedInstance;
}

-(void)zeroOutLocalCacheSize {
    _sharedInstance.eventsCached = 0;
}

- (void)updateCachedCounts {
    _sharedInstance.eventsCached++;
    if (_sharedInstance.eventsCached >= _sharedInstance.eventsToCacheBeforePost) {
        _sharedInstance.eventsCached = 0;
        [[UBFManager sharedInstance] postEventCache];
    }
}

-(void)augmentUBFEvent:(UBF*)ubfEvent withEngageEvent:(EngageEvent *)engageEvent {
    if (ubfEvent && engageEvent && self.augmentationPlugins) {
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW,
                                                        _sharedInstance.augmentationTimeoutSeconds * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
        
        UBFAugmentationOperation *augOperation = [[UBFAugmentationOperation alloc] initWithPlugins:_sharedInstance.augmentationPlugins
                                                                                          ubfEvent:ubfEvent
                                                                                       engageEvent:engageEvent
                                                                                             timer:_timer];
        
        [_sharedInstance.augmentationQueue addOperation:augOperation];
        
        // If timer is reached then the Operation has timed out.
        dispatch_source_set_event_handler(_timer, ^{
            NSLog(@"UBF event augmentation timed out");
            engageEvent.eventStatus = [NSNumber numberWithInt:EXPIRED];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:AUGMENTATION_EXPIRED_EVENT object:engageEvent];
            
            [augOperation cancel];
            dispatch_source_cancel(_timer);
        });
        dispatch_resume(_timer);
    } else {
        NSLog(@"DEBUG control reached due to UBFEvent, EngageEvent, or AugmentationPlugins array being nil");
    }
}

@end
