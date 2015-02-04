//
//  MobileIdentityManager.h
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/20/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import "SetupRecipientResult.h"
#import "SetupRecipientFailure.h"
#import "CheckIdentityResult.h"
#import "CheckIdentityFailure.h"

@interface MobileIdentityManager : NSObject

+ (instancetype)sharedInstance;

/**
 * Checks if the mobile user id has been configured yet.  If not
 * and the 'enableAutoAnonymousTracking' flag is set to true it is auto generated
 * using either the {@link EngageDefaultUUIDGenerator} or
 * the generator configured as the 'mobileUserIdGeneratorClassName'.  If
 * 'enableAutoAnonymousTracking' is 'NO' you are responsible for
 * manually setting the id using {@code EngageConfig#storeMobileUserId}.
 * <p/>
 * Once we have a mobile user id (generated or manually set) a new recipient is
 * created with the mobile user id.
 * <p/>
 * On successful completion of this method the EngageConfig will contain the
 * mobile user id and new recipient id.
 *
 * @param didSucceed custom behavior to run on success of this method
 * @param didFail custom behavior to run on failure of this method
 */
-(void)setupRecipientWithSuccess:(void (^)(SetupRecipientResult* result))didSucceed
                         failure:(void (^)(SetupRecipientFailure* failure))didFail;

/**
 * Checks for an existing recipient with all the specified ids.  If a matching recipient doesn't exist
 * the currently configured recipient is updated with the searched ids.  If an existing recipient
 * does exist the two recipients are merged and the engage app config is switched to the existing
 * recipient.
 * <p/>
 * When recipients are merged a history of the merged recipients is recorded.  By default it uses the
 * Mobile User Id, Merged Recipient Id, and Merged Date columns, however if you prefer to store
 * the merge history in a separate AuditRecord table you can set you EngageConfig.plist properties accordingly.
 * <p/>
 * WARNING: The merge process is not currently transactional.  If this method errors the data is likely to
 * be left in an inconsistent state.
 *
 * @param fieldsToIds Dictionary of column name to id value for that column.  Searches for an
 *                             existing recipient that contains ALL of the columns in the dictionary.
 *                             <p/>
 *                             Examples:
 *                             - Key: facebook_id, Value: 100
 *                             - Key: twitter_id, Value: 9999
 * @param didSucceed custom behavior to run on success of this method
 * @param didFail custom behavior to run on failure of this method
 */
-(void)checkIdentityForIds:(NSDictionary *)fieldsToIds
                   success:(void (^)(CheckIdentityResult* result))didSucceed
                   failure:(void (^)(CheckIdentityFailure* failure))didFail;

@end
