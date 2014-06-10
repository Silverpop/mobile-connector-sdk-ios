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
- (void)addParams:(NSDictionary *)param;
- (void)addSyncFields:(NSDictionary *)fields;
- (void)addColumns:(NSDictionary *)cols;
- (NSString *)envelope;

+ (id)selectRecipientData:(NSString *)emailAddress list:(NSString *)listId;
+ (id)addRecipient:(NSString *)emailAddress list:(NSString *)listId;
+ (id)updateRecipient:(NSString *)recipientId list:(NSString *)listId;
+ (id)addRecipientAnonymousToList:(NSString *)listId;

+ (id)updateUserLastKnownLocation:(CLPlacemark *)lastKnownLocation listId:(NSString* )listID;

//Database Management Interfaces - User.

//Import to a database.
//Export from a database.
+ (id)addColumn:(NSString *)column toDatabase:(NSString *)listId ofColumnType:(int)columnType; //Add a column to a database.
//get database details.
//list contact mailings.
//remove a contact
//get a list of databases.
//create a relational table.
//associate relational data with contacts in a database.
//insert and update records in a relational table.
//delete records from a relational table.
//import to a relational table.
//export from a relational table.
//purge data from a relational table.
//delete a relational table.
//create a contact list
//add a contact to a program.
//create a query of a database.
//calculate the current contacts for a query.
//set a column value.

@end
