//
//  SLLoggingIntervalViewController.m
//  Send Location To Server
//
//  Created by Mixaill Anatolich on 6/27/13.
//  Copyright (c) 2013 Mixaill Anatolich. All rights reserved.
//

#import "SLLoggingIntervalViewController.h"
#import "SLAppManager.h"

@interface SLLoggingIntervalViewController ()
@property (weak, nonatomic) IBOutlet UITextField *timeIntervalField;

@end

@implementation SLLoggingIntervalViewController

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
    _timeIntervalField.keyboardType = UIKeyboardTypeNumberPad;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _timeIntervalField.text = [NSString stringWithFormat:@"%i", [UserDefaults integerForKey:LOGGIN_INTERVAL_SETTING]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveTimeInterval];
}

- (void)viewDidUnload {
    [self setTimeIntervalField:nil];
    [super viewDidUnload];
}

- (IBAction)doneButtonClicked:(id)sender {
    [self saveTimeInterval];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL retVal;
    
    if (string.length) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *timeInterval = [f numberFromString:string];
        
        if (timeInterval && timeInterval >= 0) {
            retVal = YES;
        } else {
            retVal = NO;
        }
        
    } else {
        retVal = YES;
    }
    
    return retVal;
}

- (void)saveTimeInterval {
    NSString *timeIntervalStr = _timeIntervalField.text;
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *timeInterval = [f numberFromString:timeIntervalStr];
    
    if (timeInterval.integerValue > 0) {
        [UserDefaults setInteger:timeInterval.integerValue forKey:LOGGIN_INTERVAL_SETTING];
        [UserDefaults synchronize];
    } else {
        [UserDefaults setInteger:DEFAULT_LOGGIN_INTERVAL forKey:LOGGIN_INTERVAL_SETTING];
        [UserDefaults synchronize];
    }
    
    [[SLAppManager sharedManager] setupRequestTimer];
}

@end
