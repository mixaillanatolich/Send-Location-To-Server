//
//  SLAppManager.h
//  Send Location To Server
//
//  Created by Mixaill Anatolich on 6/10/13.
//  Copyright (c) 2013 Mixaill Anatolich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLLocationManager.h"

@interface SLAppManager : NSObject

+ (SLAppManager*)sharedManager;

- (void)sendLocationToServer;

- (NSString*)hostname;
- (NSString*)requestFormat;

@property (nonatomic, strong) SLLocationManager *locationManager;

@end
