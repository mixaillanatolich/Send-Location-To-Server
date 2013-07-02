//
//  SLAccountIDViewController.m
//  Send Location To Server
//
//  Created by Mixaill Anatolich on 7/1/13.
//  Copyright (c) 2013 Mixaill Anatolich. All rights reserved.
//

#import "SLAccountIDViewController.h"

@interface SLAccountIDViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *sendParameterSwitch;
@property (weak, nonatomic) IBOutlet UITextField *accountIdField;

@end

@implementation SLAccountIDViewController

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
    
    [_sendParameterSwitch setOn:[UserDefaults boolForKey:SEND_ACCOUNT_ID_SETTING]];
    _accountIdField.text = [UserDefaults objectForKey:ACCOUNT_ID_SETTING] ? [UserDefaults objectForKey:ACCOUNT_ID_SETTING] : @"";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UserDefaults setObject:(_accountIdField.text ? _accountIdField.text : @"") forKey:ACCOUNT_ID_SETTING];
    [UserDefaults synchronize];
}

- (void)viewDidUnload {
    [self setSendParameterSwitch:nil];
    [self setAccountIdField:nil];
    [super viewDidUnload];
}


- (IBAction)sendParameterStateChanged:(id)sender {
    [UserDefaults setBool:_sendParameterSwitch.isOn forKey:SEND_ACCOUNT_ID_SETTING];
    [UserDefaults synchronize];
}


@end
