//
//  EngageResponseXML.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/12/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "EngageResponseXML.h"


@interface EngageResponseXML ()

@property NSMutableString *text;
@property NSMutableArray *dictionaryStack;
@property NSError *error;

@end

@implementation EngageResponseXML


+(id) new
{
    EngageResponseXML *response = [[self alloc] init];
    response.text = [NSMutableString string];
    response.dictionaryStack = [NSMutableArray array];
    // Initialize the stack with a fresh dictionary
    [response.dictionaryStack addObject:[NSMutableDictionary dictionary]];
    return response;
}

+(ResultDictionary *) decode:(id)xmlParser {
    EngageResponseXML *engageRes = [EngageResponseXML new];
    // parse the response
    [xmlParser setDelegate:engageRes];
    if ([xmlParser parse]) {
        id obj = [engageRes.dictionaryStack objectAtIndex:0];
        ResultDictionary *result = [[ResultDictionary alloc] initWithDictionary:obj];
        return result;
    }
    
    return nil;
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    elementName = [elementName lowercaseString];
    
    if ([elementName isEqualToString:@"envelope"]
        || [elementName isEqualToString:@"body"]
        || [elementName isEqualToString:@"result"]) return;
    
    // Get the dictionary for the current level in the stack
    NSMutableDictionary *parentDict = [_dictionaryStack lastObject];
    
    // Create the child dictionary for the new element, and initilaize it with the attributes
    NSMutableDictionary *childDict = [NSMutableDictionary dictionary];
    [childDict addEntriesFromDictionary:attributeDict];
    
    // If there’s already an item for this key, it means we need to create an array
    id existingValue = [parentDict objectForKey:elementName];
    // according to XMLAPI documentation, email is included twice but no reason is given
    if (existingValue && ![elementName isEqualToString:@"email"])
    {
        NSMutableArray *array = nil;
        if ([existingValue isKindOfClass:[NSMutableArray class]])
        {
            // The array exists, so use it
            array = (NSMutableArray *) existingValue;
        }
        else
        {
            // Create an array if it doesn’t exist
            array = [NSMutableArray array];
            [array addObject:existingValue];
            
            // Replace the child dictionary with an array of children dictionaries
            [parentDict setObject:array forKey:elementName];
        }
        
        // Add the new child dictionary to the array
        [array addObject:childDict];
    }
    else
    {
        // No existing value, so update the dictionary
        [parentDict setObject:childDict forKey:elementName];
    }
    
    // Update the stack with pointer to dictionary in progress
    [_dictionaryStack addObject:childDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    elementName = [elementName lowercaseString];
    
    if ([elementName isEqualToString:@"envelope"]
        || [elementName isEqualToString:@"body"]
        || [elementName isEqualToString:@"result"]) return;
    
    // Update the parent dict with text info
    NSMutableDictionary *dictInProgress = [_dictionaryStack lastObject];
    
    NSString *string = [_text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Set the text property
    if (string && ![string isEqualToString:@""])
    {
        // Get rid of leading + trailing whitespace
        [dictInProgress setObject:string forKey:@"text"];
        
        // Reset the text
        self.text = [NSMutableString string];
    }
    
    // Pop the current dict
    [_dictionaryStack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // Build the text value
    [_text appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    // Set the error pointer to the parser’s error object
    self.error = parseError;
}


@end
