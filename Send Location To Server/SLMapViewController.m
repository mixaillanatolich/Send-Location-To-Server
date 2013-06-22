//
//  SLMapViewController.m
//  Send Location To Server
//
//  Created by Mixaill Anatolich on 6/18/13.
//  Copyright (c) 2013 Mixaill Anatolich. All rights reserved.
//

#import "SLMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface SLMapViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeControl;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation SLMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNumber *type = [UserDefaults valueForKey:@"mapType"];
    if (type && type.intValue < _mapTypeControl.numberOfSegments) {
        _mapTypeControl.selectedSegmentIndex = type.intValue;
        _mapView.mapType = type.intValue;
    }
    
    [_mapTypeControl setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor whiteColor]} forState:UIControlStateNormal];
    [_mapTypeControl setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor lightGrayColor]}  forState:UIControlStateHighlighted];
    [_mapTypeControl setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor lightGrayColor]}  forState:UIControlStateSelected];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_mapView.userLocation.location) {
        [self updateMapRegion:_mapView.userLocation.location];
    } else {
        [self performSelector:@selector(updateMapRegion) withObject:nil afterDelay:1.0];
    }
    
    [NotificationCenter addObserver:self selector:@selector(updateMapRegion) name:UPDATE_LOCATION_NOTIFICATION object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [NotificationCenter removeObserver:self];
    
}

- (void)viewDidUnload {
    [self setMapTypeControl:nil];
    [self setMapView:nil];
    [super viewDidUnload];
}

#pragma mark - private

- (void)updateMapRegion {
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateMapRegion) withObject:nil waitUntilDone:NO];
    }
    
    if (_mapView.userLocation.location) {
        [self updateMapRegion:_mapView.userLocation.location];
    }
}

- (void)updateMapRegion:(CLLocation*)userLocation {
    
    if (!userLocation) {
        return;
    }
    
    MKCoordinateRegion region;
    region.center.latitude = userLocation.coordinate.latitude;
    region.center.longitude = userLocation.coordinate.longitude;
    region.span.longitudeDelta = 0.01;
    region.span.latitudeDelta = 0.01;
    [_mapView setRegion:region animated:YES];
}


- (IBAction)userPositionButtonClicked:(id)sender {
    [self updateMapRegion];
}

- (IBAction)mapTypeChanged:(id)sender {
    switch (_mapTypeControl.selectedSegmentIndex){
        case 0:
            _mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            _mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            _mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            _mapView.mapType = MKMapTypeStandard;
            break;
    }
    
    [UserDefaults setValue:[NSNumber numberWithInt:_mapView.mapType] forKey:@"mapType"];
    [UserDefaults synchronize];
}


@end
