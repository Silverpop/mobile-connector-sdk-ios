//
//  XMLAPIOperation.m
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/26/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import "XMLAPIOperation.h"

@implementation XMLAPIOperation

NSString* const XMLAPI_OPERATION_SEND_MAILING = @"SendMailing";
NSString* const XMLAPI_OPERATION_FORWARD_TO_FRIEND = @"ForwardToFriend";
NSString* const XMLAPI_OPERATION_GET_CONTACT_MAILING_DETAILS = @"GetContactMailingDetails";
NSString* const XMLAPI_OPERATION_PURGE_DATA = @"PurgeData";
NSString* const XMLAPI_OPERATION_ADD_RECIPIENT = @"AddRecipient";
NSString* const XMLAPI_OPERATION_DOUBLE_OPT_IN_RECIPIENT = @"DoubleOptInRecipient";
NSString* const XMLAPI_OPERATION_UPDATE_RECIPIENT = @"UpdateRecipient";
NSString* const XMLAPI_OPERATION_OPT_OUT_RECIPIENT = @"OptOutRecipient";
NSString* const XMLAPI_OPERATION_SELECT_RECIPIENT_DATA = @"SelectRecipientData";
NSString* const XMLAPI_OPERATION_LOGIN = @"Login";
NSString* const XMLAPI_OPERATION_LOG_OUT = @"Logout";
NSString* const XMLAPI_OPERATION_IMPORT_LIST = @"ImportList";
NSString* const XMLAPI_OPERATION_EXPORT_LIST = @"ExportList";
NSString* const XMLAPI_OPERATION_ADD_LIST_COLUMN = @"AddListColumn";
NSString* const XMLAPI_OPERATION_GET_LIST_META_DATA = @"GetListMetaData";
NSString* const XMLAPI_OPERATION_LIST_RECIPIENT_MAILINGS = @"ListRecipientMailings";
NSString* const XMLAPI_OPERATION_REMOVE_RECIPIENT = @"RemoveRecipient";
NSString* const XMLAPI_OPERATION_GET_LISTS = @"GetLists";
NSString* const XMLAPI_OPERATION_CREATE_TABLE = @"CreateTable";
NSString* const XMLAPI_OPERATION_JOIN_TABLE = @"JoinTable";
NSString* const XMLAPI_OPERATION_INSERT_UPDATE_RELATIONAL_TABLE = @"InsertUpdateRelationalTable";
NSString* const XMLAPI_OPERATION_DELETE_RELATIONAL_TABLE_DATA = @"DeleteRelationalTableData";
NSString* const XMLAPI_OPERATION_IMPORT_TABLE = @"ImportTable";
NSString* const XMLAPI_OPERATION_EXPORT_TABLE = @"ExportTable";
NSString* const XMLAPI_OPERATION_PURGE_TABLE = @"PurgeTable";
NSString* const XMLAPI_OPERATION_DELETE_TABLE = @"DeleteTable";
NSString* const XMLAPI_OPERATION_CREATE_CONTACT_LIST = @"CreateContactList";
NSString* const XMLAPI_OPERATION_ADD_CONTACT_TO_CONTACT_LIST = @"AddContactToContactList";
NSString* const XMLAPI_OPERATION_ADD_CONTACT_TO_PROGRAM = @"AddContactToProgram";
NSString* const XMLAPI_OPERATION_CREATE_QUERY = @"CreateQuery";
NSString* const XMLAPI_OPERATION_CALCULATE_QUERY = @"CalculateQuery";
NSString* const XMLAPI_OPERATION_SET_COLUMN_VALUE = @"SetColumnValue";
NSString* const XMLAPI_OPERATION_TRACKING_METRIC_EXPORT = @"TrackingMetricExport";
NSString* const XMLAPI_OPERATION_RAW_RECIPIENT_DATA_EXPORT = @"RawRecipientDataExport";
NSString* const XMLAPI_OPERATION_WEB_TRACKING_DATA_EXPORT = @"WebTrackingDataExport";
NSString* const XMLAPI_OPERATION_GET_REPORT_ID_BY_DATE = @"GetReportIdByDate";
NSString* const XMLAPI_OPERATION_GET_SENT_MAILINGS_FOR_ORG = @"GetSentMailingsForOrg";
NSString* const XMLAPI_OPERATION_GET_SENT_MAILINGS_FOR_USER = @"GetSentMailingsForUser";
NSString* const XMLAPI_OPERATION_GET_SENT_MAILINGS_FOR_LIST = @"GetSentMailingsForList";
NSString* const XMLAPI_OPERATION_GET_AGGREGATE_TRACKING_FOR_MAILING = @"GetAggregateTrackingForMailing";
NSString* const XMLAPI_OPERATION_GET_AGGREGATE_TRACKING_FOR_ORG = @"GetAggregateTrackingForOrg";
NSString* const XMLAPI_OPERATION_GET_AGGREGATE_TRACKING_FOR_USER = @"GetAggregateTrackingForUser";
NSString* const XMLAPI_OPERATION_GET_JOB_STATUS = @"GetJobStatus";
NSString* const XMLAPI_OPERATION_DELETE_JOB = @"DeleteJob";
NSString* const XMLAPI_OPERATION_GET_FOLDER_PATH = @"GetFolderPath";
NSString* const XMLAPI_OPERATION_SCHEDULE_MAILING = @"ScheduleMailing";
NSString* const XMLAPI_OPERATION_PREVIEW_MAILING = @"PreviewMailing";
NSString* const XMLAPI_OPERATION_GET_MESSAGE_GROUP_DETAILS = @"GetMessageGroupDetails";
NSString* const XMLAPI_OPERATION_ADD_DYNAMIC_CONTENT_RULE_SET = @"AddDCRuleset";
NSString* const XMLAPI_OPERATION_IMPORT_DYNAMIC_CONTENT_RULE_SET = @"ImportDCRuleset";
NSString* const XMLAPI_OPERATION_EXPORT_DYNAMIC_CONTENT_RULE_SET = @"ExportDCRuleset";
NSString* const XMLAPI_OPERATION_LIST_DYNAMIC_CONTENT_RULE_SETS_FOR_MAILING = @"ListDCRulesetsForMailing";
NSString* const XMLAPI_OPERATION_GET_DYNAMIC_CONTENT_RULE_SET = @"GetDCRuleset";
NSString* const XMLAPI_OPERATION_REPLACE_DYNAMIC_CONTENT_RULE_SET = @"ReplaceDCRuleset";
NSString* const XMLAPI_OPERATION_VALIDATE_DYNAMIC_CONTENT_RULE_SET = @"ValidateDCRuleset";
NSString* const XMLAPI_OPERATION_DELETE_DYNAMIC_CONTENT_RULE_SET = @"DeleteDCRuleset";
NSString* const XMLAPI_OPERATION_GET_MAILING_TEMPLATES = @"GetMailingTemplates";
NSString* const XMLAPI_OPERATION_EXPORT_MAILING_TEMPLATE = @"ExportMailingTemplate";

@end
