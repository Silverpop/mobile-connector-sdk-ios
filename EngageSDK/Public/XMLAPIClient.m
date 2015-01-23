//
//  XMLAPIClient.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "XMLAPIClient.h"
#import "EngageResponseXML.h"
#import "EngageConnectionManager.h"

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
        
        [[[EngageConnectionManager sharedInstance] operationQueue] setSuspended:YES];
//        [[_sharedClient operationQueue] setSuspended:YES];
        
        //Perform the login to the system.
        [_sharedClient authenticateInternal:^(AFOAuthCredential *credential) {
            _sharedClient.hasBeenInitiallyAuthenticated = YES;
            NSLog(@"Authentication refresh complete");
            if (success) {
                success(credential);
            }

        } failure:^(NSError *error) {
            NSLog(@"%@", [@"Failed to refresh OAuth2 token for authentication: " stringByAppendingString:[error localizedDescription]]);
//            [[_sharedClient operationQueue] setSuspended:YES];
            [[[EngageConnectionManager sharedInstance] operationQueue] setSuspended:YES];
            if (failure) {
                failure(error);
            }
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
    
    
//    if (![[EngageConnectionManager sharedInstance] isAuthenticated]) {

//        [[self operationQueue] setSuspended:YES];
    [[[EngageConnectionManager sharedInstance] operationQueue] setSuspended:YES];
    
        //Perform the login to the system.
        [[EngageConnectionManager sharedInstance] authenticate:^(AFOAuthCredential *credential) {
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
//    }
}


- (void)postResource:(XMLAPI *)api
             success:(void (^)(ResultDictionary *ERXML))success
             failure:(void (^)(NSError *error))failure {
    
    PostResourceBlock postResource = ^(void) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[api envelope], @"xml", nil];
//        AFOAuthCredential *credential = [self credential];
//        [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [credential accessToken]] forHTTPHeaderField:@"Authorization"];
//        self.responseSerializer = [AFXMLParserResponseSerializer serializer];
        
        [[EngageConnectionManager sharedInstance] postXmlRequest:@"/XMLAPI" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            ResultDictionary *ERXML = [EngageResponseXML decode:responseObject];
            if (success) {
                success(ERXML);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    };
    
    if (![self isAuthenticated]) {
        if (self.hasBeenInitiallyAuthenticated) {
            //We need to refresh our token.
            NSLog(@"%@",@"Session expired...attempting to reconnect");
            [self authenticateInternal:^(AFOAuthCredential *credential) {
                NSLog(@"Authentication refresh complete");
            } failure:^(NSError *error) {
                NSLog(@"Failed to refresh OAuth2 token for authentication");
//                [[self operationQueue] setSuspended:YES];
                [[[EngageConnectionManager sharedInstance] operationQueue] setSuspended:YES];
            }];
        }
        
        //Place the postResource() block in the cache to be executed on authenticate complete.
        [self.apiCache addObject:postResource];
        
    } else {
        postResource();
    }
    
}

@end
