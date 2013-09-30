//
//  SLLocationManager.m
//  Send Location To Server
//
//  Created by Mixaill Anatolich on 6/10/13.
//  Copyright (c) 2013 Mixaill Anatolich. All rights reserved.
//

#import "SLLocationManager.h"
#import "SLAppManager.h"

static CGFloat const kMinUpdateDistance = 5.f;
static NSTimeInterval const kMinUpdateTime = 5.f;
static NSTimeInterval const kMaxTimeToLive = 30.f;

@interface SLLocationManager () {
    UIBackgroundTaskIdentifier bgTask;
}

@end

@implementation SLLocationManager

+ (SLLocationManager*)sharedManager {
    static SLLocationManager* sharedSLLocationManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once( &predicate, ^{
        sharedSLLocationManagerInstance = [[self alloc] init];
    } );
    return sharedSLLocationManagerInstance;
}

#pragma mark - NSObject

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:    UIApplicationDidEnterBackgroundNotification object:nil];
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        self.locationManager.distanceFilter = kMinUpdateDistance;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.locationManager.delegate = nil;
}

#pragma mark - Notification handlers

- (void)applicationDidBecomeActive {
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
}

- (void)applicationDidEnterBackground {
    [self.locationManager stopUpdatingLocation];
    if ([UserDefaults boolForKey:SEND_LOCATION_IN_BACKGROUND_SETTING]) {
        [self.locationManager startMonitoringSignificantLocationChanges];
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - Public

- (void)startUpdatingLocation {
    [self stopUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
    //[self isInBackground] ? ([UserDefaults boolForKey:SEND_LOCATION_IN_BACKGROUND_SETTING] ? [self.locationManager startMonitoringSignificantLocationChanges] : [self.locationManager stopMonitoringSignificantLocationChanges]) : [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)endBackgroundTask {
    if (bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
}
#pragma mark - Private

- (BOOL)isInBackground {
    return [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (oldLocation && ([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp] < kMinUpdateTime ||
                        [newLocation distanceFromLocation:oldLocation] < kMinUpdateDistance)) {
        return;
    }
    
    if ([self isInBackground]) {
        
        [SLAppManager showLocalNotificationForTestWithMessage:[NSString stringWithFormat:@"New location: %@", newLocation]];
        
        bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        }];
        
        [SLAppManager sendLocation:newLocation withFinishBlock:^{
            [SLAppManager showLocalNotificationForTestWithMessage:@"location sended and end background task"];
            [self endBackgroundTask];
        }];
        
    } else {
        [SLAppManager sendLocation:newLocation withFinishBlock:nil];
        [NotificationCenter postNotificationName:UPDATE_LOCATION_NOTIFICATION object:newLocation];
    }
}

@end
