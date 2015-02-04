//
//  XMLAPIErrorCode.h
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/27/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLAPIErrorCode : NSObject

/**
 *  F_NON_NUMERIC_MAILING_KEY
 */
extern int const XMLAPI_ERROR_FTF_NON_NUMERIC_MAILING_KEY;

/**
 *  FTF_NON_NUMERIC_SENDER_KEY
 */
extern int const XMLAPI_ERROR_FTF_NON_NUMERIC_SENDER_KEY;

/**
 *  FTF_BAD_MAILING
 */
extern int const XMLAPI_ERROR_FTF_BAD_MAILING;

/**
 *  FTF_INVALID_EMAIL_ADDRESS
 */
extern int const XMLAPI_ERROR_FTF_INVALID_EMAIL_ADDRESS;

/**
 *  FTF_INVALID_ENCRYPTED_SENDER_KEY
 */
extern int const XMLAPI_ERROR_FTF_INVALID_ENCRYPTED_SENDER_KEY;

/**
 *  FTF_INVALID_COMMENT_SIZE
 */
extern int const XMLAPI_ERROR_FTF_INVALID_COMMENT_SIZE;

/**
 *  Server Error (typically returned if the API is invoked incorrectly such as no XML passed in the request)
 */
extern int const XMLAPI_ERROR_SERVER_ERROR;

/**
 *  Invalid XML Request
 */
extern int const XMLAPI_ERROR_INVALID_XML_REQUEST;

/**
 *  Missing XML parameter
 */
extern int const XMLAPI_ERROR_MISSING_XML_PARAMETER;

/**
 *  Parameter x was not provided in API call
 */
extern int const XMLAPI_ERROR_PARAM_NOT_PROVIDED;

/**
 *  Name already in use. Engage cannot rename the template directory.
 */
extern int const XMLAPI_ERROR_NAME_ALREADY_IN_USE;

/**
 *  Directory already exists.
 */
extern int const XMLAPI_ERROR_DIRECTORY_ALREADY_EXISTS;

/**
 *  Parent directory does not exist.
 */
extern int const XMLAPI_ERROR_PARENT_DIRECTORY_DOES_NOT_EXIST;

/**
 *  Visibility is not valid.
 */
extern int const XMLAPI_ERROR_VISIBILITY_NOT_VALID;

/**
 *  List type is not valid.
 */
extern int const XMLAPI_ERROR_LIST_TYPE_NOT_VALID;

/**
 *  List ID is not valid.
 */
extern int const XMLAPI_ERROR_LIST_ID_NOT_VALID;

/**
 *  Mailing ID is not valid.
 */
extern int const XMLAPI_ERROR_MAILING_ID_NOT_VALID;

/**
 *  Tracking Level is not valid.
 */
extern int const XMLAPI_ERROR_TRACKING_LEVEL_NOT_VALID;

/**
 *  Error saving mailing to the database.
 */
extern int const XMLAPI_ERROR_ERROR_SAVING_MAILING;

/**
 *  Retain flag is not valid.
 */
extern int const XMLAPI_ERROR_RETAIN_FLAG_NOT_VALID;

/**
 *  Mailing Type is not valid.
 */
extern int const XMLAPI_ERROR_MAILING_TYPE_NOT_VALID;

/**
 *  Click Through Type is not valid.
 */
extern int const XMLAPI_ERROR_CLICK_THROUGH_TYPE_NOT_VALID;

/**
 *  TextSize is not an integer.
 */
extern int const XMLAPI_ERROR_TEXT_SIZE_NOT_INT;

/**
 * Parameter "x" was not provided in API call
 *
 * Appears to be a duplicate of {@link #PARAM_NOT_PROVIDED}
 */
extern int const XMLAPI_ERROR_PARAM_NOT_PROVIDED_2;

/**
 * Name already in use. Engage cannot rename template directory.
 *
 * Appears to be a duplicate of {@link #NAME_ALREADY_IN_USE}
 */
extern int const XMLAPI_ERROR_NAME_ALREADY_IN_USE_2;

/**
 *  ERR_INVALID_CREATED_FROM
 */
extern int const XMLAPI_ERROR_ERR_INVALID_CREATED_FROM;

/**
 *  ERR_INVALID_ALLOW_HTML
 */
extern int const XMLAPI_ERROR_ERR_INVALID_ALLOW_HTML;

/**
 *  ERR_INVALID_SEND_AUTOREPLY
 */
extern int const XMLAPI_ERROR_ERR_INVALID_SEND_AUTOREPLY;

/**
 *  ERR_INVALID_UPDATE_IF_FOUND
 */
extern int const XMLAPI_ERROR_ERR_INVALID_UPDATE_IF_FOUND;

/**
 *  Error saving recipient to the database.
 */
extern int const XMLAPI_ERROR_ERROR_SAVING_RECIPIENT;

/**
 *  Unable to add recipient. No EMAIL provided.
 */
extern int const XMLAPI_ERROR_ADD_RECIPIENT_EMAIL_REQUIRED;

/**
 *  Unable to add recipient. Recipient already exists.
 */
extern int const XMLAPI_ERROR_ADD_RECIPIENT_ALREADY_EXISTS;

/**
 *  Unable to update recipient / recipient does not exist.
 */
extern int const XMLAPI_ERROR_UPDATE_RECIPIENT_DOES_NOT_EXIST;

/**
 *  Recipient ID is not valid.
 */
extern int const XMLAPI_ERROR_RECIPIENT_ID_NOT_VALID;

/**
 *  No List ID or Mailing ID provided with the Recipient ID.
 */
extern int const XMLAPI_ERROR_LIST_ID_OR_MAILING_ID_REQUIRED;

/**
 *  Mailing does not exist.
 */
extern int const XMLAPI_ERROR_MAILING_DOES_NOT_EXIST;

/**
 *  Mailing deleted.
 */
extern int const XMLAPI_ERROR_MAILING_DELETED;

/**
 *  Recipient is not a member of the list.
 */
extern int const XMLAPI_ERROR_RECIPIENT_NOT_LIST_MEMBER;

/**
 *  Recipient has opted out of the list.
 */
extern int const XMLAPI_ERROR_RECIPIENT_OPTED_OUT;

/**
 *  Unable to send mailing; Internal error.
 */
extern int const XMLAPI_ERROR_MAILING_INTERNAL_ERROR;

/**
 *  ERR_INVALID_IMPORT_TYPE
 */
extern int const XMLAPI_ERROR_ERR_INVALID_IMPORT_TYPE;

/**
 *  Unable to create import job.
 */
extern int const XMLAPI_ERROR_IMPORT_JOB_CREATE_ERROR;

/**
 *  File type is not valid.
 */
extern int const XMLAPI_ERROR_FILE_TYPE_NOT_VALID;

/**
 * File type is not valid.
 *
 * Appears to be a duplicate of {@link #FILE_TYPE_NOT_VALID}
 */
extern int const XMLAPI_ERROR_FILE_TYPE_NOT_VALID_2;

/**
 *  Job ID is not valid.
 */
extern int const XMLAPI_ERROR_JOB_ID_NOT_VALID;

/**
 *  Unable to create Delete job. Internal error.
 */
extern int const XMLAPI_ERROR_DELETE_JOB_INTERNAL_ERROR;

/**
 *  Unable to destroy mailing. Internal error.
 */
extern int const XMLAPI_ERROR_DESTROY_MAILING_INTERNAL_ERROR;

/**
 *  Unable to remove recipient from list. Internal error.
 */
extern int const XMLAPI_ERROR_REMOVE_RECIPIENT_INTERNAL_ERROR;

/**
 *  Unable to create DC ruleset export job.
 */
extern int const XMLAPI_ERROR_CANNOT_CREATE_DC_RULESET_EXPORT;

/**
 *  Editor type is not valid.
 */
extern int const XMLAPI_ERROR_EDITOR_TYPE_NOT_VALID;

/**
 *  Encoding is not valid.
 */
extern int const XMLAPI_ERROR_ENCODING_NOT_VALID;

/**
 *  List is a query, cannot delete list query recipients.
 */
extern int const XMLAPI_ERROR_CANNOT_DELETE_LIST_QUERY_RECIPIENTS;

/**
 *  Session has expired or is invalid.
 */
extern int const XMLAPI_ERROR_INVALID_SESSION;

/**
 *  Invalid default value for List Column type
 */
extern int const XMLAPI_ERROR_INVALID_LIST_COLUMN_TYPE;

/**
 *  Include All Lists is not valid.
 */
extern int const XMLAPI_ERROR_INCLUDE_ALL_LISTS_NOT_VALID;

/**
 *  Organization permissions prohibit using this API.
 */
extern int const XMLAPI_ERROR_INVALID_PERMISSIONS;

/**
 *  ERR_LIST_META_DENIED
 */
extern int const XMLAPI_ERROR_ERR_LIST_META_DENIED;

/**
 *  Unable to create set column values job. Internal error.
 */
extern int const XMLAPI_ERROR_CREATE_COLUMNS_INTERNAL_ERROR;

/**
 *  ERR_EXPORT_NOT_LIST_COLUMN
 */
extern int const XMLAPI_ERROR_ERR_EXPORT_NOT_LIST_COLUMN;

/**
 *  Action code is not valid.
 */
extern int const XMLAPI_ERROR_ACTION_CODE_NOT_VALID;

/**
 *  Action code is not valid.
 */
extern int const XMLAPI_ERROR_RULESET_DOES_NOT_EXIST;

/**
 *  Unable to create Export job. Internal error.
 */
extern int const XMLAPI_ERROR_CREATE_EXPORT_JOB_INTERNAL_ERROR;

/**
 *  Can only send Custom Automated Mailings. Please provide the Mailing ID for a Custom Automated Mailing.
 */
extern int const XMLAPI_ERROR_CUSTOM_MAILING_ID_REQUIRED;

/**
 *  COLUMN_NAME is not valid for this list.
 */
extern int const XMLAPI_ERROR_COLUMN_NAME_NOT_VALID;

/**
 *  Mailing is not active.
 */
extern int const XMLAPI_ERROR_MAILING_NOT_ACTIVE;

/**
 *  SQLException deleting ruleset.
 */
extern int const XMLAPI_ERROR_DELETE_RULESET_SQL_ERROR;

/**
 *  Error deleting rule.
 */
extern int const XMLAPI_ERROR_DELETE_RULESET_ERROR;

/**
 *  Usage was not an integer.
 */
extern int const XMLAPI_ERROR_USAGE_NOT_INTEGER;

/**
 *  SQLException listing Dynamic Content ruleset.
 */
extern int const XMLAPI_ERROR_DYNAMIC_CONTENT_RULESET_SQL_ERROR;

/**
 *  SQLException listing Dynamic Content rulesets for list.
 */
extern int const XMLAPI_ERROR_DYNAMIC_CONTENT_RULESET_SQL_ERROR_2;

/**
 *  Unable to check if user exists. Internal error.
 */
extern int const XMLAPI_ERROR_USER_EXISTS_INTERNAL_ERROR;

/**
 *  You cannot schedule Multimatch Mailings through the API.
 */
extern int const XMLAPI_ERROR_CANNOT_SCHEDULE_MULTIMATCH_MAILINGS;

/**
 *  A Mailing with the provided name already exists.
 */
extern int const XMLAPI_ERROR_MAILING_NAME_ALREADY_EXISTS;

/**
 *  Errors found validating mailing.
 */
extern int const XMLAPI_ERROR_MAILING_VALIDATION_ERROR;

/**
 *  Numerous errors related to dates.
 */
extern int const XMLAPI_ERROR_DATE_ERROR;

/**
 *  Report ID for Behavior is invalid.
 */
extern int const XMLAPI_ERROR_BEHAVIOR_REPORT_ID_NOT_VALID;

/**
 *  ERR_INVALID_SENT_MAILING_TYPE
 */
extern int const XMLAPI_ERROR_ERR_INVALID_SENT_MAILING_TYPE;

/**
 *  RECURSIVE flag is not valid.
 */
extern int const XMLAPI_ERROR_RECURSIVE_NOT_VALID;

/**
 *  Cannot use a System field name for a List column.
 */
extern int const XMLAPI_ERROR_LIST_COLUMN_CANNOT_BE_SYSTEM_FIELD;

/**
 *  Unable to locate element in the definition. Unable to continue.
 */
extern int const XMLAPI_ERROR_CANNOT_LOCATE_ELEMENT;

/**
 *  Unable to create query. New List name already exists.
 */
extern int const XMLAPI_ERROR_CREATE_QUERY_NAME_ALREADY_EXISTS;

/**
 *  A Ruleset with the provided name already exists.
 */
extern int const XMLAPI_ERROR_RULESET_WITH_NAME_ALREADY_EXISTS;

/**
 *  A Ruleset with the provided name does not exist.
 */
extern int const XMLAPI_ERROR_RULESET_WITH_NAME_DOES_NOT_EXIST;

/**
 *  Invalid value for Element: LIST_ID. Not an integer. Value: 'x'
 */
extern int const XMLAPI_ERROR_LIST_ID_NOT_INTEGER;

/**
 *  Unable to create Recipient Data Job. Internal error.
 */
extern int const XMLAPI_ERROR_CREATE_RECIPIENT_DATA_JOB_INTERNAL_ERROR;

/**
 *  List is not the right type for this API.
 */
extern int const XMLAPI_ERROR_LIST_TYPE_NOT_VALID_2;

/**
 *  Column is not the right type for this API.
 */
extern int const XMLAPI_ERROR_COLUMN_TYPE_NOT_VALID;

/**
 *  Column 'x' not found in list.
 */
extern int const XMLAPI_ERROR_COLUMN_NOT_FOUND;

/**
 *  Unable to opt out recipient from list. Internal error.
 */
extern int const XMLAPI_ERROR_RECIPIENT_OPT_OUT_INTERNAL_ERROR;

/**
 *  Invalid XML in request: COLUMN Element found without a NAME.
 */
extern int const XMLAPI_ERROR_COLUMN_NAME_REQUIRED;

/**
 *  Both MAILING_ID and LIST_ID provided. Please pick only one.
 */
extern int const XMLAPI_ERROR_MAILING_ID_AND_LIST_ID_SET;

/**
 *  Export Format is not valid.
 */
extern int const XMLAPI_ERROR_EXPORT_FORMAT_NOT_VALID;

/**
 *  Mailing content archived.
 */
extern int const XMLAPI_ERROR_MAILING_CONTENT_ARCHIVED;

/**
 *  Specified folder ID must be a number.
 */
extern int const XMLAPI_ERROR_FOLDER_ID_NOT_NUMBER;

/**
 *  Visibility of the list and parent folder must match.
 */
extern int const XMLAPI_ERROR_PARENT_FOLDER_VISIBILITY_MISMATCH;

/**
 *  Specified folder ID does not exist.
 */
extern int const XMLAPI_ERROR_FOLDER_ID_NOT_FOUND;

/**
 *  Unable to update recipient's EMAIL. EMAIL is part of Unique Identifier
 */
extern int const XMLAPI_ERROR_CANNOT_UPDATE_EMAIL;

/**
 *  SYNC_FIELD Element found without a NAME.
 */
extern int const XMLAPI_ERROR_SYNC_FIELD_NAME_REQUIRED;

/**
 *  Detailed report data for this mailing is not available at this time. Please try again later.
 */
extern int const XMLAPI_ERROR_MAILING_REPORT_DATA_NOT_AVAILABLE;

/**
 *  Error saving query to the database.
 */
extern int const XMLAPI_ERROR_QUERY_SAVE_ERROR;

/**
 *  Autoresponder is not active
 */
extern int const XMLAPI_ERROR_AUTO_RESPONDER_NOT_ACTIVE;

/**
 *  Recipient Id Not Found in List
 */
extern int const XMLAPI_ERROR_RECIPIENT_ID_NOT_FOUND;

/**
 *  Sync Id Not Found in List
 */
extern int const XMLAPI_ERROR_SYNC_ID_NOT_FOUND;

/**
 *  Error Saving Recipient
 */
extern int const XMLAPI_ERROR_RECIPIENT_SAVE_ERROR;

/**
 *  Error Retrieving Recipient
 */
extern int const XMLAPI_ERROR_RECIPIENT_RETRIEVE_ERROR;

/**
 *  Error Adding Recipient
 */
extern int const XMLAPI_ERROR_RECIPIENT_ADD_ERROR;

/**
 *  Missing Recipient Key Info
 */
extern int const XMLAPI_ERROR_RECIPIENT_KEY_MISSING;

/**
 *  Column Does Not Exist in List
 */
extern int const XMLAPI_ERROR_COLUMN_DOES_NOT_EXIST;

/**
 *  Recipient Not Found in List
 */
extern int const XMLAPI_ERROR_RECIPIENT_NOT_FOUND;

/**
 *  Recipient Already Deleted in Engage
 */
extern int const XMLAPI_ERROR_RECIPIENT_ALREADY_DELETED;

/**
 *  Cannot Update System Column
 */
extern int const XMLAPI_ERROR_CANNOT_UPDATE_SYSTEM_COLUMN;

/**
 *  Error Merging Recipient
 */
extern int const XMLAPI_ERROR_RECIPIENT_MERGE_ERROR;

/**
 *  Missing Required Column Value
 */
extern int const XMLAPI_ERROR_REQUIRED_COLUMN_VALUE;

/**
 *  Email Address is Invalid
 */
extern int const XMLAPI_ERROR_EMAIL_NOT_VALID;

/**
 *  Error Adding Contact; Contact Already Exists in Contact List
 */
extern int const XMLAPI_ERROR_CONTACT_ALREADY_EXISTS;

@end
