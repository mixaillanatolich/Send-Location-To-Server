//
//  SLMainViewController.m
//  Send Location To Server
//
//  Created by Mixaill Anatolich on 6/10/13.
//  Copyright (c) 2013 Mixaill Anatolich. All rights reserved.
//

#import "SLLocationDetailViewController.h"
#import "SLAppManager.h"
#import "SLLocationManager.h"

@interface SLLocationDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *altitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *directionLabel;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;


@property (weak, nonatomic) IBOutlet UIButton *sendingLoopButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end

@implementation SLLocationDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sendingLoopButton.selected = [UserDefaults boolForKey:SEND_LOCATION_ENABLED];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateLocationInfo];
    
    [NotificationCenter addObserver:self selector:@selector(updateLocationInfo) name:UPDATE_LOCATION_NOTIFICATION object:nil];
    [NotificationCenter addObserver:self selector:@selector(updateLocationInfo) name:SEND_LOCATION_NOTIFICATION object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [NotificationCenter removeObserver:self];
    
}

- (void)viewDidUnload {
    [self setSendingLoopButton:nil];
    [self setSendButton:nil];
    [self setTimestampLabel:nil];
    [self setLatitudeLabel:nil];
    [self setLongitudeLabel:nil];
    [self setAltitudeLabel:nil];
    [self setSpeedLabel:nil];
    [self setDirectionLabel:nil];
    [self setAccuracyLabel:nil];
    [super viewDidUnload];
}



- (IBAction)sendButtonClicked:(id)sender {
    [[SLAppManager sharedManager] sendLocationToServer];
}

- (IBAction)sendLoopButtonClicked:(id)sender {
    BOOL sendLocation = [UserDefaults boolForKey:SEND_LOCATION_ENABLED];
    
    sendLocation = !sendLocation;
    
    _sendingLoopButton.selected = sendLocation;
    
    [UserDefaults setBool:sendLocation forKey:SEND_LOCATION_ENABLED];
    [UserDefaults synchronize];
}

#pragma mark - private
- (void)updateLocationInfo {
    
    CLLocation *currentLocation = [[SLLocationManager sharedManager] locationManager].location;
    
    NSString *timestamp;
    NSString *latitude;
    NSString *longitude;
    NSString *altitude;
    NSString *speed;
    NSString *direction;
    NSString *accuracy;
    
    
    if (currentLocation) {
        NSDate *date = currentLocation.timestamp;
        if (date) {
            NSLocale * enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] ;
            NSDateFormatter *formatOfDate = [[NSDateFormatter alloc] init];
            [formatOfDate setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
            [formatOfDate setLocale:enUSPOSIXLocale];
            NSString *time = [formatOfDate stringFromDate:date];
            timestamp = [NSString stringWithFormat:@"Last update: %@", time];
        } else {
            timestamp = @"Last update: n/a";
        }
        
        latitude = [NSString stringWithFormat:@"Latitude: %f", currentLocation.coordinate.latitude];

        longitude = [NSString stringWithFormat:@"Longitude: %f", currentLocation.coordinate.longitude];
        
        altitude = [NSString stringWithFormat:@"Altitude: %.2f m", currentLocation.altitude];
        
        CLLocationSpeed aSpeed = currentLocation.speed;
        if (aSpeed >= 0.0) {
            speed = [NSString stringWithFormat:@"Speed: %.2f km/h", aSpeed * 3.6];
        } else {
            speed = @"Speed: n/a";
        }
        
        CLLocationDirection aCource = currentLocation.course;
        if (aCource >= 0.0) {
            direction = [NSString stringWithFormat:@"Direction: %i°", (int)aCource];
        } else {
            direction = @"Direction: n/a";
        }
        
        CLLocationAccuracy verticalAccuracy = currentLocation.verticalAccuracy;
        NSString *aVerticalAccuracy;
        if (verticalAccuracy >= 0.0) {
            aVerticalAccuracy = [NSString stringWithFormat:@"V: %0.2f", verticalAccuracy];
        } else {
            aVerticalAccuracy = @"V: n/a";
        }
        CLLocationAccuracy horizontalAccuracy = currentLocation.horizontalAccuracy;
        NSString *aHorizontalAccuracy;
        if (horizontalAccuracy >= 0.0) {
            aHorizontalAccuracy = [NSString stringWithFormat:@"H: %0.2f", horizontalAccuracy];
        } else {
            aHorizontalAccuracy = @"H: n/a";
        }
        
        accuracy = [NSString stringWithFormat:@"Accuracy %@ %@", aVerticalAccuracy, aHorizontalAccuracy];

    } else {
        timestamp = @"Last update: n/a";
        latitude = @"Latitude: n/a";
        longitude = @"Longitude: n/a";
        altitude = @"Altitude: n/a";
        speed = @"Speed: n/a";
        direction = @"Direction: n/a";
        accuracy = @"Accuracy: n/a";
    }
    
    _timestampLabel.text = timestamp;
    _latitudeLabel.text = latitude;
    _longitudeLabel.text = longitude;
    _altitudeLabel.text = altitude;
    _speedLabel.text = speed;
    _directionLabel.text = direction;
    _accuracyLabel.text = accuracy;
    
}

@end
