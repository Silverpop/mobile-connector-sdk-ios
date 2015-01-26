//
//  XMLAPI.h
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/10/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface XMLAPI : NSObject

extern int const COLUMN_TYPE_TEXT;
extern int const COLUMN_TYPE_YES_NO;
extern int const COLUMN_TYPE_NUMERIC;
extern int const COLUMN_TYPE_DATE;
extern int const COLUMN_TYPE_TIME;
extern int const COLUMN_TYPE_COUNTRY;
extern int const COLUMN_TYPE_SELECT_ONE;
extern int const COLUMN_TYPE_SEGMENTING;
extern int const COLUMN_TYPE_SMS_OPT_IN;
extern int const COLUMN_TYPE_SMS_OPT_OUT_DATE;
extern int const COLUMN_TYPE_SMS_PHONE_NUMBER;
extern int const COLUMN_TYPE_PHONE_NUMBER;
extern int const COLUMN_TYPE_TIMESTAMP;
extern int const COLUMN_TYPE_MULTI_SELECT;

+ (id)resourceNamed:(NSString *)namedResource;
+ (id)resourceNamed:(NSString *)namedResource params:(NSDictionary *)params;
- (void)listId:(NSString *)listId;
- (void)recipientId:(NSString *)recipientId;
- (void)addParams:(NSDictionary *)param;
- (void)addParam:(NSString *)key :(NSString *)value;
- (void)addSyncFields:(NSDictionary *)fields;
- (void)addColumns:(NSDictionary *)cols;
- (void)addColumn:(NSString *)name :(NSString *)value;
- (NSString *)envelope;

+ (id)selectRecipientData:(NSString *)emailAddress list:(NSString *)listId;
+ (id)addRecipient:(NSString *)emailAddress list:(NSString *)listId;
+ (id)addRecipientWithMobileUserIdColumnName:(NSString *)mobileUserIdColumnName
                                mobileUserId:(NSString *)mobileUserId
                                       list :(NSString *)listId;
+ (id)updateRecipient:(NSString *)recipientId list:(NSString *)listId;
+ (id)addRecipientAnonymousToList:(NSString *)listId;

+ (id)updateUserLastKnownLocation:(CLPlacemark *)lastKnownLocation listId:(NSString* )listID;

+ (id)addColumn:(NSString *)column toDatabase:(NSString *)listId ofColumnType:(int)columnType; //Add a column to a database.

@end
