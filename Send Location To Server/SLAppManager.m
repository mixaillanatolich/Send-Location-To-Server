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
    requestTimer = [NSTimer scheduledTimerWithTimeInterval:[self updateInterval] target:self selector:@selector(sendLocationToServer) userInfo:nil repeats:YES];
}

- (void)resetRequestTimer {
    [requestTimer invalidate];
    requestTimer = nil;
}

- (NSTimeInterval)updateInterval {
    return 60.0;
}

#pragma mark - public

+ (NSString*)hostname {
    return [NSString stringWithFormat:@"http://tr.gpshome.ru:20100"];
}

+ (NSString*)requestFormat {
    return @"imei=%@lat=%@&lon=%@&speed=%@&heading=%@&vacc=%@&hacc=%@&altitude=%@";
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

+ (void)sendLocation:(CLLocation*)location withFinishBlock:(void(^)())callback {
    
    if (!location) {
        callback();
        return;
    }
    
    
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[self hostname]]];
    
    [client setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"SendLocation %@", [client defaultValueForHeader:@"User-Agent"]]];
    
    NSDictionary *params = @{@"imei": [self CTGetIMEI],
                             @"lat" : [NSString stringWithFormat:@"%.6f", location.coordinate.latitude],
                             @"lon" : [NSString stringWithFormat:@"%.6f", location.coordinate.longitude],
                             @"speed" : [NSString stringWithFormat:@"%.6f", location.speed],
                             @"heading" : [NSString stringWithFormat:@"%.6f", location.course],
                             @"vacc" : [NSString stringWithFormat:@"%.6f", location.verticalAccuracy],
                             @"hacc" : [NSString stringWithFormat:@"%.6f", location.horizontalAccuracy],
                             @"altitude" : [NSString stringWithFormat:@"%.6f", location.altitude],
                             @"deviceid" : @""};
    
       /*imei=013411001582430&
        lat=56.671478&
        lon=43.465025&
        speed=-1.000000&
        heading=-1.000000&
        vacc=10.000000&
        hacc=1414.000000&
        altitude=116.273415&
        deviceid=" */
    
    NSMutableURLRequest *request = [client requestWithMethod:@"GET" path:nil parameters:params];
    [request setTimeoutInterval:15];
    
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
    
}


#pragma mark - debug
+ (void)showLocalNotificationForTestWithMessage:(NSString*)message {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:15];
    notification.alertBody = message;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)sendLocationToServer {
    
    CLLocation *currentLocation = _locationManager.locationManager.location;
    
    if (!currentLocation) {
        return;
    }
    
    lastUpdateDate = [NSDate new];
    
    [SLAppManager sendLocation:currentLocation withFinishBlock:nil];
    
    /*
     AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[self hostname]]];
     
     NSLog(@"def value for header:   %@",[client defaultValueForHeader:@"User-Agent"]);
     
     [client setDefaultHeader:@"User-Agent" value:@"SendLocation (iPhone; iOS 6.1.4; Scale/2.00)"];
     
     NSMutableURLRequest *request = [client requestWithMethod:@"GET" path:@"/?imei=013411001582430&lat=56.671478&lon=43.465025&speed=-1.000000&heading=-1.000000&vacc=10.000000&hacc=1414.000000&altitude=116.273415&deviceid=" parameters:nil];
     
     //NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:@"/gprmc/Data?acct=testandr&dev=test01&gprmc=$GPRMC,204902,A,5640.2307,N,04327.5038,E,000.0,000.0,110613,,*11" parameters:nil];
     
     AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
     NSLog(@"sendLocationToServer %@", JSON);
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
     NSLog(@"sendLocationToServer Fail %@",JSON);
     }];
     [operation start];
     */
    /*
     From Android
     POST /gprmc/Data?acct=testandr&dev=test01&gprmc=$GPRMC,204102,A,5640.2307,N,04327.5038,E,000.0,000.0,110613,,*11 HTTP/1.1
     Content-Length: 1
     Content-Type: application/x-www-form-urlencoded
     Host: tr.gpshome.ru:20100
     Connection: Keep-Alive
     */
    
    /*
     NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://tr.gpshome.ru:20100/gprmc/Data?acct=testandr&dev=test01&gprmc=$GPRMC,205002,A,5640.2307,N,04327.5038,E,000.0,000.0,120613,,*11"]
     cachePolicy:NSURLRequestReloadIgnoringCacheData
     timeoutInterval:30];
     [request setHTTPMethod:@"POST"];
     NSURLResponse *response;
     NSError *error = nil;
     NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
     
     if (error) {
     NSLog(@"launch Request error:%@", error.description);
     }else{
     NSLog(@"launch response:\n%@", [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding]);
     }
     */
}


@end
