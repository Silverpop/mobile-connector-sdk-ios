//
//  XMLAPIManager.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/9/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "XMLAPIManager.h"
#import "XMLAPIClient.h"
#import "UBFClient.h"
#import "EngageConfigManager.h"

@interface XMLAPIManager()

@property (strong, nonatomic) EngageConfigManager *ecm;

@end

@implementation XMLAPIManager

__strong static XMLAPIManager *_sharedInstance = nil;

+ (instancetype)createClient:(NSString *)clientId
                      secret:(NSString *)secret
                       token:(NSString *)refreshToken
                        host:(NSString *)hostUrl
        engageDatabaseListId:(NSString *)engageListId
              connectSuccess:(void (^)(AFOAuthCredential *credential))success
                     failure:(void (^)(NSError *error))failure {
    
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedInstance = [[XMLAPIManager alloc] init];
        [EngageConfig storeEngageListId:engageListId];
        
        [XMLAPIClient createClient:clientId
                         secret:secret
                          token:refreshToken
                           host:hostUrl
                 connectSuccess:^(AFOAuthCredential *credential) {
                     NSLog(@"Successfully authenticated connection to Engage API");
                 } failure:^(NSError *error) {
                     NSLog(@"Failed to authenticate connection to Engage API%@", error);
                 }];
        
        _sharedInstance.ecm = [EngageConfigManager sharedInstance];        
    });
    
    return _sharedInstance;
}


+ (id)sharedInstance {
    if (_sharedInstance == nil) {
        [NSException raise:@"XMLAPIManager sharedInstance is null" format:@"XMLAPIManager sharedInstance is nil. You must first create an XMLAPIManager instance"];
    }
    return _sharedInstance;
}


- (void) postXMLAPI:(XMLAPI *)xmlapi {
    [self postXMLAPI:xmlapi success:nil failure:nil];
}


- (void)postXMLAPI:(XMLAPI *)xmlapi
           success:(void (^)(ResultDictionary *ERXML))success
           failure:(void (^)(NSError *error))failure {
    [[XMLAPIClient client] postResource:xmlapi success:nil failure:nil];
}


// calls add recipient and caches recipientId for app defaults
- (void)createAnonymousUserToList:(NSString *)listId
                          success:(void (^)(ResultDictionary *ERXML))success
                          failure:(void (^)(NSError *error))failure {
    // register device with Engage DB
    [self postXMLAPI:[XMLAPI addRecipientAnonymousToList:listId]
               success:^(ResultDictionary *ERXML) {
                   if ([[ERXML valueForShortPath:@"SUCCESS"] boolValue]) {
                       NSString *userId = [ERXML valueForShortPath:@"RecipientId"];
                       [EngageConfig storeAnonymousId:userId];
                       NSLog(@"Successfully created anonymous user with id %@", userId);
                   }
                   success(ERXML);
               } failure:failure];
}

- (void)updateAnonymousToPrimaryUser:(NSString *)userId
                                list:(NSString *)listId
                   primaryUserColumn:(NSString *)primaryUserColumn
                         mergeColumn:(NSString *)mergeColumn
                             success:(void (^)(ResultDictionary *ERXML))success
                             failure:(void (^)(NSError *error))failure {
    
    // UPDATE UBF TO LOG ANALYTICS FOR THIS PREFERRED CONTACT
    [EngageConfig storePrimaryUserId: userId];
    
    // update existing user with preferred contact id
    NSString *anonymousId = [EngageConfig anonymousId];
    XMLAPI *anonymousUser = [XMLAPI updateRecipient:anonymousId list:listId];
    [anonymousUser addColumns:@{ mergeColumn : userId } ];
    [self postXMLAPI:anonymousUser success:^(ResultDictionary *ERXML) {
        if ([[ERXML valueForShortPath:@"SUCCESS"] boolValue]) {
            XMLAPI *mobileUser = [XMLAPI resourceNamed:@"UpdateRecipient" params:@{ @"LIST_ID" : listId } ];
            // FIELDS TO SYNC/SEARCH BY
            [mobileUser addSyncFields:@{ primaryUserColumn : userId } ];
            // COLUMNS TO UPDATE ON OLDEST MATCH
            [mobileUser addColumns:@{ mergeColumn : userId } ];
            
            [self postXMLAPI:mobileUser success:success failure:failure];
        }
        else {
            success(ERXML);
        }
    } failure:failure];
}

//-(void) testAddListColumnToUserDatabase {
//    
//}
//
//-(void) testAddUserLocationToDatabase {
//    
//    NSString *listId = [[EngageConfigManager sharedInstance] configForGeneralFieldName:PLIST_GENERAL_DATABASE_LIST_ID];
//    XMLAPIClient *client = [XMLAPIClient client];
//    XMLAPI *updateUserKnownLocation = [XMLAPI updateUserLastKnownLocation:self.currentPlacemarkCache listId:listId];
//    [client postResource:updateUserKnownLocation success:^(ResultDictionary *ERXML) {
//        NSLog(@"Updated user last known location to %@", self.currentPlacemarkCache);
//    } failure:nil];
//    
//}

@end
