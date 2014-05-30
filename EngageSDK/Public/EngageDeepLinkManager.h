//
//  EngageDeepLinkManager.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileDeepLinking-iOS/MobileDeepLinking.h>
#import <MobileDeepLinking-iOS/MDLDeeplinkMatcher.h>

@interface EngageDeepLinkManager : MobileDeepLinking

+ (id)sharedInstance;

- (NSDictionary *)parseDeepLinkURL:(NSURL *)deepLink;

@end
