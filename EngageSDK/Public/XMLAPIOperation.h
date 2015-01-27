//
//  XMLAPIOperation.h
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/26/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

@interface XMLAPIOperation : NSObject

/**
 * You can automate a mailing to send after contacts successfully Opt In or Edit Profile using a
 * Web form associated. You can also set automation for custom events, which are triggered by an
 * API request.
 * <p/>
 * The SendMailing operation sends a mailing to the specified contact. The SendMailing operation
 * is specifically for the delivery of autoresponders based on a custom event. This operation will
 * NOT send a mailing Template1. The Mailing ID must be for an existing, custom event autoresponder
 * and the contact email address must be for a contact who already exists in the database associated
 * with the mailing. See the Add a Contact for information on adding a contact to a database.
 * <p/>
 * Each Send is queued for message generation and delivery. They do not always send immediately,
 * but receive slices of processing time as determined by an algorithm. Small sends such as these
 * are typically built and sent within a range of seconds-to-minutes, but that varies based on
 * several factors such as concurrent system usage.
 * <p/>
 * Note: There is a limit of 1,000 SendMailing API calls per day for an Organization. If you plan
 * to send more than 1,000 transactional emails per day, please contact your Silverpop account
 * manager to discuss alternatives.
 */
extern NSString * const XMLAPI_OPERATION_SEND_MAILING;

/**
 * This operation sends a copy of a mailing along with an additional message to the specified contacts.
 * You must use the Mailing ID of an existing Sent Mailing.
 * <p/>
 * Note: The ForwardToFriend API is not available for mailings associated with Non-Email-Key databases.
 */
extern NSString * const XMLAPI_OPERATION_FORWARD_TO_FRIEND;

/**
 * This interface returns details about a mailing sent to a specific contact. It is intended to be
 * used with the SureFrom Code which can be placed in the mailing body.
 */
extern NSString * const XMLAPI_OPERATION_GET_CONTACT_MAILING_DETAILS;

/**
 * This interface deletes all records from a database, suppression, seed, test or contact list
 * (target) based on the contacts existing in a specific database, contact list, or query (source).
 * <p/>
 * If both databases share the same key definition, contacts will be matched using the key.
 * However, if the key definition is different, contacts will be matched using email address.
 * <p/>
 * It is suggested that Contacts be purged from a non-keyed database by using an associated query
 * or contact list as the Source. Specifying different non-keyed databases for Target and Source
 * will not result in any matches to be purged.
 * <p/>
 * If a contact list is specified for the target, records are not deleted from the database;
 * the contacts are only removed from the contact list.
 * <p/>
 * A data job will be created upon successful processing of the request. The data job will perform the following:
 * • Remove contacts found in the target object which also exist in the source object.
 * • Create a new database or list containing copies of the purged records.
 * <p/>
 * This operation requires exposing the existing Purge functionality to the API with the following enhancements:
 * • Ability to specify a source query that is owned by the target parent (UI restricts this)
 * • Ability to purge data from a target Contact List
 * • Ability to purge a target Database or Contact List using the same object as the source
 * <p/>
 * The existing GetJobStatus operation may be used to determine the status of the data job.
 */
extern NSString * const XMLAPI_OPERATION_PURGE_DATA;

/**
 * This interface adds one new contact to an existing database. If your database has a key other
 * than Email, you must include all unique key columns with their corresponding name/value pairs.
 * If adding and/or updating contacts in a database that has no Unique Identifier defined, one or
 * more Sync Fields must be specified in order to look up the contact.
 * <p/>
 * When adding/updating records in your organization’s CRM List, you can specify whether to sync
 * the contact to your CRM system by passing a COLUMN element with a NAME “CRM Enable Sync” and
 * VALUE of Yes or No. If you do not include this column, the organization’s default setting will be used.
 * <p/>
 * When adding/updating records in your organization’s CRM List, you can specify whether the individual
 * is a Lead or Contact by passing a COLUMN element with a NAME “CRM Contact Type” and VALUE of “Lead”
 * or “Other”. If you do not include this column, the individual will be designated a Lead.
 */
extern NSString * const XMLAPI_OPERATION_ADD_RECIPIENT;

/**
 * This interface confirms the Opt-in for a contact in a Double Opt-in Database. Any fields specified
 * will override any previously specified values set when creating the contact from the Pre Opt-in state.
 * <p/>
 * Note: You must specify all key fields in the COLUMN elements.
 */
extern NSString * const XMLAPI_OPERATION_DOUBLE_OPT_IN_RECIPIENT;

/**
 * This interface updates a contact in an existing database. Use of the optional OPT_OUT child element
 * allows this operation to add a currently opted-out contact back into the database.
 * <p/>
 * If your database has a key other than Email, you must include all unique key columns with their
 * corresponding name/value pairs.
 * <p/>
 * If updating contacts in a database that has no Unique Identifier defined, one or more Sync Fields
 * must be specified in order to look up the contact.
 * <p/>
 * When adding/updating records in your organization’s CRM List, you can specify whether to sync the
 * contact to your CRM system by passing a COLUMN element with a NAME “CRM Enable Sync” and VALUE of
 * “Yes” or “No”. If you do not include this column, the organization’s default setting will be used.
 * <p/>
 * When adding/updating records in your organization’s CRM List, you can specify whether the individual
 * is a Lead or Contact by passing a COLUMN element with a NAME “CRM Contact Type” and VALUE of
 * “Lead” or “Other”. If you do not include this column, the individual will be designated a Lead.
 * <p/>
 * Key columns may only be updated if the RECIPIENT_ID or ENCODED_RECIPIENT_ID is passed to look up the contact.
 */
extern NSString * const XMLAPI_OPERATION_UPDATE_RECIPIENT;

/**
 * This interface moves a contact in a database to an opted-out state.
 * <p/>
 * If you are using a custom opt-out page and wish to record opt outs against specific mailings, you
 * must ensure that the link to your opt-out page within your mailing templates includes the following
 * parameters:
 * - %%MAILING_ID%%
 * - %%RECIPIENT_ID%%
 * - %%JOB_ID_CODE%%
 */
extern NSString * const XMLAPI_OPERATION_OPT_OUT_RECIPIENT;

/**
 * This interface retrieves the information about a contact in a database.
 * <p/>
 * If your database has a key other than Email, you must include all unique key columns with their
 * corresponding name/value pairs.
 * <p/>
 * If your database has no Unique Identifier defined, one or more columns must be specified in order
 * to look up the contact.
 * <p/>
 * If both Recipient Id and Visitor Key are provided, Recipient Id is used to lookup a contact.
 */
extern NSString * const XMLAPI_OPERATION_SELECT_RECIPIENT_DATA;

/**
 * Before calling any operation that requires authentication, you must obtain a
 * Jsession ID using the Login operation.
 */
extern NSString * const XMLAPI_OPERATION_LOGIN;

/**
 * After completing the API actions, you must use a Logout request to close and invalidate
 * the session.
 */
extern NSString * const XMLAPI_OPERATION_LOG_OUT;

/**
 * This interface allows importing a batch file containing new, modified, or opted out contacts.
 * Contacts can also be added to an existing Contact List.
 * <p/>
 * Use the steps below to perform an import through the API:
 * 1. Upload the source file to the Engage FTP server.
 * 2. Upload the Definition and Column Mapping file to the Engage FTP server.
 * 3. Authenticate the user with a Login API call.
 * 4. Initiate the database import using an ImportList call.
 * 5. Determine status of the background import job by making a GetJobStatus API call (optional).
 * 6. Log off from the Engage API using a Logout API call.
 * <p/>
 * You must place all files in the upload directory on the FTP server or the database import service
 * will not “find” them.
 * <p/>
 * Note: Contact your Relationship Manager to obtain FTP logon information.
 */
extern NSString * const XMLAPI_OPERATION_IMPORT_LIST;

/**
 * This interface exports contact data from a database, query, or contact list. Engage exports
 * the results to a CSV file, then adds that file to the FTP account associated with the current
 * session. You can copy the results file to Stored Files in Engage.
 * <p/>
 * Note: If the database is a Double Opt-in database, Engage only exports confirmed contacts.
 * In addition, the database security settings that allow you to use this operation are, by default,
 * disabled for all Double Opt-In databases.
 */
extern NSString * const XMLAPI_OPERATION_EXPORT_LIST;

/**
 * This interface allows adding a column to an existing Engage Database.
 */
extern NSString * const XMLAPI_OPERATION_ADD_LIST_COLUMN;

/**
 * This interface returns the description of a Database, Query, or Relational table.
 */
extern NSString * const XMLAPI_OPERATION_GET_LIST_META_DATA;

/**
 * This interface returns a list of mailings for a specified database (or query) and contact as
 * well as metrics associated with those mailings.
 * <p/>
 * Note: This operation only returns mailings with associated events (for example, Open, Clickthrough, and Bounce).
 */
extern NSString * const XMLAPI_OPERATION_LIST_RECIPIENT_MAILINGS;

/**
 * Use this interface to remove a contact from a database or Contact List. If your database has a key
 * other than Email, you must include all unique key columns with their corresponding name/value pairs.
 * If your database has no Unique Identifier defined, one or more Sync Fields must be specified in order
 * to look up the contact.
 */
extern NSString * const XMLAPI_OPERATION_REMOVE_RECIPIENT;

/**
 * This interface extracts a list of databases for an organization.
 */
extern NSString * const XMLAPI_OPERATION_GET_LISTS;

/**
 * This interface creates a Relational Table in Engage.
 */
extern NSString * const XMLAPI_OPERATION_CREATE_TABLE;

/**
 * This interface supports associating a Database with a Relational Table.
 * You must specify a table (name or ID) and database (name or ID) along
 * with the contact columns making the association.
 */
extern NSString * const XMLAPI_OPERATION_JOIN_TABLE;

/**
 * This interface inserts or updates relational data. For each Row that is passed in:
 * - If a row is found having the same key as the passed in row, update the record.
 * - If no matching row is found, insert a new row setting the column values to those
 * passed in the request. When rows are inserted or updated in the relational table,
 * all Column values are set based on the values passed in the COLUMN elements.
 * <p/>
 * Note: Only one hundred rows may be passed in a single InsertUpdateRelationalTable call.
 */
extern NSString * const XMLAPI_OPERATION_INSERT_UPDATE_RELATIONAL_TABLE;

/**
 * This interface deletes records from a relational table.
 */
extern NSString * const XMLAPI_OPERATION_DELETE_RELATIONAL_TABLE_DATA;

/**
 * This interface is used for programmatically creating or updating a Relational
 * Table in Engage. This operation requires a mapping file and source file stored
 * on the FTP server related to the Engage account used to Login. Once you upload
 * the Relational Table source and mapping files to the FTP server, you can make
 * an ImportTable API call to launch the job.
 * <p/>
 * Notes: This operation does not associate the relational table to a database.
 * See “Associate Relational Data to Contacts in a Database” for creating the association.
 */
extern NSString * const XMLAPI_OPERATION_IMPORT_TABLE;

/**
 * This interface supports programmatically exporting Relational Table data from Engage
 * into a CSV file, which Engage uploads to the FTP account or to the Stored Files
 * directory associated with the session.
 */
extern NSString * const XMLAPI_OPERATION_EXPORT_TABLE;

/**
 * This interface supports programmatically deleting Relational Table data from Engage.
 * You can purge all data (or specify a date range using “Delete Before”).
 */
extern NSString * const XMLAPI_OPERATION_PURGE_TABLE;

/**
 * The Delete Table API supports programmatically deleting Relational Table data from Engage.
 * You cannot delete the Relational Table in any of the following cases:
 * • When the table is in use by active Group of Automated Messages.
 * • If the table is in use by an active Autoresponder.
 * • If the table is in use by an active Sending mailing.
 * • When queries exist that reference the table, but are owned by an associated database.
 * <p/>
 * You can delete the following:
 * • Table data
 * • The table entity/structure
 * • Database/Table associations (joins)
 * • Relational Table queries
 */
extern NSString * const XMLAPI_OPERATION_DELETE_TABLE;

/**
 * This interface creates a new Contact List in Engage.
 */
extern NSString * const XMLAPI_OPERATION_CREATE_CONTACT_LIST;

/**
 * This interface adds one new contact to a Contact List. If the contact is not yet
 * in your database, they may be added using the AddRecipient operation (see the
 * “Add a Contact” section).
 * <p/>
 * The contact may be added to the Contact List by providing either a Contact Id or
 * the key fields from the Database. The Contact Id can be obtained from the
 * RecipientId element in the response of the following operations: AddRecipient,
 * UpdateRecipient, and SelectRecipientData.
 * <p/>
 * If providing key fields and your database has a key other than Email, you must
 * include all unique key columns with their corresponding name/value pairs. If
 * using a database that has no Unique Identifier defined, one or more columns must
 * be specified in order to look up the contact.
 * <p/>
 * Upon looking up the contact in the database using the Contact Id or key fields,
 * Engage will process the contact as follows:
 * • If the contact is found and does not yet exist in the Contact List, they will be added.
 * • If the contact is found and already exists in the Contact List, they will be not be added.
 * • If more than one contact is found matching the Sync Fields for a non-keyed list, an error
 * message will be returned.
 * • If the contact is not found, an error message will be returned.
 */
extern NSString * const XMLAPI_OPERATION_ADD_CONTACT_TO_CONTACT_LIST;

/**
 * This interface is used to add a Contact to a Program. The Contact will be added to the
 * beginning of the Program.
 * <p/>
 * This operation will typically be used in conjunction with either the AddRecipient or
 * UpdateRecipient operation. After adding or updating a Contact using those operations,
 * the RecipientId in the response XML can be used in the CONTACT_ID element in a
 * subsequent AddContactToProgram API request.
 * <p/>
 * A valid jsessionid must be provided to authenticate the request.
 * <p/>
 * The contact will not be added if any of the following scenarios exist:
 * • The specified CONTACT_ID is already an active participant in the Program.
 * • The specified CONTACT_ID is NOT in the database associated with the Program.
 * • The specified PROGRAM_ID is Pending and not accepting new Contacts.
 * • The specified PROGRAM_ID is Inactive and not accepting new Contacts.
 * • The specified PROGRAM_ID is Completed and not accepting new Contacts.
 * • The specified PROGRAM_ID has a Last Contact Add Date in the past.
 * • The specified PROGRAM_ID does not exist.
 */
extern NSString * const XMLAPI_OPERATION_ADD_CONTACT_TO_PROGRAM;

/**
 * This interface supports programmatically creating a query of an Engage database.
 * A query can search for values within database columns, relational table columns,
 * and also filter by mailing activity.
 */
extern NSString * const XMLAPI_OPERATION_CREATE_QUERY;

/**
 * This interface supports programmatically calculating the number of contacts for a query.
 * A data job is submitted to calculate the query and GetJobStatus must be used to determine
 * whether the data job is complete. You may only call the Calculate Query data job for a
 * particular query if you have not calculated the query size in the last 12 hours.
 */
extern NSString * const XMLAPI_OPERATION_CALCULATE_QUERY;

/**
 * This interface updates a column value for all records in a database, query, or contact list.
 * If a query or contact list is specified, contacts in the parent database will be updated
 * if they are in the query or contact list.
 */
extern NSString * const XMLAPI_OPERATION_SET_COLUMN_VALUE;

/**
 * This interface extracts mailing tracking metrics and creates a .zip file containing one or
 * more flat files (plain text with one row of data per line) for extracted mailing metrics.
 */
extern NSString * const XMLAPI_OPERATION_TRACKING_METRIC_EXPORT;

/**
 * This interface allows exporting unique contact-level events and creates a .zip file containing
 * a single flat file with all metrics. You can request all (or a subset) of the Event Types.
 * The API provides the ability to specify one of the following:
 * • One or more mailings
 * • One or more Mailing/Report ID combinations (for Autoresponders)
 * • A specific Database (optional: include related queries)
 * • A specific Group of Automated Messages
 * • An Event Date Range
 * • A Mailing Date Range
 * <p/>
 * If Private mailings—not owned by the user calling the API—are explicitly specified or are determined
 * based on a specified Database, Group of Automated Messages, or Date Range, the events associated
 * with that mailing will not be included in the resulting file. No error will be returned and all
 * other mailing events will be included in the file.
 * <p/>
 * When exporting events within a date range, you can filter them by Mailing Type (for example,
 * Automated Messages). This API provides the ability to export all events not yet exported.
 * This allows exporting on a recurring basis without specifying date ranges. Engage returns
 * any event not previously exported by the user.
 */
extern NSString * const XMLAPI_OPERATION_RAW_RECIPIENT_DATA_EXPORT;

/**
 * This interface allows exporting unique Web Tracking events and creates a .zip file containing a
 * single flat file with all events. You can request all (or a subset) of the Event Types. The API
 * provides the ability to specify the following:
 * • One or more Landing Pages Site
 * • One or more Custom Domains
 * • A specific Database
 * • An Event Date Range
 * <p/>
 * If a Site, Domain, or Database is not specified, all events for the Event Date Range will be
 * returned for the Organization of the calling user.
 * <p/>
 * A file is generated based on the request and placed in the Stored Files or FTP account
 * associated with the Engage user calling the API.
 */
extern NSString * const XMLAPI_OPERATION_WEB_TRACKING_DATA_EXPORT;

/**
 * This interface extracts the Report IDs for a particular mailing sent between specified dates.
 * For standard mailings, this will be a single ID, but for Autoresponders and Automated Messages,
 * this will be one ID per day.
 */
extern NSString * const XMLAPI_OPERATION_GET_REPORT_ID_BY_DATE;

/**
 * This interface extracts a listing of mailings sent for an organization for a specified date range.
 * <p/>
 * Note: The Engage user account calling the API must have Organization Administration rights.
 */
extern NSString * const XMLAPI_OPERATION_GET_SENT_MAILINGS_FOR_ORG;

/**
 * This interface extracts a listing of mailings sent for the logged on user for a specified date range.
 * <p/>
 * If the calling user is an Org Admin, all users’ mailings will be returned. If using the OPTIONALUSER
 * parameter, an Org Admin can specify a particular username to retrieve only mailings sent by that user.
 */
extern NSString * const XMLAPI_OPERATION_GET_SENT_MAILINGS_FOR_USER;

/**
 * This interface extracts a listing of mailings sent for a particular database and specified date range.
 * It allows specification of a Database or Query ID as well as a flag to include “children.”
 * <p/>
 * Note: The Engage user account calling the API must have Organization Administration rights.
 */
extern NSString * const XMLAPI_OPERATION_GET_SENT_MAILINGS_FOR_LIST;

/**
 * This interface extracts metrics for a specified mailing.
 */
extern NSString * const XMLAPI_OPERATION_GET_AGGREGATE_TRACKING_FOR_MAILING;

/**
 * This interface extracts a listing of mailings sent for an organization for a specified date range
 * and provides metrics for those mailings.
 */
extern NSString * const XMLAPI_OPERATION_GET_AGGREGATE_TRACKING_FOR_ORG;

/**
 * This interface extracts a listing of mailings sent by a user for a specified date range and
 * provides metrics for those mailings.
 */
extern NSString * const XMLAPI_OPERATION_GET_AGGREGATE_TRACKING_FOR_USER;

/**
 * After initiating a data job, you can monitor the status of the job using this operation.
 * This step is optional in the job process.
 * <p/>
 * If a data job completes with errors, you can view detailed results in the Results file
 * (.res) and Error file (.err) which you can find in the Download folder of the FTP account.
 */
extern NSString * const XMLAPI_OPERATION_GET_JOB_STATUS;

/**
 * After verifying the successful completion of a data job, the user can remove the job from
 * Engage by using the DeleteJobStatus operation.
 */
extern NSString * const XMLAPI_OPERATION_DELETE_JOB;

/**
 * GetFolderPathThis interface returns the Folder Path for a specified Folder Id or a specified
 * Object Id (e.g. Database, Query, Contact List, or Mailing).
 */
extern NSString * const XMLAPI_OPERATION_GET_FOLDER_PATH;

/**
 * Sends a template-based mailing to a specific database or query.
 */
extern NSString * const XMLAPI_OPERATION_SCHEDULE_MAILING;

/**
 * This interface returns a preview of a mailing template. If a contact email address is provided
 * in the request, the preview will include personalization for the specified contact.
 */
extern NSString * const XMLAPI_OPERATION_PREVIEW_MAILING;

/**
 * This interface returns the description of an Automated Message Group.
 */
extern NSString * const XMLAPI_OPERATION_GET_MESSAGE_GROUP_DETAILS;

/**
 * This interface creates a Ruleset including its content areas, rules, and content. If user does
 * not specify a MAILING_ID, Engage will create a new Ruleset in the user’s Private folder of
 * the Asset Library.
 * <p/>
 * Note: A ruleset may contain no more than 1,000 rules.
 */
extern NSString * const XMLAPI_OPERATION_ADD_DYNAMIC_CONTENT_RULE_SET;

/**
 * This interface imports a .zip containing the XML file defining a New or Classic Dynamic Content
 * Ruleset and any associated HTML or images. Imported files are loaded from the user’s FTP
 * upload directory.
 * <p/>
 * If the user does not specify a MAILING_ID or RULESET_ID, Engage creates a new Ruleset in the
 * user’s Private folder of the Asset Library. If the user does specify a RULESET_ID, Engage replaces
 * the Ruleset.
 * <p/>
 * Note: A ruleset may contain no more than 1,000 rules.
 */
extern NSString * const XMLAPI_OPERATION_IMPORT_DYNAMIC_CONTENT_RULE_SET;

/**
 * This interface exports the specified Ruleset and all associated content (including images),
 * from the Asset Library as a .zip file. Engage places the file in the FTP or Stored Files
 * directory based on the user’s choice (Stored Files is the default directory if user does not
 * select a specific location).
 * <p/>
 * This interface supports both Classic and New Dynamic Content Rulesets. The exported file
 * will be appropriately formatted (Classic or New Dynamic Content Ruleset) in accordance
 * with RULESET_ID that was passed.
 */
extern NSString * const XMLAPI_OPERATION_EXPORT_DYNAMIC_CONTENT_RULE_SET;

/**
 * This interface returns a list of available DC Rulesets for the specified mailing.
 */
extern NSString * const XMLAPI_OPERATION_LIST_DYNAMIC_CONTENT_RULE_SETS_FOR_MAILING;

/**
 * This interface returns the specified Ruleset in XML format. It does not support returning content
 * images. To retrieve a complete Ruleset and its associated content, use the ExportDCRuleset operation.
 */
extern NSString * const XMLAPI_OPERATION_GET_DYNAMIC_CONTENT_RULE_SET;

/**
 * This interface replaces an existing Ruleset with newly specified parameters.
 * <p/>
 * Note: A ruleset cannot contain more than 1,000 rules.
 */
extern NSString * const XMLAPI_OPERATION_REPLACE_DYNAMIC_CONTENT_RULE_SET;

/**
 * This interface performs a validation check against all Dynamic Content Rulesets (including
 * nested Rulesets) associated with the specified mailing. The validation check ensures that
 * all placeholders and criteria match the specified mailing and its Rulesets.
 */
extern NSString * const XMLAPI_OPERATION_VALIDATE_DYNAMIC_CONTENT_RULE_SET;

/**
 * This interface deletes the specified Ruleset from the Asset Library. You can only delete Rulesets
 * that are not associated with a mailing. If you attempt to delete a mailing's Ruleset, you will
 * receive an error indicating the reason for failure (the Ruleset is currently associated with a
 * mailing). If the desired result is to delete the Ruleset in order to update its content, utilize
 * the ReplaceDCRuleset operation.
 */
extern NSString * const XMLAPI_OPERATION_DELETE_DYNAMIC_CONTENT_RULE_SET;

/**
 * This interface extracts a list of Shared or Private mailing templates for your Organization.
 * The templates returned may be limited by the date they were last modified.
 */
extern NSString * const XMLAPI_OPERATION_GET_MAILING_TEMPLATES;

/**
 * This interface exports a mailing template. The results are an .stl file (a zip file containing
 * XML with a Silverpop Template extension) which will be written to the FTP account associated
 * with the current session. You can (optionally) copy the resulting file to Stored Files.
 */
extern NSString * const XMLAPI_OPERATION_EXPORT_MAILING_TEMPLATE;

@end
