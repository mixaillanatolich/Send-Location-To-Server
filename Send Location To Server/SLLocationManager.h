//
//  SLLocationManager.h
//  Send Location To Server
//
//  Created by Mixaill Anatolich on 6/10/13.
//  Copyright (c) 2013 Mixaill Anatolich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^locationHandler)(CLLocation *location);

@interface SLLocationManager : NSObject <CLLocationManagerDelegate>

+ (SLLocationManager*)sharedManager;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy) locationHandler locationUpdatedInForeground;
@property (nonatomic, copy) locationHandler locationUpdatedInBackground;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (void)endBackgroundTask;

@end
