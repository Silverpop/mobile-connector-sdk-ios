//
//  EngageResponseXML.h
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/12/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResultDictionary.h"

@interface EngageResponseXML : NSObject<NSXMLParserDelegate>

+(id) decode:(id)responseObject;

@end
