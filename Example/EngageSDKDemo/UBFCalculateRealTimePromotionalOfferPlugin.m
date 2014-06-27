//
//  UBFCalculateRealTimePromotionalOfferPlugin.m
//  EngageSDKDemo
//
//  Created by Jeremy Dyer on 6/27/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "UBFCalculateRealTimePromotionalOfferPlugin.h"
#import "UBFAccelerameterAugmentationPlugin.h"
#import "UBFWeatherAugmentationPlugin.h"
#import "EngageConfig.h"
#import "EngageConfigManager.h"
#import <AudioToolbox/AudioToolbox.h>

#define REAL_TIME_USER_EXPERIENCE_CAMPAIGN @"Real Time User Experience Campaign"

@interface UBFCalculateRealTimePromotionalOfferPlugin()

@property (assign)BOOL isDeviceFacingUser;
@property (nonatomic, strong) NSString *ubfLocationAddressName;

@property (assign) BOOL playSound;
@property (nonatomic, strong) NSString *displayMessage;

@end

@implementation UBFCalculateRealTimePromotionalOfferPlugin

-(id)init {
    self = [super init];
    if (self) {
        self.ubfLocationAddressName = [[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_LOCATION_ADDRESS];
    }
    return self;
}


-(BOOL)processSyncronously {
    return NO;
}


-(BOOL)isSupplementalDataReady:(UBF*)ubfEvent {
    //Always ready because it just computes a hard value
    return YES;
}


-(UBF*)process:(UBF*)ubfEvent {
    if (ubfEvent) {
        //Gets the appropriate campaign for the user.
        self.displayMessage = [self determineAppropriateUserCampaignFromWeather:ubfEvent];
        
        //Gets the pitch of the device to determine if the phone is facing the ground or not
        self.isDeviceFacingUser = [self isDeviceFacingUser:ubfEvent];
        if (!self.isDeviceFacingUser) {
            //Play an annoying noise to make the user look at the phone and display a notification
            self.playSound = YES;
        } else {
            //Just simply display a alert notification to the user
            self.playSound = NO;
        }
        
        [self performSelectorOnMainThread:@selector(displayAlertMessageToUser) withObject:nil waitUntilDone:NO];
        [ubfEvent setAttribute:REAL_TIME_USER_EXPERIENCE_CAMPAIGN value:self.displayMessage];
        
    }
    return ubfEvent;
}

- (NSString *)determineAppropriateUserCampaignFromWeather:(UBF *)ubfEvent {
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    NSNumber *hotIndex = [numFormatter numberFromString:[ubfEvent.attributes objectForKey:HOT_WEATHER]];
    NSString *userAddress = [ubfEvent.attributes objectForKey:self.ubfLocationAddressName];
    if ([hotIndex intValue] == 0) {
        //It isn't hot outside. Lets suggest some Coffee for the user.
        if (userAddress) {
            return [NSString stringWithFormat:@"Its cool at %@ today. How about $5 off at Starbucks?", userAddress];
        } else {
            return @"Seems a bit chilly today where you are how about 20% off Starbucks?";
        }
    } else {
        //It is hot outside lets suggest a Coors Lite Summer Brew. (Just saw advertisement while writing this)
        if (userAddress) {
            return [NSString stringWithFormat:@"Hot day at %@. How about $5 off at Coors Lite Summer Brew 12 pack?", userAddress];
        } else {
            return @"Seems hot where you are how about 20% off a Coors Lite Summer Brew 12 pack?";
        }
    }
}

- (BOOL)isDeviceFacingUser:(UBF *)ubfEvent {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber *devicePitch = [numberFormatter numberFromString:[ubfEvent.attributes objectForKey:DEVICE_PITCH_DEGREES]];
    
    if ([devicePitch doubleValue] < 0) {
        return NO;
    } else {
        return YES;
    }
}

- (void) displayAlertMessageToUser {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Weather Offer"
                                                    message:self.displayMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    
    //PLays the sound only if the device is not facing the user's eyes as determined by a previous augmentation plugin
    if (self.playSound) {
        AudioServicesPlaySystemSound(1007);
    }
    
    [alert show];
}

@end
