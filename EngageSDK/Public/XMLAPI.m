//
//  XMLAPI.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/10/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "XMLAPI.h"
#import "EngageConfig.h"

#define COLUMN (@"COLUMN")
#define SYNC_FIELD (@"SYNC_FIELD")

@interface XMLAPI ()
@property NSString *namedResource;
@property NSMutableDictionary *bodyElements;
@end

@implementation XMLAPI

+ (id)resourceNamed:(NSString *)namedResource {
    XMLAPI *api = [[self alloc] init];
    api.namedResource = namedResource;
    api.bodyElements = [NSMutableDictionary dictionary];
    return api;
}

+ (id)resourceNamed:(NSString *)namedResource params:(NSDictionary *)params {
    XMLAPI *api = [self resourceNamed:namedResource];
    [api.bodyElements addEntriesFromDictionary:params];
    return api;
}

- (void)addParams:(NSDictionary *)param {
    [_bodyElements addEntriesFromDictionary:param];
}

- (void)addElements:(NSDictionary *)elements named:(NSString *)elementName {
    NSMutableDictionary *syncFields = [NSMutableDictionary dictionary];
    NSDictionary *existing;
    if ((existing = [_bodyElements objectForKey:elementName])) {
        [syncFields addEntriesFromDictionary:existing];
    }
    [syncFields addEntriesFromDictionary:elements];
    [_bodyElements setObject:[NSDictionary dictionaryWithDictionary:syncFields] forKey:elementName];
}

- (void)addSyncFields:(NSDictionary *)fields {
    [self addElements:fields named:@"SYNC_FIELDS"];
}

- (void)addColumns:(NSDictionary *)cols {
    [self addElements:cols named:@"COLUMNS"];
}

- (NSString *)resource {
    return _namedResource;
}

- (NSString *)envelope {
    NSMutableString *body = [NSMutableString stringWithCapacity:100];
    NSMutableString *syncFields = [NSMutableString stringWithCapacity:100];
    NSString *nameValueForm = @"<%1$@><NAME>%2$@</NAME><VALUE>%3$@</VALUE></%1$@>";
    
    NSDictionary *element;
    for (id key in _bodyElements) {
        element = [_bodyElements objectForKey:key];
        
        if ([key isEqualToString:@"COLUMNS"]) {
            for (id keyCol in element) {
                [body appendFormat:nameValueForm,COLUMN,keyCol,[element objectForKey:keyCol]];
            }
        }
        else if ([key isEqualToString:@"SYNC_FIELDS"]) {
            for (id keyField in element) {
                [syncFields appendFormat:nameValueForm,SYNC_FIELD,keyField,[element objectForKey:keyField]];
            }
        }
        else {
            [body appendFormat:@"<%1$@>%2$@</%1$@>",key,[_bodyElements objectForKey:key]];
        }
    }
    
    if (![syncFields isEqual:@""]) {
        [body appendFormat:@"<SYNC_FIELDS>%@</SYNC_FIELDS>",syncFields];
    }
    
    return [NSString stringWithFormat:@"<Envelope><Body><%1$@>%2$@</%1$@></Body></Envelope>",
            _namedResource, body];
}

#pragma mark -

+ (id)selectRecipientData:(NSString *)emailAddress list:(NSString *)listId {
    XMLAPI *api = [self resourceNamed:@"SelectRecipientData"];
    [api.bodyElements addEntriesFromDictionary:
     @{
     @"LIST_ID" : listId,
     @"EMAIL" : emailAddress,
     @"COLUMNS" : @{ @"EMAIL": emailAddress }
     }];
    return api;
}

+ (id)addRecipient:(NSString *)emailAddress list:(NSString *)listId {
    XMLAPI *api = [self resourceNamed:@"AddRecipient"];
    [api.bodyElements addEntriesFromDictionary:
     @{
     @"LIST_ID" : listId,
     @"UPDATE_IF_FOUND" : @"true" ,
     @"SYNC_FIELDS" :
     @{
        @"Email" : emailAddress},
     @"COLUMNS" :
     @{
        @"Email" : emailAddress }
     }];
    return api;
}

+ (id)updateRecipient:(NSString *)recipientId list:(NSString *)listId {
    XMLAPI *api = [self resourceNamed:@"UpdateRecipient"];
    [api.bodyElements addEntriesFromDictionary:
     @{
     @"LIST_ID" : listId,
     @"RECIPIENT_ID" : recipientId
     }];
    return api;
}

+ (id)addRecipientAnonymousToList:(NSString *)listId {
    XMLAPI *api = [self resourceNamed:@"AddRecipient"];
    [api.bodyElements addEntriesFromDictionary:
     @{
     @"LIST_ID" : listId
     }];
    return api;
}

@end
