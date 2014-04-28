//
//  EngageQueueManager.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 4/22/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "EngageQueueManager.h"
#import <CoreData/CoreData.h>
#import "EngageEvent.h"
#import "EngageLocalEventStore.h"
#import "EngageClient.h"
#import "ResultDictionary.h"
#import "EngageResponseXML.h"
//#import "Reachability.h"

#define REACHABILITY_URL @"http://pilot.silverpop.com/XMLAPI"

//#define ENGAGE_URL_ENDPOINT @"http://pilot.silverpop.com/XMLAPI"
//#define ENGAGE_LIST_ID @"19278"
//#define ENGAGE_LOGIN_USERNAME @"slytle@ehirelabs.com"
//#define ENGAGE_LOGIN_PASSWORD @"k727/9369[22EtH8J8v62(k44^Ko36B3T69P"

@interface EngageQueueManager ()

@property (nonatomic) NSOperationQueue* engageOperationsQueue;
//@property (nonatomic, strong) Reachability *reachability;

@property (nonatomic, strong) EngageClient *engageClient;

@end

@implementation EngageQueueManager

- (id) init {
    
    self.engageClient = [[EngageClient alloc] initWithHost:REACHABILITY_URL
                                                  clientId:@"ae58e0fd-310e-4423-a157-208e342f1cbb"
                                                    secret:@"f447039c-7d3f-46b0-9a5e-36b85d39e7f4"
                                                     token:@"96338534-7c47-48af-9961-836eca933632"];
    
    self = [super initWithBaseURL:[NSURL URLWithString:REACHABILITY_URL]];
    if (self) {
        self.engageOperationsQueue = [[NSOperationQueue alloc] init];
        
//        //Set up Reachability notificaitons.
//        self.reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
//        [self.reachability startNotifier];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(handleNetworkChange:)
//                                                     name:kReachabilityChangedNotification
//                                                   object:nil];
        
        // Check for events in Core Data that have not be posted to Silverpop
        NSArray *unpostedLocalEvents = [[EngageLocalEventStore sharedInstance] findUnpostedEvents];
        NSLog(@"Re-queueing %lu unposted local events to Silverpop from events local store", (unsigned long)[unpostedLocalEvents count]);
        for (EngageEvent *unpostedEvent in unpostedLocalEvents) {
            [self enqueueEngageEvent:unpostedEvent];
        }
        
        //Check for expired events that should be removed from the local store
        [[EngageLocalEventStore sharedInstance] deleteExpiredLocalEvents];
    }
    
    return self;
}

+ (EngageQueueManager *)sharedInstance
{
    static EngageQueueManager *sharedInstance = nil;
    static dispatch_once_t isDispatched;
    
    dispatch_once(&isDispatched, ^{
        sharedInstance = [[EngageQueueManager alloc] init];
    });
    
    return sharedInstance;
}

//- (void)enqueueXMLAPIEvent:(XMLAPI *)xmlApiEvent {
//    NSError *error;
//    if (![[EngageLocalEventStore sharedInstance].managedObjectContext save:&error]) {
//        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//    }
//    
//    //Attempt to post the event to Silverpop by enqueuing the event in the engageOperationsQueue.
//    [self.engageOperationsQueue addOperationWithBlock:^{
//        
//        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[xmlApiEvent envelope], @"xml", nil];
//        NSLog(@"Operation Params %@", params.description);
//        [self postPath:@"/XMLAPI" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            ResultDictionary *ERXML = [EngageResponseXML decode:responseObject];
//            NSLog(@"%@", ERXML);
//            //[engageEvent setEventHasPosted:[[NSNumber alloc] initWithInt: 1]];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"Failure in operation .... =(");
//            //[engageEvent setEventHasPosted:[[NSNumber alloc] initWithInt: 0]];
//        }];
//        
//        //        if (self.credential.isExpired) {
//        //            NSLog(@"%@",@"Session expired...attempting to reconnect");
//        //            [super connectSuccess:^(AFOAuthCredential *credential) {
//        //                self.credential = credential;
//        //                postResource();
//        //            } failure:failure];
//        //        }
//        //        else {
//        //            postResource();
//        //        }
//        
//        //Updates the CoreData context.
//        NSError *error;
//        if (![[EngageLocalEventStore sharedInstance].managedObjectContext save:&error]) {
//            NSLog(@"Unable to mark EngageEvent as POSTED in the EngageQueueManger success block!");
//        } else {
//            NSLog(@"EngageEvent has been marked as posted to the server");
//        }
//    }];
//
//}

- (void) enqueueEngageEvent:(EngageEvent *)engageEvent {
    
    NSError *error;
    if (![[EngageLocalEventStore sharedInstance].managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    //Attempt to post the event to Silverpop by enqueuing the event in the engageOperationsQueue.
    [self.engageOperationsQueue addOperationWithBlock:^{
        
        NSArray *eventsCache = @[engageEvent.eventJson];
        NSDictionary *params = @{ @"events" : eventsCache };
        NSLog(@"Operation Params %@", params.description);
        
        [self setParameterEncoding:AFJSONParameterEncoding];
        
        NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"/rest/events/submission" parameters:params];
        AFHTTPRequestOperation *operation =
        [self HTTPRequestOperationWithRequest:request
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          //NSLog(@"%@",[operation debugDescription]);
                                          //NSLog(@"%@",[responseObject debugDescription]);
                                          [engageEvent setEventHasPosted:[[NSNumber alloc] initWithInt: 1]];
                                          
                                          //Updates the CoreData context.
                                          NSError *error;
                                          if (![[EngageLocalEventStore sharedInstance].managedObjectContext save:&error]) {
                                              NSLog(@"Unable to mark EngageEvent as POSTED in the EngageQueueManger success block!");
                                          } else {
                                              NSLog(@"EngageEvent has been marked as posted to the server");
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          //NSLog(@"%@",[operation debugDescription]);
                                          NSLog(@"%@",[error debugDescription]);
                                          
                                          NSArray *ops = [[self operationQueue] operations];
                                          if (![ops containsObject:operation]) {
                                              NSLog(@"-----REQUEUED FAILED OPERATION-----");
                                              // requeue operation if it failed
                                              [self enqueueHTTPRequestOperation:operation];
                                          }
                                          
                                      }];
        
        
        [self enqueueHTTPRequestOperation:operation];
    }];

    
}

- (void) enqueueEvent:(NSDictionary *)event {
    NSLog(@"Enqueuing event %@ for posting to Silverpop API", event);
    
    //Insert EngageEvent into Core Data
    EngageEvent *engageEvent = [NSEntityDescription insertNewObjectForEntityForName:@"EngageEvent" inManagedObjectContext:[EngageLocalEventStore sharedInstance].managedObjectContext];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    NSNumber *myNumber = [f numberFromString:[event objectForKey:@"eventTypeCode"]];
    engageEvent.eventType = myNumber;
    engageEvent.eventJson = [self createJsonStringFromDictionary:event];
    engageEvent.eventHasPosted = [[NSNumber alloc] initWithInt:0];
    engageEvent.eventDate = [[NSDate alloc] init];
    
    [self enqueueEngageEvent:engageEvent];
}


//-(void) handleNetworkChange:(NSNotification *)notification {
//    NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
//    
//    if (remoteHostStatus == NotReachable) {
//        NSLog(@"Suspending UBF Event Operations Queue");
//        [self.engageOperationsQueue setSuspended:YES];
//    } else {
//        NSLog(@"Resuming UBF Event Operation Queue");
//        [self.engageOperationsQueue setSuspended:NO];
//    }
//}


- (NSString *)createJsonStringFromDictionary:(NSDictionary *)dictionary {
    NSError *error;
    NSString *jsonString;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

@end
