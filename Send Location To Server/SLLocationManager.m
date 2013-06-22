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
static NSTimeInterval const kMinUpdateTime = 30.f;
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
    [self.locationManager startMonitoringSignificantLocationChanges];
}

#pragma mark - Public

- (void)startUpdatingLocation {
    [self stopUpdatingLocation];
    [self isInBackground] ? [self.locationManager startMonitoringSignificantLocationChanges] : [self.locationManager startUpdatingLocation];
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
        
        [SLAppManager sendNMEALocation:newLocation withFinishBlock:^{
            [SLAppManager showLocalNotificationForTestWithMessage:@"location sended and end background task"];
            [self endBackgroundTask];
        }];
        
    } else {
        [SLAppManager sendNMEALocation:newLocation withFinishBlock:nil];
        [NotificationCenter postNotificationName:UPDATE_LOCATION_NOTIFICATION object:newLocation];
    }
}

@end
