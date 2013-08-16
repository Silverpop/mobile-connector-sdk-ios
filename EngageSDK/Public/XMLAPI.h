//
//  XMLAPI.h
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/10/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLAPI : NSObject

+ (id)resourceNamed:(NSString *)namedResource;
+ (id)resourceNamed:(NSString *)namedResource params:(NSDictionary *)params;
- (void)addParams:(NSDictionary *)param;
- (void)addSyncFields:(NSDictionary *)fields;
- (void)addColumns:(NSDictionary *)cols;
- (NSString *)envelope;

+ (id)selectRecipientData:(NSString *)emailAddress list:(NSString *)listId;
+ (id)addRecipient:(NSString *)emailAddress list:(NSString *)listId;
+ (id)updateRecipient:(NSString *)recipientId list:(NSString *)listId;
+ (id)addRecipientAnonymousToList:(NSString *)listId;

@end
