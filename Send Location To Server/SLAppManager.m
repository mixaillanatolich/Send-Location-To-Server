//
//  SLAppManager.m
//  Send Location To Server
//
//  Created by Mixaill Anatolich on 6/10/13.
//  Copyright (c) 2013 Mixaill Anatolich. All rights reserved.
//

#import "SLAppManager.h"
#import "CoreTelephony.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

@interface SLAppManager () {
    
    NSDate *lastUpdateDate;
    
    
    NSTimer *requestTimer;
}

@end

@implementation SLAppManager

+ (SLAppManager*)sharedManager {
    static SLAppManager* sharedAppManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once( &predicate, ^{
        sharedAppManagerInstance = [[self alloc] init];
    } );
    return sharedAppManagerInstance;
}

#pragma mark - NSObject

- (id)init {
    if (self = [super init]) {
        
        if (![UserDefaults boolForKey:NOT_FIRST_START]) {
            [UserDefaults setBool:YES forKey:SEND_LOCATION_IN_BACKGROUND_SETTING];
            [UserDefaults setBool:NO forKey:NOT_TURN_OFF_DISPLAY_SETTING];
            [UserDefaults setInteger:DEFAULT_LOGGIN_INTERVAL forKey:LOGGIN_INTERVAL_SETTING];
            
            [UserDefaults setBool:YES forKey:NOT_FIRST_START];
            [UserDefaults synchronize];
        }
        
        [[UIApplication sharedApplication] setIdleTimerDisabled:[UserDefaults boolForKey:NOT_TURN_OFF_DISPLAY_SETTING]];
        
        self.locationManager = [SLLocationManager sharedManager];
        [_locationManager startUpdatingLocation];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [self setupRequestTimer];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification handlers

- (void)applicationDidBecomeActive {
    [self setupRequestTimer];
}

- (void)applicationDidEnterBackground {
    [self resetRequestTimer];
}

#pragma mark - privite

- (void)setupRequestTimer {
    [self resetRequestTimer];
    requestTimer = [NSTimer scheduledTimerWithTimeInterval:[self updateInterval] target:self selector:@selector(maybeSendLocationToServer) userInfo:nil repeats:YES];
}

- (void)resetRequestTimer {
    [requestTimer invalidate];
    requestTimer = nil;
}

- (NSTimeInterval)updateInterval {
    NSInteger loginInterval = [UserDefaults integerForKey:LOGGIN_INTERVAL_SETTING];
    if (loginInterval <= 0) {
        loginInterval = DEFAULT_LOGGIN_INTERVAL;
    }
    return loginInterval;
}

- (void)maybeSendLocationToServer {
    
    if ([UserDefaults boolForKey:SEND_LOCATION_ENABLED]) {
        CLLocation *currentLocation = _locationManager.locationManager.location;
        
        if (!currentLocation) {
            return;
        }
        
        lastUpdateDate = [NSDate new];
        
        [SLAppManager sendLocation:currentLocation force:NO withFinishBlock:nil];
    }
    
}

#pragma mark - public

- (void)sendLocationToServer {
    
    CLLocation *currentLocation = _locationManager.locationManager.location;
    
    if (!currentLocation) {
        return;
    }
    
    lastUpdateDate = [NSDate new];
    
    [SLAppManager sendLocation:currentLocation force:YES withFinishBlock:nil];
    
}

+ (void)sendLocation:(CLLocation*)location withFinishBlock:(void(^)())callback {
    [SLAppManager sendLocation:location force:NO withFinishBlock:callback];
}

+ (void)sendLocation:(CLLocation*)location force:(BOOL)force withFinishBlock:(void(^)())callback {
    
    if (!location) {
        if (callback) {
            callback();
        }
        return;
    }
    
    if (![UserDefaults boolForKey:SEND_LOCATION_ENABLED] && !force) {
        if (callback) {
            callback();
        }
        return;
    }
    
    NSMutableURLRequest *request;
    
    
    int typeOfRequest = [UserDefaults integerForKey:TYPE_OF_REQUEST_SETTING];
    
    if (typeOfRequest == 0) {
        request = [SLAppManager customFormatRequestForLocation:location];
    } else if (typeOfRequest == 1) {
        request = [SLAppManager NMEARequestForLocation:location];
    } else {
        request = [SLAppManager NMEARequestForLocation:location];
    }
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"sendLocationToServer %@", JSON);
        if (callback) {
            callback();
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"sendLocationToServer Fail %@ - %@",JSON, error);
        if (callback) {
            callback();
        }
    }];
    [operation start];
    
    [NotificationCenter postNotificationName:SEND_LOCATION_NOTIFICATION object:location];
}

#pragma mark - requests

+ (NSMutableURLRequest*)customFormatRequestForLocation:(CLLocation*)location {
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[self hostname]]];
    
    [client setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"SendLocation %@", [client defaultValueForHeader:@"User-Agent"]]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
                                @"lat" : [NSString stringWithFormat:@"%.6f", location.coordinate.latitude],
                                @"lon" : [NSString stringWithFormat:@"%.6f", location.coordinate.longitude],
                                @"speed" : [NSString stringWithFormat:@"%.6f", location.speed],
                                @"heading" : [NSString stringWithFormat:@"%.6f", location.course],
                                @"vacc" : [NSString stringWithFormat:@"%.6f", location.verticalAccuracy],
                                @"hacc" : [NSString stringWithFormat:@"%.6f", location.horizontalAccuracy],
                                @"altitude" : [NSString stringWithFormat:@"%.6f", location.altitude]
                                }];
    
    
    NSDictionary *additionalParams = [UserDefaults dictionaryForKey:ADDITIONAL_PARAMETERS_SETTING];
    if (additionalParams && additionalParams.count) {
        [params addEntriesFromDictionary:additionalParams];
    }
    
    if ([UserDefaults boolForKey:SEND_DEVICE_ID_SETTING]) {
        [params setObject:([UserDefaults objectForKey:DEVICE_ID_SETTING] ? [UserDefaults objectForKey:DEVICE_ID_SETTING] : @"") forKey:@"deviceid"];
    }
    
    if ([UserDefaults boolForKey:SEND_ACCOUNT_ID_SETTING]) {
        [params setObject:([UserDefaults objectForKey:ACCOUNT_ID_SETTING] ? [UserDefaults objectForKey:ACCOUNT_ID_SETTING] : @"") forKey:@"accountid"];
    }
    
    NSString *httpMethod = [UserDefaults valueForKey:TYPE_OF_HTTP_METHOD_SETTING];
    
    if (![httpMethod isEqualToString:@"POST"] && ![httpMethod isEqualToString:@"GET"]) {
        httpMethod = @"GET";
    }
    
    NSMutableURLRequest *request = [client requestWithMethod:httpMethod path:nil parameters:params];
    [request setTimeoutInterval:15];
    
    return request;
}

+ (NSMutableURLRequest*)NMEARequestForLocation:(CLLocation*)location {
    
    //POST /gprmc/Data?acct=testandr&dev=test01&gprmc=$GPRMC,204102,A,5640.2307,N,04327.5038,E,000.0,000.0,110613,,*11
    
    NSArray *timeAndDate = [SLAppManager devideTimeAndDate];
    
    NSString *gprmc = [NSString stringWithFormat:@"gprmc=$GPRMC,%@,A,%@,%@,%@,%04.1f,%@,,*", timeAndDate[0],[SLAppManager latitudeForCLLocationDegrees:location.coordinate.latitude], [SLAppManager longitudeForCLLocationDegrees:location.coordinate.longitude], [SLAppManager speedToKnots:location.speed], (location.course >= 0.0 ? location.course : 0.0),timeAndDate[1]];
    
    gprmc = [gprmc stringByAppendingString:[SLAppManager xorString:gprmc]];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[self hostname]]];
    
    NSString *param = [NSString stringWithFormat:@"%@?%@",[SLAppManager pathOnServer], gprmc];
    
    NSDictionary *additionalParams = [UserDefaults dictionaryForKey:ADDITIONAL_PARAMETERS_SETTING];
    if (additionalParams && additionalParams.count) {
        for (NSString *key in additionalParams.allKeys) {
            NSString *parameter = [NSString stringWithFormat:@"%@=%@",key,[additionalParams objectForKey:key]];
            parameter = [parameter stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            param = [param stringByAppendingFormat:@"&%@",parameter];
        }
    }
    
    if ([UserDefaults boolForKey:SEND_DEVICE_ID_SETTING]) {
        NSString *deviceId = [NSString stringWithFormat:@"deviceid=%@",([UserDefaults objectForKey:DEVICE_ID_SETTING] ? [UserDefaults objectForKey:DEVICE_ID_SETTING] : @"")];
        deviceId = [deviceId stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        param = [param stringByAppendingFormat:@"&%@",deviceId];
    }
    
    if ([UserDefaults boolForKey:SEND_ACCOUNT_ID_SETTING]) {
        NSString *accountId = [NSString stringWithFormat:@"accountid=%@",([UserDefaults objectForKey:ACCOUNT_ID_SETTING] ? [UserDefaults objectForKey:ACCOUNT_ID_SETTING] : @"")];
        accountId = [accountId stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        param = [param stringByAppendingFormat:@"&%@",accountId];
    }
    
    NSString *httpMethod = [UserDefaults valueForKey:TYPE_OF_HTTP_METHOD_SETTING];
    
    if (![httpMethod isEqualToString:@"POST"] && ![httpMethod isEqualToString:@"GET"]) {
        httpMethod = @"GET";
    }
    
    NSMutableURLRequest *request = [client requestWithMethod:httpMethod path:param parameters:nil];
    [request setTimeoutInterval:15];
    
    return request;
}

#pragma mark - private

+ (NSString*)hostname {
    return [NSString stringWithFormat:@"http://tr.gpshome.ru:20100"];
}

+ (NSString*)pathOnServer {
    return [NSString stringWithFormat:@"/gprmc/Data"];
}

+ (NSString*)deviceId {
    return [NSString stringWithFormat:@"testandr"];
}

+ (NSString*)requestFormat {
    return @"imei=%@lat=%@&lon=%@&speed=%@&heading=%@&vacc=%@&hacc=%@&altitude=%@";
}

+ (NSArray*)devideTimeAndDate {
    
    NSLocale * enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] ;
    NSDateFormatter *formatOfDate = [[NSDateFormatter alloc] init];
    [formatOfDate setDateFormat:@"HHmmss.SSS"];
    [formatOfDate setLocale:enUSPOSIXLocale];
    [formatOfDate setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSString *time = [formatOfDate stringFromDate:[NSDate new]];
    
    [formatOfDate setDateFormat:@"ddMMyy"];
    NSString *date = [formatOfDate stringFromDate:[NSDate new]];
    
    return @[time, date];
}

+ (NSString*)latitudeForCLLocationDegrees:(CLLocationDegrees)latitude {
    
    if (!latitude) {
        return @"0000.0000,N";
    }
    
    double _degrees = floor(fabs(latitude));
    double decimal = fabs(latitude - _degrees);
    double _minutes = decimal * 60.0;
    return [NSString stringWithFormat:@"%03.0f%6.4f,%@",_degrees, _minutes, ((latitude < 0.0) ? @"S" : @"N") ];
}

+ (NSString*)longitudeForCLLocationDegrees:(CLLocationDegrees)longitude {
    
    if (!longitude) {
        return @"0000.0000,E";
    }
    
    double _degrees = floor(fabs(longitude));
    double decimal = fabs(longitude - _degrees);
    double _minutes = decimal * 60.0;
    return [NSString stringWithFormat:@"%03.0f%6.4f,%@",_degrees, _minutes, ((longitude < 0.0) ? @"W" : @"E") ];
}

+ (NSString*)speedToKnots:(CLLocationSpeed)speed {
    
    NSString *knots;
    
    if (speed <= 0.0) {
        knots = @"0.0";
    } else {
        knots = [NSString stringWithFormat:@"%04.1f", speed * 0.514];
    }
    
    return knots;
}

+ (NSString*)CTGetIMEI {
    
    struct CTResult it;
    CFMutableDictionaryRef dict;
    struct CTServerConnection *conn;
    
    conn = _CTServerConnectionCreate(kCFAllocatorDefault, callback, NULL);
    
    _CTServerConnectionCopyMobileEquipmentInfo(&it, conn, &dict);
    CFRelease(conn);
    
    return (__bridge id)CFDictionaryGetValue(dict, (__bridge void *)kCTMobileEquipmentInfoIMEI);
}

+ (NSString*)xorString:(NSString *)string {
    
    int checksum = 0;
    NSUInteger length = [string length];
    unichar buffer[length];
    
    [string getCharacters:buffer range:NSMakeRange(0, length)];
    
    for (NSUInteger i = 0; i < length; i++){
        checksum ^= buffer[i];
    }
    
    return [NSString stringWithFormat:@"%02X",checksum];
}


#pragma mark - debug
+ (void)showLocalNotificationForTestWithMessage:(NSString*)message {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:15];
    notification.alertBody = message;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
