//
//  XMLAPI.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/10/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "XMLAPI.h"
#import "EngageConfig.h"
#import "EngageConfigManager.h"
#import "XMLAPIOperation.h"

#define COLUMN (@"COLUMN")
#define SYNC_FIELD (@"SYNC_FIELD")

@interface XMLAPI ()
@property NSString *namedResource;
@property NSMutableDictionary *bodyElements;
@end

@implementation XMLAPI

int const COLUMN_TYPE_TEXT = 0;
int const COLUMN_TYPE_YES_NO = 1;
int const COLUMN_TYPE_NUMERIC = 2;
int const COLUMN_TYPE_DATE = 3;
int const COLUMN_TYPE_TIME = 4;
int const COLUMN_TYPE_COUNTRY = 5;
int const COLUMN_TYPE_SELECT_ONE = 6;
int const COLUMN_TYPE_SEGMENTING = 8;
int const COLUMN_TYPE_SMS_OPT_IN = 13;
int const COLUMN_TYPE_SMS_OPT_OUT_DATE = 14;
int const COLUMN_TYPE_SMS_PHONE_NUMBER = 15;
int const COLUMN_TYPE_PHONE_NUMBER = 16;
int const COLUMN_TYPE_TIMESTAMP = 17;
int const COLUMN_TYPE_MULTI_SELECT = 20;


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

- (void) listId:(NSString *)listId {
    [[self bodyElements] addEntriesFromDictionary: @{@"LIST_ID" : listId}];
}

- (void) recipientId:(NSString *)recipientId {
    [[self bodyElements] addEntriesFromDictionary:@{@"RECIPIENT_ID": recipientId}];
}

- (void)addParams:(NSDictionary *)param {
    [_bodyElements addEntriesFromDictionary:param];
}

/**
 *  Adds a single param to the existing list of params
 *
 *  @param key   param name
 *  @param value param value
 */
- (void) addParam:(NSString *)key :(NSString *)value {
    NSDictionary *params = @{ key : value };
    [self addParams:params];
}

- (void)addElements:(NSDictionary *)elements named:(NSString *)elementName {
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    NSDictionary *existing;
    if ((existing = [_bodyElements objectForKey:elementName])) {
        [fields addEntriesFromDictionary:existing];
    }
    [fields addEntriesFromDictionary:elements];
    [_bodyElements setObject:[NSDictionary dictionaryWithDictionary:fields] forKey:elementName];
}

- (void)addSyncFields:(NSDictionary *)fields {
    [self addElements:fields named:@"SYNC_FIELDS"];
}

- (void)addColumns:(NSDictionary *)cols {
    [self addElements:cols named:@"COLUMNS"];
}

/**
 *  Adds a single column to the list of existing columns
 *
 *  @param name  column name
 *  @param value column value
 */
-(void)addColumn:(NSString *)name :(NSString *)value {
    NSDictionary *cols = @{ name : value };
    [self addColumns:cols];
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

+ (id)selectRecipientWithId:(NSString *)recipientId list:(NSString *)listId {
    XMLAPI *api = [self resourceNamed:XMLAPI_OPERATION_SELECT_RECIPIENT_DATA];
    [api.bodyElements addEntriesFromDictionary:
     @{
       @"LIST_ID" : listId,
       @"RECIPIENT_ID" : recipientId
       }];
    return api;
}

+ (id)selectRecipientData:(NSString *)emailAddress list:(NSString *)listId {
    XMLAPI *api = [self resourceNamed:XMLAPI_OPERATION_SELECT_RECIPIENT_DATA];
    [api.bodyElements addEntriesFromDictionary:
     @{
     @"LIST_ID" : listId,
     @"EMAIL" : emailAddress,
     @"COLUMNS" : @{ @"EMAIL": emailAddress }
     }];
    return api;
}

+ (id)addRecipient:(NSString *)emailAddress list:(NSString *)listId {
    XMLAPI *api = [self resourceNamed:XMLAPI_OPERATION_ADD_RECIPIENT];
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

+ (id)addRecipientWithMobileUserIdColumnName:(NSString *)mobileUserIdColumnName
                                mobileUserId:(NSString *)mobileUserId
                                       list :(NSString *)listId {
    XMLAPI *addRecipientXml = [self resourceNamed:XMLAPI_OPERATION_ADD_RECIPIENT];
    [addRecipientXml.bodyElements addEntriesFromDictionary:
     @{
       @"LIST_ID" : listId,
       @"COLUMNS" :
           @{ mobileUserIdColumnName : mobileUserId }
       }];
    return addRecipientXml;
}

+ (id)updateRecipient:(NSString *)recipientId list:(NSString *)listId {
    XMLAPI *api = [self resourceNamed:XMLAPI_OPERATION_UPDATE_RECIPIENT];
    [api.bodyElements addEntriesFromDictionary:
     @{
     @"LIST_ID" : listId,
     @"RECIPIENT_ID" : recipientId
     }];
    return api;
}

+ (id)addRecipientAnonymousToList:(NSString *)listId {
    XMLAPI *api = [self resourceNamed:XMLAPI_OPERATION_ADD_RECIPIENT];
    [api.bodyElements addEntriesFromDictionary:
     @{
     @"LIST_ID" : listId
     }];
    return api;
}


+ (id)addColumn:(NSString *)column toDatabase:(NSString *)listId ofColumnType:(int)columnType {
    XMLAPI *api = [self resourceNamed:XMLAPI_OPERATION_ADD_LIST_COLUMN];
    [api.bodyElements addEntriesFromDictionary:@{
                                                 @"LIST_ID" : listId,
                                                 @"COLUMN_NAME" : column,
                                                 @"COLUMN_TYPE" : [NSString stringWithFormat:@"%d", columnType],
                                                 @"DEFAULT" : @""
    }];
    return api;
}


+ (id)updateUserLastKnownLocation:(CLPlacemark *)lastKnownLocation listId:(NSString* )listID {
    
    NSString *lastKnownLocationDateFormat = [[EngageConfigManager sharedInstance] configForLocationFieldName:PLIST_LOCATION_LAST_KNOWN_LOCATION_TIME_FORMAT];
    
    //Updates the users last known location.
    NSString *location;
    if (lastKnownLocation) {
        location = [NSString stringWithFormat:@"%@, %@ %@, %@ (%@)", [[lastKnownLocation addressDictionary] objectForKey:@"City"], [[lastKnownLocation addressDictionary] objectForKey:@"State"], [[lastKnownLocation addressDictionary] objectForKey:@"ZIP"], [[lastKnownLocation addressDictionary] objectForKey:@"Country"], [[lastKnownLocation addressDictionary] objectForKey:@"CountryCode"]];
    } else {
        location = @"UNKNOWN";
    }
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:lastKnownLocationDateFormat];
    NSString *lastKnownLocationDate = [dateFormatter stringFromDate:date];
    
    NSString *lastKnownLocationColumnName = [[EngageConfigManager sharedInstance] configForLocationFieldName:PLIST_LOCATION_LAST_KNOWN_LOCATION];
    NSString *lastKnownLocationTime = [[EngageConfigManager sharedInstance] configForLocationFieldName:PLIST_LOCATION_LAST_KNOWN_LOCATION_TIME];
    
    
    XMLAPI *api = [XMLAPI resourceNamed:XMLAPI_OPERATION_UPDATE_RECIPIENT params:@{ @"LIST_ID" : listID } ];
    // FIELDS TO SYNC/SEARCH BY
    [api addSyncFields:@{ @"EMAIL" : [EngageConfig mobileUserId] } ];
    // COLUMNS TO UPDATE ON OLDEST MATCH
    [api addColumns:@{ lastKnownLocationColumnName : location,
                       lastKnownLocationTime : lastKnownLocationDate} ];
    
    return api;
}

@end
