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
    }
    return self;
}

- (void)dealloc {

}

#pragma mark - public

- (NSString*)hostname {
    return [NSString stringWithFormat:@"http://tr.gpshome.ru:20100"];
}

- (NSString*)requestFormat {
    return @"imei=%@lat=%@&lon=%@&speed=%@&heading=%@&vacc=%@&hacc=%@&altitude=%@";
}

- (NSString*)CTGetIMEI {
    
    struct CTResult it;
    CFMutableDictionaryRef dict;
    struct CTServerConnection *conn;
    
    conn = _CTServerConnectionCreate(kCFAllocatorDefault, callback, NULL);
    
    _CTServerConnectionCopyMobileEquipmentInfo(&it, conn, &dict);
    CFRelease(conn);
    
    return (__bridge id)CFDictionaryGetValue(dict, (__bridge void *)kCTMobileEquipmentInfoIMEI);
}

- (void)sendLocationToServer {
    
    CLLocation *currentLocation = _locationManager.locationManager.location;
    
    if (!currentLocation) {
        return;
    }
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[self hostname]]];
    
    NSLog(@"def value for header:   %@",[client defaultValueForHeader:@"User-Agent"]);
    
    //[client setDefaultHeader:@"User-Agent" value:@"SendLocation (iPhone; iOS 6.1.4; Scale/2.00)"];
    
    NSMutableURLRequest *request = [client requestWithMethod:@"GET" path:@"/?imei=013411001582430&lat=56.671478&lon=43.465025&speed=-1.000000&heading=-1.000000&vacc=10.000000&hacc=1414.000000&altitude=116.273415&deviceid=" parameters:nil];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"sendLocationToServer %@", JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"sendLocationToServer Fail %@",JSON);
    }];
    [operation start];
    
}

@end
