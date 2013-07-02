//
//  SLDeviceIDViewController.m
//  Send Location To Server
//
//  Created by Mixaill Anatolich on 7/1/13.
//  Copyright (c) 2013 Mixaill Anatolich. All rights reserved.
//

#import "SLDeviceIDViewController.h"

@interface SLDeviceIDViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *sendParameterSwitch;
@property (weak, nonatomic) IBOutlet UITextField *deviceIdField;

@end

@implementation SLDeviceIDViewController

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
	// Do any additional setup after loading the view.
    
    [_sendParameterSwitch setOn:[UserDefaults boolForKey:SEND_DEVICE_ID_SETTING]];
    _deviceIdField.text = [UserDefaults objectForKey:DEVICE_ID_SETTING] ? [UserDefaults objectForKey:DEVICE_ID_SETTING] : @"";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UserDefaults setObject:(_deviceIdField.text ? _deviceIdField.text : @"") forKey:DEVICE_ID_SETTING];
    [UserDefaults synchronize];
}

- (void)viewDidUnload {
    [self setSendParameterSwitch:nil];
    [self setDeviceIdField:nil];
    [super viewDidUnload];
}


- (IBAction)sendParameterStateChanged:(id)sender {
    [UserDefaults setBool:_sendParameterSwitch.isOn forKey:SEND_DEVICE_ID_SETTING];
    [UserDefaults synchronize];
}


@end
