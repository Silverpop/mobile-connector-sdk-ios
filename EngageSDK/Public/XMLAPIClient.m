//
//  XMLAPIClient.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "XMLAPIClient.h"
#import "EngageResponseXML.h"
#import "EngageConfig.h"
#import "ResultDictionary.h"


@implementation XMLAPIClient

__strong static XMLAPIClient *_sharedClient = nil;

+ (instancetype)createClient:(NSString *)clientId
                      secret:(NSString *)secret
                       token:(NSString *)refreshToken
                        host:(NSString *)hostUrl {
    
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedClient = [[self alloc] initWithHost:hostUrl clientId:clientId secret:secret token:refreshToken];
    });
    return _sharedClient;
}

+ (instancetype)client
{
    return _sharedClient;
}

- (void)postResource:(XMLAPI *)api
             success:(void (^)(ResultDictionary *ERXML))success
             failure:(void (^)(NSError *error))failure {
    
    void (^postResource)() = ^() {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[api envelope], @"xml", nil];
        
        [self postPath:@"/XMLAPI" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            ResultDictionary *ERXML = [EngageResponseXML decode:responseObject];
            success(ERXML);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    };
    
    if (self.credential.isExpired) {
        NSLog(@"%@",@"Session expired...attempting to reconnect");
        [super connectSuccess:^(AFOAuthCredential *credential) {
            self.credential = credential;
            postResource();
        } failure:failure];
    }
    else {
        postResource();
    }
    
}

// calls add recipient and caches recipientId for app defaults
- (void)createAnonymousUserToList:(NSString *)listId
                          success:(void (^)(ResultDictionary *ERXML))success
                          failure:(void (^)(NSError *error))failure {
    // register device with Engage DB
    [self postResource:[XMLAPI addRecipientAnonymousToList:listId]
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
    [self postResource:anonymousUser success:^(ResultDictionary *ERXML) {
        if ([[ERXML valueForShortPath:@"SUCCESS"] boolValue]) {
            XMLAPI *mobileUser = [XMLAPI resourceNamed:@"UpdateRecipient" params:@{ @"LIST_ID" : listId } ];
            // FIELDS TO SYNC/SEARCH BY
            [mobileUser addSyncFields:@{ primaryUserColumn : userId } ];
            // COLUMNS TO UPDATE ON OLDEST MATCH
            [mobileUser addColumns:@{ mergeColumn : userId } ];
            
            [self postResource:mobileUser success:success failure:failure];
        }
        else {
            success(ERXML);
        }
    } failure:failure];
}

@end
