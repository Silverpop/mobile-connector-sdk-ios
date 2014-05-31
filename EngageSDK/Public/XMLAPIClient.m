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

@interface XMLAPIClient()

@property (strong, nonatomic) NSMutableArray *apiCache; //Only cache api requests if the client is not authenticated yet.
@property (assign) BOOL hasBeenInitiallyAuthenticated;

@end


@implementation XMLAPIClient

typedef void (^PostResourceBlock)(void);

__strong static XMLAPIClient *_sharedClient = nil;

+ (instancetype)createClient:(NSString *)clientId
                      secret:(NSString *)secret
                       token:(NSString *)refreshToken
                        host:(NSString *)hostUrl
              connectSuccess:(void (^)(AFOAuthCredential *credential))success
                     failure:(void (^)(NSError *error))failure {
    
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedClient = [[self alloc] initWithHost:hostUrl clientId:clientId secret:secret token:refreshToken];
        _sharedClient.apiCache = [[NSMutableArray alloc] init];
        _sharedClient.hasBeenInitiallyAuthenticated = NO;
        
        [[_sharedClient operationQueue] setSuspended:YES];
        
        //Perform the login to the system.
        [_sharedClient authenticateInternal:^(AFOAuthCredential *credential) {
            _sharedClient.hasBeenInitiallyAuthenticated = YES;
            NSLog(@"Authentication refresh complete");
        } failure:^(NSError *error) {
            NSLog(@"Failed to refresh OAuth2 token for authentication");
            [[_sharedClient operationQueue] setSuspended:YES];
        }];
    });
    return _sharedClient;
}

+ (instancetype)client
{
    return _sharedClient;
}


- (void)authenticateInternal:(void (^)(AFOAuthCredential *credential))success
                     failure:(void (^)(NSError *error))failure {
    
    [[_sharedClient operationQueue] setSuspended:YES];
    
    //Perform the login to the system.
    [_sharedClient authenticate:^(AFOAuthCredential *credential) {
        if (success) {
            success(credential);
        }
        
        for (int i = 0; i < [self.apiCache count]; i++) {
            ((PostResourceBlock)[self.apiCache objectAtIndex:i])();
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


- (void)postResource:(XMLAPI *)api
             success:(void (^)(ResultDictionary *ERXML))success
             failure:(void (^)(NSError *error))failure {
    
    PostResourceBlock postResource = ^(void) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[api envelope], @"xml", nil];
        
        [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [self.credential accessToken]] forHTTPHeaderField:@"Authorization"];
        self.responseSerializer = [AFXMLParserResponseSerializer serializer];
        
        [self POST:@"/XMLAPI" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            ResultDictionary *ERXML = [EngageResponseXML decode:responseObject];
            success(ERXML);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    };
    
    if (![self isAuthenticated]) {
        if (self.hasBeenInitiallyAuthenticated) {
            //We need to refresh our token.
            NSLog(@"%@",@"Session expired...attempting to reconnect");
            [_sharedClient authenticateInternal:^(AFOAuthCredential *credential) {
                NSLog(@"Authentication refresh complete");
            } failure:^(NSError *error) {
                NSLog(@"Failed to refresh OAuth2 token for authentication");
                [[_sharedClient operationQueue] setSuspended:YES];
            }];
        }
        
        //Place the postResource() block in the cache to be executed on authenticate complete.
        [_sharedClient.apiCache addObject:postResource];
        
    } else {
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
